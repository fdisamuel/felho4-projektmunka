# Féléves Projektmunka Kódbázis

Ez a repó a féléves projektmunkához felhasznált kódbázist tartalmazza. A projekt célja az OpenStack alapú Kubernetes klaszter beállítása és menedzselése különböző automatizált eszközökkel, mint például Ansible és Terraform.

## Fájlok és céljuk

- `roles/kubernetes_master/tasks/main.yaml`: Feladatok a Kubernetes master node beállításához és konfigurálásához.
- `roles/kubernetes_setup/tasks/main.yaml`: Általános beállítási feladatok a Kubernetes klaszterhez.
- `roles/kubernetes_worker/tasks/main.yaml`: Feladatok a Kubernetes worker node-ok csatlakoztatásához a klaszterhez.
- `terraform_openstack/main.tf`: Terraform konfiguráció az OpenStack infrastruktúra beállításához.
- `terraform_openstack/variables.tf`: Változók definiálása a Terraform konfigurációhoz.
- `terraform_openstack/resources.auto.tfvars`: Felhasználó által beállítandó változók a Terraform+Ansible futtatásához.
- `ubuntu-container-test/`: felépített Rook Ceph adattárolási megoldás teszteléséhez manifest fájlok
- `kubernetes_master.yaml`: Ansible playbook a Kubernetes master node beállításához.
- `kubernetes_worker.yaml`: Ansible playbook a Kubernetes worker node-ok beállításához.