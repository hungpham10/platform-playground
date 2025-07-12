#!/bin/bash

######################################################################
# @author      : Hung Nguyen Xuan Pham (hung0913208@gmail.com)
# @file        : generic
# @created     : Saturday May 20, 2023 21:40:34 +07
#
# @description : generic boot script
######################################################################


export TELEGRAM_BOT_TOKEN=${telegram_bot_token}
export ENDPOINT="${redis_endpoint}"

if ! apt install -y git; then
  curl -X POST                                                                                                                                                        \
       -H "Content-Type: application/json"                                                                                                                            \
       -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"${domain}: Fail apt install, ip ${ip}\", \"disable_notification\": false}"                              \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
  exit 1
fi
if [ ! -d /tmp/playbook ]; then
  if ! git clone --branch ${branch} ${repository} /tmp/playbook; then
    curl -X POST                                                                                                                                                      \
         -H "Content-Type: application/json"                                                                                                                          \
         -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"${domain}: ${hostname} fail fetching ${repository}, ip ${ip}\", \"disable_notification\": false}"     \
          https://api.telegram.org/bot${telegram_bot_token}/sendMessage
    exit 255
  fi
fi

if ! apt install -y redis-tools; then
  curl -X POST                                                                                                                                                        \
       -H "Content-Type: application/json"                                                                                                                            \
       -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"${domain}: Fail apt install redis-tools, ip ${ip}\", \"disable_notification\": false}"                  \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
  exit 1
fi

source /tmp/playbook/kubernetes/scripts/redis.sh
source /tmp/playbook/kubernetes/scripts/yaml.sh

if ! redis_lock "${domain}-${node_type}" "${commit}"; then
  curl -X POST                                                                                                                                                        \
       -H "Content-Type: application/json"                                                                                                                            \
       -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"${domain}: Fail locking ${domain}-${node_type}, ip ${ip}\", \"disable_notification\": false}"           \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
  exit 1
fi

inet=$(parse_yaml sample.yml | grep ${gateway} | awk '{ split($0,a,"__"); print a[3] }' | head -1)
if [[ ${#inet} -eq 0 ]]; then
  exit -1
fi

redis_set_key "${domain}-${node_type}-${id}" $(ip -f inet addr show $inet | grep -Po 'inet \K[\d.]+')

if [[ "${hostname}" -eq "vm-${node_type}-${size}" ]]; then
  for i in $(seq ${size}); do
    cnt=0

    while ! redis_get_key "${domain}-${node_type}-$i" &> /dev/null; do
      cnt=$((cnt+1))

      if [[ $cnt -gt 30 ]]; then
        curl -X POST                                                                                                                                                  \
             -H "Content-Type: application/json"                                                                                                                      \
             -d "{\"chat_id\": \"${telegram_chat_id}\", \"text\": \"${domain}: Fail waiting ${domain}-${node_type}-$i, ip ${ip}\", \"disable_notification\": false}"  \
              https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
        redis_unlock "${domain}-${node_type}" "${commit}"
        exit 1
      fi

      sleep 10
    done

    sed -i -e "s/<$i>/$(redis_get_key "${domain}-${node_type}-$i")/g" /tmp/hosts
  done

  while ! redis_unlock "${domain}-${node_type}" "${commit}"; do
    sleep 10
  done
fi

%{ if node_type == "vault" }
/tmp/playbook/kubernetes/scripts/boot/hybrid.sh --ip "${ip}"                      \
          --enable_vault 1                                                        \
          --size       ${size}                                                    \
          --domain    "${domain}"                                                 \
          --username  "${username}"                                               \
          --playbook  "${playbook}"                                               \
          --hostname  "${hostname}"                                               \
          --provision  ${monitor}                                                 \
          --node_type "${node_type}"                                              \
          --telegram_chat_id "${telegram_chat_id}"                                \
          --telegram_bot_token "${telegram_bot_token}"                            \
          --ansible_extra_vars "${ansible_extra_vars}"                            \
          --ansible_config_yaml_path "${ansible_config_yaml_path}"                \
          --infrastructure_config_yaml_path "${infrastructure_config_yaml_path}"
%{ endif }
%{ if node_type == "kong" }
/tmp/playbook/kubernetes/scripts/boot/hybrid.sh --ip "${ip}"                      \
          --enable_kong 1                                                         \
          --size       ${size}                                                    \
          --domain    "${domain}"                                                 \
          --username  "${username}"                                               \
          --playbook  "${playbook}"                                               \
          --hostname  "${hostname}"                                               \
          --provision  ${monitor}                                                 \
          --node_type "${node_type}"                                              \
          --telegram_chat_id "${telegram_chat_id}"                                \
          --telegram_bot_token "${telegram_bot_token}"                            \
          --ansible_extra_vars "${ansible_extra_vars}"                            \
          --ansible_config_yaml_path "${ansible_config_yaml_path}"                \
          --infrastructure_config_yaml_path "${infrastructure_config_yaml_path}"
%{ endif }
%{ if node_type == "proxysql" }
/tmp/playbook/kubernetes/scripts/boot/hybrid.sh --ip "${ip}"                      \
          --enable_proxysql 1                                                     \
          --size       ${size}                                                    \
          --domain    "${domain}"                                                 \
          --username  "${username}"                                               \
          --playbook  "${playbook}"                                               \
          --hostname  "${hostname}"                                               \
          --provision  ${monitor}                                                 \
          --node_type "${node_type}"                                              \
          --telegram_chat_id "${telegram_chat_id}"                                \
          --telegram_bot_token "${telegram_bot_token}"                            \
          --ansible_extra_vars "${ansible_extra_vars}"                            \
          --ansible_config_yaml_path "${ansible_config_yaml_path}"                \
          --infrastructure_config_yaml_path "${infrastructure_config_yaml_path}"
%{ endif }

if [[ "${hostname}" -ne "vm-${node_type}-{cluster_size}" ]]; then
  while ! redis_unset "${domain}-${node_type}-${id}"; do
    sleep 10
  done
fi
