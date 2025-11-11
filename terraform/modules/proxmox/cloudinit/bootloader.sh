#!/bin/bash

######################################################################
# @author      : Hung Nguyen Xuan Pham (hung0913208@gmail.com)
# @file        : gateway
# @created     : Sunday Dec 04, 2022 20:49:00 +07
#
# @description : bootstrap of initing node
######################################################################

function error() {
	if [ $# -eq 2 ]; then
		echo "[  ERROR  ]: $1 line ${SCRIPT}:$2"
	else
		echo "[  ERROR  ]: $1 in ${SCRIPT}"
	fi

  curl -X POST                                                                                                                      \
       -H "Content-Type: application/json"                                                                                          \
       -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"[${hostname}]: $1 in ${SCRIPT}\", \"disable_notification\": false}"     \
        https://api.telegram.org/bot${telegram_bot_token}/sendMessage
	exit 1
}

function error_with_log() {
  curl -X POST                                                                                                                      \
       -H "Content-Type: application/json"                                                                                          \
       -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"${hostname}: ${1}\nReason:\\n\", \"disable_notification\": false}"      \
        https://api.telegram.org/bot${telegram_bot_token}/sendMessage
  curl -v -F "chat_id=${telegram_chat_id}" -F document=@$2 https://api.telegram.org/bot${telegram_bot_token}/sendDocument
	exit 1
}

function cleanup() {
  rm -fr /tmp/playbook
  rm -fr /tmp/hosts
  rm -fr /tmp/id_rsa
  rm -fr /tmp/id_rsa.pub
  rm -fr /tmp/id_rsa.base64
}

function clone_playbook_from_local_storage() {
  if ! tar -xzf /tmp/playbook.tar.gz -C /tmp; then
    error "failed to extract /tmp/playbook.tar.gz to /tmp"
  fi 
}

function clone_playbook_from_installer() {
  # Fetch playbook from TFTP server
  if [[ ${#tftp_server_ip} -eq 0 ]]; then
    error "missing tftp_server_ip"
  fi

  tftp $tftp_server_ip <<EOF
  get pkg/configuration.tar.gz /tmp/playbook.tar.gz
  quit
EOF

  if [ ! -f /tmp/playbook.tar.gz ]; then
    error "failed to fetch configmap from tftp server"
  fi

  if ! tar -xzf /tmp/playbook.tar.gz -C /tmp; then
    error "failed to extract /tmp/playbook.tar.gz to /tmp"
  fi
}

function clone_agent_from_installer() {
  # Fetch agent from TFTP server

  if [ "${use_alpaca_agent}" = "true" ]; then
    if [[ ${#tftp_server_ip} -eq 0 ]]; then
      error "missing tftp_server_ip"
    fi

    tftp $tftp_server_ip <<EOF
    get agent.tar.gz /tmp/agent.tar.gz
    quit
EOF

    if [ ! -f /tmp/agent.tar.gz ]; then
      error "failed to fetch configmap from tftp server"
    fi

    if ! tar -xzf /tmp/agent.tar.gz -C /tmp; then
      error "failed to extract /tmp/agent.tar.gz to /tmp"
    fi
  fi
}

function clone_config_from_installer() {
  # Fetch playbook from TFTP server
  if [[ ${#tftp_server_ip} -eq 0 ]]; then
    error "missing tftp_server_ip"
  fi

  tftp $tftp_server_ip <<EOF
  get instances/${ip_of_this_instance}.tar.gz /tmp/configmap.tar.gz
  quit
EOF

  if [ ! -f /tmp/configmap.tar.gz ]; then
    error "failed to fetch configmap from tftp server"
  fi

  if ! tar -xzf /tmp/configmap.tar.gz -C /tmp; then
    error "failed to extract /tmp/configmap.tar.gz to /tmp"
  fi
}

function clone_utilities_from_installer() {
  # Fetch utilities from TFTP server
  if [[ ${#tftp_server_ip} -eq 0 ]]; then
    error "missing tftp_server_ip"
  fi

  tftp $tftp_server_ip <<EOF
  get utilities.tar.gz /tmp/utilities.tar.gz
  quit
EOF

  if [ ! -f /tmp/utilities.tar.gz ]; then
    error "failed to fetch configmap from tftp server"
  fi

  if ! tar -xzf /tmp/utilities.tar.gz -C /tmp; then
    error "failed to extract /tmp/utilities.tar.gz to /tmp"
  fi
}

function init_using_local_storage() {
  clone_playbook_from_local_storage
  init
}

function init_using_installer() {
  clone_config_from_installer
  clone_agent_from_installer
  clone_playbook_from_installer
  init
}

function init() {
  # Build ansible playbook from our template
  if ! cp -av /tmp/playbook/ansible /etc/ansible/; then
    error "fail copying /tmp/playbook/ansible to /etc/ansible"
  fi
  if ! cp -av /tmp/inventory.json /etc/ansible/; then
    error "fail copying /tmp/inventory.json to /etc/ansible"
  fi

  # Generate ssh-key and copy to our ansible playbook
  if ! base64 --decode /tmp/id_rsa.base64 | tee /etc/ansible/id_rsa; then
    error "fail decoding /tmp/id_rsa.base64 to /etc/ansible/id_rsa"
  fi
  if ! cp -av /tmp/id_rsa.pub /etc/ansible/id_rsa.pub; then
    error "fail copying /tmp/id_rsa.pub to /etc/ansible/"
  fi
  chmod 0600 /etc/ansible/id_rsa
  chmod 0600 /etc/ansible/id_rsa.pub

  mkdir -p /usr/local/{bin,lib}
  mkdir -p /usr/local/lib/devops

  if [ "${use_alpaca_agent}" = "true" ]; then
    # Copy agent and setup agent service to run in each instance
    if ! cp -av /tmp/agent/agent /usr/local/bin/agent; then
      error "fail copying /tmp/agent/agent to /usr/local/bin/agent"
    fi
    chmod +x /usr/local/bin/agent

    if ! cp -av /tmp/agent/agent.service /etc/systemd/system/agent.service; then
      error "fail copying /tmp/agent/agent.service to /etc/systemd/system/agent.service"
    fi

    # Start agent
    systemctl daemon-reload
    systemctl enable agent.service
    systemctl start agent.service
  fi

  # Setup ansible
  if ! apt install -y python3-pip git; then
    error "fail install python3-pip"
  fi
  if ! pip3 install ansible; then
    error "fail install ansible"
  fi
}

function include_libraries() {
  if [ -d /usr/local/lib/devops ]; then
    for LIB in $(ls -1c /usr/local/lib/devops/*.sh); do
      source $LIB
    done
  fi
}

function setup_dependencies() {
  pip3 install -r /etc/ansible/requirements.txt
}

function perform_setup_playbook_without_agent() {
  if [ ! -f "$infrastructure_config_yaml_path" ]; then
    error "Please configure $infrastructure_config_yaml_path"
  fi

  if ! ansible-playbook -i /etc/ansible/inventory.json /etc/ansible/${playbook}                                         \
            --private-key /etc/ansible/id_rsa                                                                           \
            --tags setup --skip-tags always &> /tmp/ansible.log; then
        REASON=$(tac /var/log/cloud-init-output.log | awk '/PLAY RECAP/,/TASK /' | tac - | tr '\r\n' ' ' | tr '\"' "'")
    if ! echo "$REASON" | grep "FAILED\|failed\|fatal"; then
      REASON=$(tail -100 /tmp/ansible.log)
    fi

    error_with_log "Fail setup ${hostname}" /tmp/ansible.log
  fi
}

function perform_setup_playbook_with_agent() {
  if regenerate_internal_intrastructure_yaml_from_agent "/etc/ansible/infrastructure.yml"; then
    if [ -f /etc/ansible/infrastructure.yml ]; then
      export infrastructure_config_yaml_path="/etc/ansible/infrastructure.yml"
    fi
  fi

  perform_setup_playbook_without_agent
}

function perform_setup_playbook() {
  if [ "${use_alpaca_agent}" = "true" ]; then
    perform_setup_playbook_with_agent
  else
    perform_setup_playbook_without_agent
  fi
}

notify_when_done=1
branch="master"

while [ $# -gt 0 ]; do
	case $1 in
    --ip)                              ip="$2"; shift;;
    --size)                            size="$2"; shift;;
    --hostname)                        hostname="$2"; shift;;
    --branch)                          branch="$2"; shift;;
    --repository)                      repository="$2"; shift;;
    --playbook)                        playbook="$2"; shift;;
    --steps)                           steps="$2"; shift;;
    --tftp_server_ip)                  tftp_server_ip="$2"; shift;;
    --use_alpaca_agent)                use_alpaca_agent="$2"; shift;;
    --telegram_chat_id)                telegram_chat_id="$2"; shift;;
    --telegram_bot_token)              telegram_bot_token="$2"; shift;;
    --infrastructure_yaml)             infrastructure_config_yaml_path="$2"; shift;;
		(--) 		shift; break;;
		(*) 		error "unrecognized option $1";;
		(*)		  error "unsupport command $1";;
	esac
	shift
done

trap cleanup EXIT

if [ -f /etc/running ]; then
  exit 0
fi

# Execute steps
IFS=';' read -r -a step_array <<< "$steps"

for step in "${step_array[@]}"; do
  if [[ -n "$step" ]]; then
    echo "Executing step: $step"

    if ! "$step"; then
      error "Step '$step' failed to execute"
    fi
  fi
done
