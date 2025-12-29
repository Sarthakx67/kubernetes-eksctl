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