#!/bin/bash

# --- Configuration ---
LOGSDIR=/tmp
SCRIPT_NAME=$(basename "$0")
DATE=$(date +%F)
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

# Detect the actual user (even when running with sudo)
REAL_USER=${SUDO_USER:-$USER}
USERID=$(id -u)

# --- Validation Function ---
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

echo -e "$Y Starting Setup on Amazon Linux 2023... $N"

if [[ "$USERID" -ne 0 ]]; then
    echo -e "$R ERROR:: Please run this script with root access (sudo) $N"
    exit 1
fi

# 1. System Updates & Basics
dnf update -y &>>$LOGFILE
VALIDATE $? "System Update"
dnf install -y yum-utils git tar gzip &>>$LOGFILE
VALIDATE $? "Installed git, tar, gzip"

# 2. Docker Setup
dnf install -y docker &>>$LOGFILE
VALIDATE $? "Docker Installed"
systemctl start docker &>>$LOGFILE
VALIDATE $? "Docker Started"
systemctl enable docker &>>$LOGFILE
VALIDATE $? "Docker Enabled"
usermod -aG docker "$REAL_USER" &>>$LOGFILE
VALIDATE $? "Added $REAL_USER to docker group"

# 3. Dynamic Architecture Detection (for eksctl/kubectl)
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then 
    PLATFORM="amd64"
elif [ "$ARCH" = "aarch64" ]; then 
    PLATFORM="arm64"
else
    PLATFORM="amd64" # Default fallback
fi
echo -e "$Y Detected Architecture: $PLATFORM $N"

# 4. Install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_$PLATFORM.tar.gz"
tar -xzf "eksctl_$(uname -s)_$PLATFORM.tar.gz" -C /tmp && rm "eksctl_$(uname -s)_$PLATFORM.tar.gz"
install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl
VALIDATE $? "eksctl Installed ($PLATFORM)"

# 5. Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$PLATFORM/kubectl" &>>$LOGFILE
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &>>$LOGFILE
rm kubectl
VALIDATE $? "kubectl Installed ($PLATFORM)"

# 6. Install kubens (kubectx)
if [ ! -d "/opt/kubectx" ]; then
    git clone https://github.com/ahmetb/kubectx /opt/kubectx &>>$LOGFILE
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens &>>$LOGFILE
    VALIDATE $? "kubens Installed"
else
    echo -e "kubens already exists ... $Y SKIPPING $N"
fi

# 7. Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 &>>$LOGFILE
chmod 700 get_helm.sh
./get_helm.sh &>>$LOGFILE
rm get_helm.sh
VALIDATE $? "Helm Installed"

echo -e "$G Setup Complete! Please LOG OUT and log back in to use Docker. $N"