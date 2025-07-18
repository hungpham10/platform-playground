VERSION 0.7

molecule-gateway:
    FROM serversideup/ansible:8.7.0-bullseye-python3.12

    # Set environment variables for instances
    ENV INSTANCE_IP="192.168.24.129"
    ENV INSTANCE_USER="devops"
    ENV INSTANCE_GW="192.168.24.1"
    ENV SUDO_PASSWORD="rootroot"
    ENV SSH_KEY_PATH=/root/.ssh/id_rsa

    # Copy Ansible and Molecule files
    COPY ansible/playbooks/* ./ansible/
    COPY ansible/roles       ./ansible/roles
    COPY ansible/group_vars  ./ansible/group_vars
    COPY tests/ansible/gateway ./ansible/molecule
    COPY ansible/requirements.txt ./

    # Copy SSH keys and set permissions
    COPY .ssh/id_rsa /root/.ssh/
    RUN chmod 600 /root/.ssh/*
        
    # Install Python dependencies
    RUN pip3 install -r requirements.txt

    # Run molecule tests
    WORKDIR ./ansible
    RUN molecule test
