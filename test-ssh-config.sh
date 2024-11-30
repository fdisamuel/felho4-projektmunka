#!/bin/bash

# Extract values from terraform vars file
MASTER_NAME=$(grep 'name = ".*-master"' terraform_openstack/resources.auto.tfvars | cut -d'"' -f2)
WORKER_NAME=$(grep 'name = ".*-worker"' terraform_openstack/resources.auto.tfvars | cut -d'"' -f2)
KEY_PAIR=$(grep 'key_pair = ' terraform_openstack/resources.auto.tfvars | cut -d'"' -f2)
PUBLIC_IP=$(grep 'floating_ip = ' terraform_openstack/resources.auto.tfvars | cut -d'"' -f2)

# Get worker IPs from kubectl
WORKER_IPS=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')

# Run ansible playbook in check mode (dry-run)
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --check -v -u root -i "${PUBLIC_IP}," kubernetes_master.yaml \
--extra-vars "\
nodeIp=${WORKER_IPS// /,} \
publicIp=${PUBLIC_IP} \
kubernetes_master_node='{\"name\":\"${MASTER_NAME}\",\"key_pair\":\"${KEY_PAIR}\"}' \
kubernetes_worker_node='{\"name\":\"${WORKER_NAME}\",\"key_pair\":\"${KEY_PAIR}\"}'"

echo "Dry run complete. No changes were made."