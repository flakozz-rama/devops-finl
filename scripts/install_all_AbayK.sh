#!/bin/bash
# install_all_AbayK.sh - Complete DevOps Stack Installation
# Author: AbayK
# Description: Installs Docker, Jenkins, Minikube, kubectl, and Ansible

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

if [ "$EUID" -ne 0 ]; then
    error "Please run as root: sudo $0"
fi

REAL_USER=${SUDO_USER:-$USER}

log "=========================================="
log "   DevOps Stack Installation - AbayK"
log "=========================================="

# =============================================================================
# 1. Update System
# =============================================================================
log "Updating system packages..."
apt-get update -y && apt-get upgrade -y

# =============================================================================
# 2. Install Docker (if not installed)
# =============================================================================
if ! command -v docker &> /dev/null; then
    log "Installing Docker..."
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    usermod -aG docker $REAL_USER
    log "Docker installed successfully"
else
    log "Docker already installed"
fi

# =============================================================================
# 3. Install Ansible
# =============================================================================
if ! command -v ansible &> /dev/null; then
    log "Installing Ansible..."
    apt-get install -y ansible
    log "Ansible installed successfully"
else
    log "Ansible already installed"
fi

# =============================================================================
# 4. Install Jenkins
# =============================================================================
if ! command -v jenkins &> /dev/null && ! systemctl list-units --type=service | grep -q jenkins; then
    log "Installing Jenkins..."
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update -y
    apt-get install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins
    log "Jenkins installed successfully"
    log "Jenkins initial password: $(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo 'Starting up...')"
else
    log "Jenkins already installed"
fi

# =============================================================================
# 5. Install kubectl
# =============================================================================
if ! command -v kubectl &> /dev/null; then
    log "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    log "kubectl installed successfully"
else
    log "kubectl already installed"
fi

# =============================================================================
# 6. Install Minikube
# =============================================================================
if ! command -v minikube &> /dev/null; then
    log "Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-$(dpkg --print-architecture)
    install minikube-linux-$(dpkg --print-architecture) /usr/local/bin/minikube
    rm minikube-linux-$(dpkg --print-architecture)
    log "Minikube installed successfully"
else
    log "Minikube already installed"
fi

# =============================================================================
# 7. Verify Installations
# =============================================================================
log "=========================================="
log "   Installation Complete!"
log "=========================================="
echo ""
log "Versions installed:"
echo "  Docker:    $(docker --version 2>/dev/null || echo 'not found')"
echo "  Ansible:   $(ansible --version 2>/dev/null | head -1 || echo 'not found')"
echo "  Jenkins:   $(systemctl is-active jenkins 2>/dev/null || echo 'not running')"
echo "  kubectl:   $(kubectl version --client --short 2>/dev/null || echo 'not found')"
echo "  Minikube:  $(minikube version --short 2>/dev/null || echo 'not found')"
echo ""
log "=========================================="
log "   Next Steps:"
log "=========================================="
echo "  1. Logout and login (or run: newgrp docker)"
echo "  2. Access Jenkins: http://$(hostname -I | awk '{print $1}'):8080"
echo "  3. Get Jenkins password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "  4. Start Minikube: minikube start --driver=docker"
echo ""
