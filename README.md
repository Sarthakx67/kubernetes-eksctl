# EKS Cluster Setup using eksctl

This repository contains the configuration and setup scripts to provision an Amazon EKS (Elastic Kubernetes Service) cluster using the `eksctl` command-line tool. It includes an automated bootstrap script to prepare your workstation on **Amazon Linux 2023**.

## Architecture
![Architecture Diagram](./images/eksctl.png)

## 1. Workstation Setup
To interact with the EKS cluster, we need a workstation (EC2 instance) configured with the necessary tools.

**Prerequisites:**
* AWS Account with appropriate permissions.
* **EC2 Instance:** Launch an instance using the **Amazon Linux 2023** AMI (e.g., `t3.micro` or `t2.micro` is sufficient for the workstation itself).
* **Security Group:** Allow SSH (Port 22) from your IP.

### Installation Steps
1.  Connect to your Amazon Linux 2023 instance via SSH.
2.  Clone this repository or copy the `workstation.sh` script.
3.  Run the setup script with root privileges. This script automatically installs:
    * Docker (and adds the current user to the docker group)
    * kubectl
    * eksctl
    * kubens (kubectx)
    * Helm
    * Git

```bash
sudo sh workstation.sh

3. We are using Default VPC with allow-all security group.
4. Configure AWS. this EC2 instance should have access to provision EKS cluster.
```
aws configure
```

### EKS
EKS is AWS kubernetes service. EKS is the master node completely managed by AWS. We can't have SSH access to it.

* We are going to use EKS managed node group, means we no need to worry about installations, underlying OS, etc.
* We are using spot instances to reduce the bill.
* Create one key-pair and import public key into AWS.

```
eksctl create cluster --config-file=eks.yaml
```