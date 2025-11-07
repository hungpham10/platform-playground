
#!/bin/bash
set -e

# Default values
DEFAULT_SSL_DIR="kafka-p12-certs"
DEFAULT_PASSWORD="password123"
DEFAULT_DOMAINS="kafka.local"

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -d, --dir DIR          SSL directory (default: $DEFAULT_SSL_DIR)"
    echo "  -p, --password PWD     Password for keystore/truststore (default: $DEFAULT_PASSWORD)"
    echo "  -n, --domains DOMAINS  Comma-separated list of domains (default: $DEFAULT_DOMAINS)"
    echo "  -h, --hosts HOSTS      Comma-separated list of Kafka hostnames/IPs"
    echo "  -f, --hostfile FILE    File containing list of hostnames/IPs (one per line)"
    echo "  --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -h 'kafka1,kafka2,kafka3,192.168.1.100' -n 'tiki.vn,internal.tiki.vn'"
    echo "  $0 -f hosts.txt -n 'company.com,company.net,company.local'"
    echo "  $0 -h 'kafka1,kafka2' -n 'domain1.com,domain2.com' -p mypass123"
    exit 0
}

# Parse arguments
SSL_DIR="$DEFAULT_SSL_DIR"
PASSWORD="$DEFAULT_PASSWORD"
DOMAINS="$DEFAULT_DOMAINS"
HOSTS=""
HOSTFILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            SSL_DIR="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -n|--domains)
            DOMAINS="$2"
            shift 2
            ;;
        -h|--hosts)
            HOSTS="$2"
            shift 2
            ;;
        -f|--hostfile)
            HOSTFILE="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$HOSTS" && -z "$HOSTFILE" ]]; then
    echo "❌ Error: You must specify either --hosts or --hostfile"
    usage
    exit 1
fi

# Read hosts from file or string
HOST_LIST=()
if [[ -n "$HOSTFILE" ]]; then
    if [[ ! -f "$HOSTFILE" ]]; then
        echo "❌ Error: Hostfile $HOSTFILE not found"
        exit 1
    fi
    echo "📖 Reading hosts from file: $HOSTFILE"
    while IFS= read -r line; do
        [[ -n "$line" ]] && HOST_LIST+=("$line")
    done < "$HOSTFILE"
else
    echo "📖 Reading hosts from command line"
    IFS=',' read -ra HOST_LIST <<< "$HOSTS"
fi

# Read domains from string
DOMAIN_LIST=()
IFS=',' read -ra DOMAIN_LIST <<< "$DOMAINS"
PRIMARY_DOMAIN="${DOMAIN_LIST[0]}"

# Display configuration
echo "🔐 Creating Kafka PKCS12 certificates with multiple domains..."
echo "   Directory: $SSL_DIR"
echo "   Password: $PASSWORD"
echo "   Domains: ${DOMAIN_LIST[*]}"
echo "   Primary domain: $PRIMARY_DOMAIN"
echo "   Hosts: ${HOST_LIST[*]}"
echo ""

# Clean and create directory
rm -rf "$SSL_DIR"
mkdir -p "$SSL_DIR"

# Save host and domain lists for reference
printf "%s\n" "${HOST_LIST[@]}" > "$SSL_DIR/hosts.txt"
printf "%s\n" "${DOMAIN_LIST[@]}" > "$SSL_DIR/domains.txt"

# FIX: Use consistent CA name without domain suffix to avoid mismatch
CA_CN="Kafka-CA"
BROKER_CN="broker"

# Step 1: Generate CA
echo "1. 📜 Generating Certificate Authority..."
openssl genrsa -out "$SSL_DIR/ca-key.pem" 4096
openssl req -new -x509 \
    -key "$SSL_DIR/ca-key.pem" \
    -out "$SSL_DIR/ca-cert.pem" \
    -days 3650 \
    -subj "/C=VN/ST=HCMC/L=HCMC/O=Tiki/CN=$CA_CN" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" \
    -addext "basicConstraints=critical,CA:TRUE"

# Step 2: Generate broker certificate with dynamic SAN for all domains
echo "2. 🔧 Generating broker certificate with SAN for all hosts and domains..."

# Create SAN configuration dynamically
cat <<EOF > "$SSL_DIR/broker-ext.cnf"
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = VN
ST = HCMC
L = HCMC
O = Tiki
CN = $BROKER_CN

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
basicConstraints = critical,CA:FALSE

[alt_names]
EOF

# Add dynamic SAN entries
DNS_COUNT=1
IP_COUNT=1

# Add hosts with all domains
for host in "${HOST_LIST[@]}"; do
    if [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # It's an IP address
        echo "IP.$IP_COUNT = $host" >> "$SSL_DIR/broker-ext.cnf"
        ((IP_COUNT++))
    else
        # It's a hostname - add for all domains
        echo "DNS.$DNS_COUNT = $host" >> "$SSL_DIR/broker-ext.cnf"
        ((DNS_COUNT++))
        
        # Add FQDN for each domain
        for domain in "${DOMAIN_LIST[@]}"; do
            if [[ "$host" != "localhost" ]]; then
                echo "DNS.$DNS_COUNT = $host.$domain" >> "$SSL_DIR/broker-ext.cnf"
                ((DNS_COUNT++))
            fi
        done
    fi
done

# Add wildcards for all domains
for domain in "${DOMAIN_LIST[@]}"; do
    echo "DNS.$DNS_COUNT = *.$domain" >> "$SSL_DIR/broker-ext.cnf"
    ((DNS_COUNT++))
done

# Add common entries
echo "DNS.$DNS_COUNT = localhost" >> "$SSL_DIR/broker-ext.cnf"
((DNS_COUNT++))
echo "IP.$IP_COUNT = 127.0.0.1" >> "$SSL_DIR/broker-ext.cnf"
((IP_COUNT++))
echo "IP.$IP_COUNT = ::1" >> "$SSL_DIR/broker-ext.cnf"

# Display SAN summary
echo "   SAN includes:"
echo "   - ${#HOST_LIST[@]} hosts with ${#DOMAIN_LIST[@]} domains each"
echo "   - ${#DOMAIN_LIST[@]} wildcard domains"
echo "   - Common entries (localhost, 127.0.0.1, ::1)"

# Generate broker certificate
openssl genrsa -out "$SSL_DIR/broker-key.pem" 2048
openssl req -new \
    -key "$SSL_DIR/broker-key.pem" \
    -out "$SSL_DIR/broker-csr.pem" \
    -config "$SSL_DIR/broker-ext.cnf"

openssl x509 -req \
    -in "$SSL_DIR/broker-csr.pem" \
    -CA "$SSL_DIR/ca-cert.pem" \
    -CAkey "$SSL_DIR/ca-key.pem" \
    -CAcreateserial \
    -out "$SSL_DIR/broker-cert.pem" \
    -days 365 \
    -extfile "$SSL_DIR/broker-ext.cnf" \
    -extensions v3_req

# Step 3: Create broker PKCS12 keystore
echo "3. 💾 Creating broker PKCS12 keystore..."
openssl pkcs12 -export \
    -in "$SSL_DIR/broker-cert.pem" \
    -inkey "$SSL_DIR/broker-key.pem" \
    -chain \
    -CAfile "$SSL_DIR/ca-cert.pem" \
    -name "kafka-broker" \
    -out "$SSL_DIR/kafka.keystore.p12" \
    -password "pass:$PASSWORD"

# Step 4: Create truststore
echo "4. 🔒 Creating truststore..."
if which keytool &> /dev/null; then
    keytool -import -trustcacerts \
        -alias "kafka-ca" \
        -file "$SSL_DIR/ca-cert.pem" \
        -keystore "$SSL_DIR/kafka.truststore.p12" \
        -storetype PKCS12 \
        -storepass "$PASSWORD" \
        -noprompt
else
    openssl pkcs12 -export \
        -nokeys \
        -in "$SSL_DIR/ca-cert.pem" \
        -name "kafka-ca" \
        -out "$SSL_DIR/kafka.truststore.p12" \
        -password "pass:$PASSWORD"
fi

# Step 5: Generate individual broker certificates (optional)
echo "5. 🖥️  Generating individual broker certificates..."
for host in "${HOST_LIST[@]}"; do
    if [[ ! "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Only create individual certs for hostnames (not pure IPs)
        echo "   Creating certificate for: $host"
        
        # Create individual broker SAN config with all domains
        cat <<EOF > "$SSL_DIR/broker-${host}.cnf"
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = VN
ST = HCMC
L = HCMC
O = Tiki
CN = $host

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
basicConstraints = critical,CA:FALSE

[alt_names]
DNS.1 = $host
EOF
        
        # Add all domains for this host
        DOMAIN_DNS_COUNT=2
        for domain in "${DOMAIN_LIST[@]}"; do
            echo "DNS.$DOMAIN_DNS_COUNT = $host.$domain" >> "$SSL_DIR/broker-${host}.cnf"
            ((DOMAIN_DNS_COUNT++))
        done
        
        # Add common entries
        cat <<EOF >> "$SSL_DIR/broker-${host}.cnf"
DNS.$DOMAIN_DNS_COUNT = localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

        # Generate individual broker certificate
        openssl genrsa -out "$SSL_DIR/broker-${host}-key.pem" 2048
        openssl req -new \
            -key "$SSL_DIR/broker-${host}-key.pem" \
            -out "$SSL_DIR/broker-${host}-csr.pem" \
            -config "$SSL_DIR/broker-${host}.cnf"

        openssl x509 -req \
            -in "$SSL_DIR/broker-${host}-csr.pem" \
            -CA "$SSL_DIR/ca-cert.pem" \
            -CAkey "$SSL_DIR/ca-key.pem" \
            -CAcreateserial \
            -out "$SSL_DIR/broker-${host}-cert.pem" \
            -days 365 \
            -extfile "$SSL_DIR/broker-${host}.cnf" \
            -extensions v3_req

        # Create individual keystore
        openssl pkcs12 -export \
            -in "$SSL_DIR/broker-${host}-cert.pem" \
            -inkey "$SSL_DIR/broker-${host}-key.pem" \
            -chain \
            -CAfile "$SSL_DIR/ca-cert.pem" \
            -name "kafka-broker-$host" \
            -out "$SSL_DIR/kafka.${host}.keystore.p12" \
            -password "pass:$PASSWORD"
    fi
done

# Step 6: Generate client certificate
echo "6. 👤 Generating client certificate..."
cat <<EOF > "$SSL_DIR/client-ext.cnf"
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = VN
ST = HCMC
L = HCMC
O = Tiki
CN = kafka-client

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = @alt_names
basicConstraints = critical,CA:FALSE

[alt_names]
DNS.1 = kafka-client
EOF

# Add all domains for client
CLIENT_DNS_COUNT=2
for domain in "${DOMAIN_LIST[@]}"; do
    echo "DNS.$CLIENT_DNS_COUNT = kafka-client.$domain" >> "$SSL_DIR/client-ext.cnf"
    ((CLIENT_DNS_COUNT++))
done

cat <<EOF >> "$SSL_DIR/client-ext.cnf"
IP.1 = 127.0.0.1
EOF

openssl genrsa -out "$SSL_DIR/client-key.pem" 2048
openssl req -new \
    -key "$SSL_DIR/client-key.pem" \
    -out "$SSL_DIR/client-csr.pem" \
    -config "$SSL_DIR/client-ext.cnf"

openssl x509 -req \
    -in "$SSL_DIR/client-csr.pem" \
    -CA "$SSL_DIR/ca-cert.pem" \
    -CAkey "$SSL_DIR/ca-key.pem" \
    -CAcreateserial \
    -out "$SSL_DIR/client-cert.pem" \
    -days 365 \
    -extfile "$SSL_DIR/client-ext.cnf" \
    -extensions v3_req

openssl pkcs12 -export \
    -in "$SSL_DIR/client-cert.pem" \
    -inkey "$SSL_DIR/client-key.pem" \
    -chain \
    -CAfile "$SSL_DIR/ca-cert.pem" \
    -name "kafka-client" \
    -out "$SSL_DIR/client.keystore.p12" \
    -password "pass:$PASSWORD"

# Step 7: Create client configuration
echo "7. ⚙️  Creating client configuration..."
cat <<EOF > "$SSL_DIR/client.properties"
# Kafka SSL Client Configuration
security.protocol=SSL
ssl.truststore.location=/opt/kafka/ssl/kafka.truststore.p12
ssl.truststore.password=$PASSWORD
ssl.truststore.type=PKCS12

ssl.keystore.location=/opt/kafka/ssl/client.keystore.p12
ssl.keystore.password=$PASSWORD
ssl.keystore.type=PKCS12

ssl.endpoint.identification.algorithm=
EOF

# Step 8: Verification and validation
echo "8. ✅ Verifying certificates..."
echo "   Broker certificate SAN summary:"
openssl x509 -in "$SSL_DIR/broker-cert.pem" -text -noout | grep -A 30 "Subject Alternative Name" | head -20

# FIXED: Certificate chain validation with proper string comparison
echo ""
echo "   🔍 Validating certificate chain..."
CA_SUBJECT=$(openssl x509 -in "$SSL_DIR/ca-cert.pem" -noout -subject | sed 's/subject=//')
BROKER_ISSUER=$(openssl x509 -in "$SSL_DIR/broker-cert.pem" -noout -issuer | sed 's/issuer=//')

echo "   CA Subject: $CA_SUBJECT"
echo "   Broker Issuer: $BROKER_ISSUER"

# Normalize strings for comparison (remove spaces and convert to same case)
NORMALIZED_CA=$(echo "$CA_SUBJECT" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
NORMALIZED_BROKER=$(echo "$BROKER_ISSUER" | tr -d ' ' | tr '[:upper:]' '[:lower:]')

if [[ "$NORMALIZED_CA" == "$NORMALIZED_BROKER" ]]; then
    echo "   ✅ Certificate chain is valid (CA matches broker issuer)"
else
    echo "   ❌ WARNING: CA and broker issuer don't match!"
    echo "   This will cause SSL handshake failures!"
    exit 1
fi

# FIXED: Test certificate chain validation using openssl verify
echo ""
echo "   🔍 Testing certificate chain with openssl verify..."
if openssl verify -CAfile "$SSL_DIR/ca-cert.pem" "$SSL_DIR/broker-cert.pem" > /dev/null 2>&1; then
    echo "   ✅ Certificate chain validation passed (openssl verify)"
else
    echo "   ❌ Certificate chain validation failed!"
    openssl verify -CAfile "$SSL_DIR/ca-cert.pem" "$SSL_DIR/broker-cert.pem"
    exit 1
fi

# FIXED: Test truststore contains the correct CA
echo ""
echo "   🔍 Validating truststore..."
if which keytool &> /dev/null; then
    if keytool -list -v -keystore "$SSL_DIR/kafka.truststore.p12" -storepass "$PASSWORD" -storetype PKCS12 2>/dev/null | grep -q "kafka-ca"; then
        echo "   ✅ Truststore contains the correct CA certificate"
    else
        echo "   ❌ WARNING: Truststore doesn't contain the expected CA"
        exit 1
    fi
fi

# NEW: Test the actual PKCS12 files can be read
echo ""
echo "   🔍 Testing PKCS12 file accessibility..."
if keytool -list -keystore "$SSL_DIR/kafka.keystore.p12" -storepass "$PASSWORD" -storetype PKCS12 > /dev/null 2>&1; then
    echo "   ✅ Broker keystore is accessible and valid"
else
    echo "   ❌ Broker keystore is inaccessible or invalid"
    exit 1
fi

if keytool -list -keystore "$SSL_DIR/kafka.truststore.p12" -storepass "$PASSWORD" -storetype PKCS12 > /dev/null 2>&1; then
    echo "   ✅ Truststore is accessible and valid"
else
    echo "   ❌ Truststore is inaccessible or invalid"
    exit 1
fi

echo ""
echo "🎉 CERTIFICATES CREATED AND VALIDATED SUCCESSFULLY!"
echo ""
echo "📊 Summary:"
echo "   Total hosts: ${#HOST_LIST[@]}"
echo "   Total domains: ${#DOMAIN_LIST[@]}"
echo "   Primary domain: $PRIMARY_DOMAIN"
echo "   All domains: ${DOMAIN_LIST[*]}"
echo "   CA Common Name: $CA_CN"
echo "   Broker Common Name: $BROKER_CN"
echo ""
echo "📁 Generated files in $SSL_DIR/:"
echo "   kafka.keystore.p12          - Universal broker keystore (all hosts & domains)"
echo "   kafka.truststore.p12        - Truststore"
echo "   client.keystore.p12         - Client keystore"
echo "   client.properties           - Client config"
echo "   hosts.txt                   - List of processed hosts"
echo "   domains.txt                 - List of processed domains"
echo "   kafka.{host}.keystore.p12   - Individual broker keystores"
echo ""
echo "🔐 Password: $PASSWORD"
echo ""
echo "🚀 For Ansible deployment:"
echo "   cp $SSL_DIR/kafka.keystore.p12 $SSL_DIR/kafka.truststore.p12 /path/to/ansible/roles/kafka/files/ssl/"
echo ""
echo "💡 Important: The CA name is now consistent ('$CA_CN') to prevent SSL handshake issues"
