#!/bin/bash

set -e

# Default values
DEFAULT_SSL_SOURCE="./kafka-certs"
DEFAULT_ROLE_PATH="./roles/kafka"
DEFAULT_PASSWORD="password123"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -s, --source SOURCE  Source certificates directory (default: $DEFAULT_SSL_SOURCE)"
    echo "  -r, --role ROLE      Ansible role path (default: $DEFAULT_ROLE_PATH)"
    echo "  -p, --password PWD   Password for certificates (default: $DEFAULT_PASSWORD)"
    echo "  -h, --help          Show this help message"
}

# Parse arguments
SSL_SOURCE="$DEFAULT_SSL_SOURCE"
ROLE_PATH="$DEFAULT_ROLE_PATH"
PASSWORD="$DEFAULT_PASSWORD"

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            SSL_SOURCE="$2"
            shift 2
            ;;
        -r|--role)
            ROLE_PATH="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check if source directory exists
if [ ! -d "$SSL_SOURCE" ]; then
    echo "❌ Source directory $SSL_SOURCE does not exist"
    echo "   Please generate certificates first using generate-kafka-certs-openssl.sh"
    exit 1
fi

# Check if role directory exists
if [ ! -d "$ROLE_PATH" ]; then
    echo "❌ Role directory $ROLE_PATH does not exist"
    echo "   Creating directory structure..."
    mkdir -p "$ROLE_PATH/files/ssl"
    mkdir -p "$ROLE_PATH/tasks"
    mkdir -p "$ROLE_PATH/defaults"
    mkdir -p "$ROLE_PATH/handlers"
fi

# Create ssl directory in role if it doesn't exist
mkdir -p "$ROLE_PATH/files/ssl"

# Copy certificate files
echo "📁 Copying certificates to role..."
cp "$SSL_SOURCE/kafka.keystore.p12" "$ROLE_PATH/files/ssl/"
cp "$SSL_SOURCE/kafka.truststore.p12" "$ROLE_PATH/files/ssl/"
cp "$SSL_SOURCE/broker-cert.pem" "$ROLE_PATH/files/ssl/"
cp "$SSL_SOURCE/ca-cert.pem" "$ROLE_PATH/files/ssl/"

# Update defaults/certificates.yml with password
DEFAULTS_FILE="$ROLE_PATH/defaults/main/certificates.yml"

# Create defaults directory if it doesn't exist
mkdir -p "$ROLE_PATH/defaults/main"

# Create or update defaults/certificates.yml
cat > "$DEFAULTS_FILE" << EOF
# Kafka SSL Configuration
kafka_ssl_dir: "/opt/kafka/ssl"
kafka_cluster_certificate:
  truststore:
    destination: "kafka.truststore.p12"
    password: "$PASSWORD"
    type: "PKCS12"
  keystore:
    destination: "kafka.keystore.p12"
    password: "$PASSWORD"
    type: "PKCS12"
  ca_cert:
    destination: "ca-cert.pem"
  broker_cert:
    destination: "broker-cert.pem"
EOF

echo "✅ Certificates copied to $ROLE_PATH/files/ssl/"
echo "✅ Default variables updated in $ROLE_PATH/defaults/main/certificates.yml"
echo ""
echo "🔐 Password set to: $PASSWORD"
echo ""
echo "🚀 Next steps: Run your Ansible playbook"
