Assumption:
----------
1. You already have AWS account and agreed to deploy resources in default vpc

Steps:
-----
1. Installed AWS CLI via MSI
2. Configured aws configure
3. Installed terraform
4. Installed WSL, Followed by Ubuntu on my win laptop. Then installed Ansible on laptop. 


# Kubernetes Cluster on AWS EC2 (Terraform + Ansible)

This repository provisions and bootstraps a **Kubernetes cluster on AWS EC2** using:

- **Terraform** – Infrastructure provisioning
- **Ansible** – OS & Kubernetes configuration
- **kubeadm** – Kubernetes bootstrap
- **containerd** – Container runtime
- **Calico** – CNI networking

The setup creates:
- **1 Control Plane node**
- **2 Worker nodes**
- Deployed into the **default AWS VPC** (fast path)

This project is suitable for:
- Learning Kubernetes (CKA / CKS prep)
- Platform engineering practice
- Kubernetes bootstrap automation
- Non-production / lab environments

---

## Architecture Overview

```

AWS (Default VPC)
│
├── EC2: Control Plane
│   ├── kube-apiserver
│   ├── etcd
│   ├── controller-manager
│   └── scheduler
│
├── EC2: Worker 1
│   └── kubelet + containerd
│
└── EC2: Worker 2
└── kubelet + containerd

```

Networking:
- Pod CIDR: `192.168.0.0/16`
- CNI: **Calico (Tigera Operator)**

---

## Repository Structure

```

k8s-prod/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── userdata.sh
│
├── ansible/
│   ├── inventory.ini
│   ├── site.yml
│   └── roles/
│       ├── common/
│       ├── containerd/
│       ├── k8s/
│       ├── control-plane/
│       ├── worker/
│       └── calico/
│
└── README.md

````

---

## Prerequisites

### Local Machine
- Terraform >= 1.5
- Ansible >= 2.15
- AWS CLI v2
- SSH client

### AWS
- AWS account
- IAM user with permissions:
  - `AmazonEC2FullAccess`
  - `IAMReadOnlyAccess`
- Default VPC available in target region

---

## AWS CLI Configuration

Configure AWS CLI before running Terraform:

```bash
aws configure
````

Verify access:

```bash
aws sts get-caller-identity
```

---

## Terraform: Infrastructure Provisioning

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Validate

```bash
terraform validate
```

### 3. Plan

```bash
terraform plan
```

### 4. Apply

```bash
terraform apply
```

Terraform will create:

* EC2 instances (1 control plane, 2 workers)
* Security group
* SSH key association

---

## Ansible: Kubernetes Bootstrap

### 1. Create Inventory

After Terraform apply, note the outputs and update:

```ini
[control_plane]
cp ansible_host=<CONTROL_PLANE_IP>

[workers]
worker1 ansible_host=<WORKER_IP_1>
worker2 ansible_host=<WORKER_IP_2>

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=C:/Users/<USERNAME>/.ssh/k8s
```

### 2. Test Connectivity

```bash
cd ansible
ansible -i inventory.ini all -m ping
```

### 3. Run Playbook

```bash
ansible-playbook -i inventory.ini site.yml
```

This will:

1. Prepare OS (swap, sysctl)
2. Install and configure containerd
3. Install kubeadm, kubelet, kubectl
4. Initialize control plane
5. Join worker nodes
6. Install Calico CNI

---

## Cluster Validation

SSH into the control plane node:

```bash
kubectl get nodes
kubectl get pods -A
```

Expected:

* All nodes in `Ready` state
* Calico pods running

Test pod networking:

```bash
kubectl run nginx --image=nginx
kubectl get pod -o wide
```

---

## Known Design Decisions

* **Default VPC** is used (fast path)
* **Single control plane** (non-HA)
* **Server-side apply** used for Calico to avoid CRD size limits
* SSH-based Ansible execution (no SSM)

---

## Limitations

* Not production hardened
* No HA control plane
* Publicly reachable EC2 instances
* No Ingress controller
* No persistent storage (CSI)

---

## Possible Enhancements

* Custom VPC with private subnets
* HA control plane
* IAM Roles for Service Accounts (IRSA)
* OIDC / Pinniped authentication
* Ingress controller (NGINX / ALB)
* GitOps (Argo CD / Flux)
* CIS hardening

---

## Cleanup

To destroy infrastructure:

```bash
cd terraform
terraform destroy
```

---

## Author Notes

This project demonstrates a **real-world Kubernetes bootstrap pipeline** using Terraform and Ansible, closely resembling how platform teams automate kubeadm-based clusters.

It is intentionally verbose and explicit to aid learning and troubleshooting.

---