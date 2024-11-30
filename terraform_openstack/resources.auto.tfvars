kubernetes_master_node = ({
    name = "foldis-k8s-master"
    flavor_name = "m2.large"
    image_id = "b2be6f4e-ebd8-42af-a526-63691a4d90ea"
    key_pair = "foldis-k8s"
    floating_ip = "193.225.251.69"
    boot_volume_size = 128
    data_volume_size = 256
})

kubernetes_worker_node = ({
    name = "foldis-k8s-worker"
    count = 3
    flavor_name = "m2.large"
    image_id = "b2be6f4e-ebd8-42af-a526-63691a4d90ea"
    key_pair = "foldis-k8s"
    boot_volume_size = 128
    data_volume_size = 256
})

kubernetes_network = ({
    name = "default"
    network_subnet_range = "192.168.0.0/24"
})

# User configuration options for customizing the provisioned cluster
#
# k3s_version: Set the version of kubernetes libraries. Changing the default version might cause issues.
# containerd_version: Set the version of containerd. Changing the default version might cause issues.
#
# container_network_interface: Choose which Container Network Interface (CNI) should be installed. Currently available options are 'flannel' (default) and 'calico'.
# allow_pods_on_master: Allow pods to be scheduled on the master node.
# enable_gpu: Enable the utilization of GPU resources on the nodes. NVIDIA GPUs are supported.
#             The image used for virtual machines must include NVIDIA drivers.
# install_prometheus_stack: Installs the kube-prometheus-stack helm chart for monitoring (For resource usage visualization in Lens).

software_version = ({
    k3s_version = "v1.31.2+k3s1"
    containerd_version = "1.6"
})

user_config = ({
    container_network_interface = "flannel"
    allow_pods_on_master = true
    install_prometheus_stack = true
})

# Configuration options for usage on HUN-REN Cloud
#
# hunren_cloud_site: Required for setting up site specific settings. Possible options are "sztaki" and "wigner".

hunren_cloud_config = ({
    hunren_cloud_site = "sztaki"
})
