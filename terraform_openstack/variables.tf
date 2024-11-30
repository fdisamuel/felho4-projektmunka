variable "auth_data" {
  type = object({
    credential_id = string
    credential_secret = string
    auth_url = string
  })
  sensitive = true
}

variable "kubernetes_master_node" {
  type = object({
    name = string
    flavor_name = string
    image_id = string
    key_pair = string
    floating_ip = string
    boot_volume_size = number
    data_volume_size = number
})
}

variable "kubernetes_worker_node" {
  type = object({
    name = string
    count = number
    flavor_name = string
    image_id = string
    key_pair = string
    boot_volume_size = number
    data_volume_size = number
})
}

variable "kubernetes_network" {
  type = object({
    name = string
    network_subnet_range = string
})
}

variable "software_version" {
  type = object({
    k3s_version = string
    containerd_version = string
})
}

variable "user_config" {
  type = object({
    container_network_interface = string
    allow_pods_on_master = bool
    install_prometheus_stack = bool
})
}

variable "hunren_cloud_config" {
  type = object({
    hunren_cloud_site = string
})
}