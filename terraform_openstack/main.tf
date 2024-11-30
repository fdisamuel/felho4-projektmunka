terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.47.0"
    }
  }
}

provider "openstack" {
  application_credential_id = var.auth_data.credential_id
  application_credential_secret = var.auth_data.credential_secret
  auth_url    = var.auth_data.auth_url
  insecure = false
}

locals {
  # Address used to access Master node depending on whether floating IPs are used.
  master_ip = openstack_compute_floatingip_associate_v2.fip_1.0.floating_ip
  # Create a comma-separated list of worker IPs
  worker_ips = join(",", openstack_compute_instance_v2.kubernetes_workers[*].access_ip_v4)
}

resource "openstack_compute_instance_v2" "kubernetes_master" {
  name            = var.kubernetes_master_node.name
  flavor_name     = var.kubernetes_master_node.flavor_name
  key_pair        = var.kubernetes_master_node.key_pair
  security_groups = ["${openstack_networking_secgroup_v2.terraform_kubernetes_master.name}", "${openstack_networking_secgroup_v2.terraform_kubernetes_all.name}"]

  network {
    name = var.kubernetes_network.name
  }

  block_device {
    uuid                  = var.kubernetes_master_node.image_id
    source_type           = "image"
    volume_size           = var.kubernetes_master_node.boot_volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    volume_size           = var.kubernetes_master_node.data_volume_size
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  count       = 1
  floating_ip = var.kubernetes_master_node.floating_ip
  instance_id = openstack_compute_instance_v2.kubernetes_master.id
  fixed_ip    = openstack_compute_instance_v2.kubernetes_master.network.0.fixed_ip_v4
}

resource "null_resource" "kubernetes_master_config" {
  triggers = {
    master_instance_id = openstack_compute_instance_v2.kubernetes_master.id
  }

provisioner "local-exec" {
  working_dir = "./"
  command = <<EOF
              ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_RETRIES=10 \
              ansible-playbook -u root -i '${local.master_ip},' ../kubernetes_master.yaml \
              --extra-vars \
              'nodeIp=${openstack_compute_instance_v2.kubernetes_master.access_ip_v4} \
              kubeVersion=${var.software_version.k3s_version} \
              untaintMaster=${var.user_config.allow_pods_on_master} \
              installPrometheus=${var.user_config.install_prometheus_stack} \
              publicIp=${local.master_ip} \
              kubernetes_master_node='{\"name\":\"${var.kubernetes_master_node.name}\",\"key_pair\":\"${var.kubernetes_master_node.key_pair}\"}' \
              kubernetes_worker_node='{\"name\":\"${var.kubernetes_worker_node.name}\",\"key_pair\":\"${var.kubernetes_worker_node.key_pair}\"}' \
              workerIps=${local.worker_ips}'
  EOF
}

provisioner "local-exec" {
  when    = destroy
  command = "rm -rf ../join-command"
}
}

resource "openstack_compute_instance_v2" "kubernetes_workers" {
  name            = "${var.kubernetes_worker_node.name}-${count.index+1}"
  count           = var.kubernetes_worker_node.count
  flavor_name     = var.kubernetes_worker_node.flavor_name
  key_pair        = var.kubernetes_worker_node.key_pair
  security_groups = ["${openstack_networking_secgroup_v2.terraform_kubernetes_all.name}"]

  network {
    name = var.kubernetes_network.name
  }

  block_device {
    uuid                  = var.kubernetes_worker_node.image_id
    source_type           = "image"
    volume_size           = var.kubernetes_worker_node.boot_volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

   block_device {
    source_type           = "blank"
    volume_size           = var.kubernetes_worker_node.data_volume_size
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "null_resource" "kubernetes_worker_config" {
  count = var.kubernetes_worker_node.count
  triggers = {
    master_config_id = null_resource.kubernetes_master_config.id,
    worker_instance_ids = join(",", openstack_compute_instance_v2.kubernetes_workers.*.id)
  }

provisioner "local-exec" {
  working_dir = "./"
  command = <<EOF
              ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_RETRIES=10 \
              ansible-playbook -u root -i '${openstack_compute_instance_v2.kubernetes_workers[count.index].access_ip_v4},' ../kubernetes_worker.yaml \
              --extra-vars \
              'nodeIp=${openstack_compute_instance_v2.kubernetes_workers[count.index].access_ip_v4}' \
              --ssh-common-args '-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p \
              ubuntu@${local.master_ip}"'
  EOF
}

# Add cleanup provisioner that runs last
provisioner "local-exec" {
  command = "rm -f ../join-command"
}

depends_on = [
  null_resource.kubernetes_master_config,
]
}