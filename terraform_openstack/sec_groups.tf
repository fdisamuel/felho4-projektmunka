resource "openstack_networking_secgroup_v2" "terraform_kubernetes_master" {
  name        = "terraform_kubernetes_master"
  description = "Created by Terraform. Do not use or manage manually."
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_master.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_x" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_master.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_master.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_master.id
}

resource "openstack_networking_secgroup_v2" "terraform_kubernetes_all" {
  name        = "terraform_kubernetes_all"
  description = "Created by Terraform. Do not use or manage manually."
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = var.kubernetes_network.network_subnet_range
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_all.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = var.kubernetes_network.network_subnet_range
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_all.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.kubernetes_network.network_subnet_range
  security_group_id = openstack_networking_secgroup_v2.terraform_kubernetes_all.id
}