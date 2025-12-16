#!/bin/bash
# setup_vm_AbayK.sh - Linux VM Setup Script
# Author: AbayK
# Description: Initial setup script for Linux VM (Ubuntu 20.04+/22.04+)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

LOG_FILE="/var/log/devops-setup.log"

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run this script as root (sudo)"
fi

log "Starting DevOps VM Setup..."

# =============================================================================
# 1. Update Operating System
# =============================================================================
log "Updating operating system..."
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

# =============================================================================
# 2. Install Required Packages
# =============================================================================
log "Installing required packages..."
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# =============================================================================
# 3. Install Java 17
# =============================================================================
log "Installing Java 17..."
apt-get install -y openjdk-17-jdk

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /etc/environment
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/environment

# =============================================================================
# 4. Install Gradle
# =============================================================================
log "Installing Gradle..."
GRADLE_VERSION="8.5"
wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O /tmp/gradle.zip
unzip -q /tmp/gradle.zip -d /opt
ln -sf /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
rm /tmp/gradle.zip

# =============================================================================
# 5. Install Git (already installed, but ensure latest)
# =============================================================================
log "Ensuring Git is up to date..."
apt-get install -y git

# =============================================================================
# 6. Create Directory Structure
# =============================================================================
log "Creating directory structure..."
mkdir -p /opt/devops-project/{app,docker,k8s,ansible,scripts}
chown -R $SUDO_USER:$SUDO_USER /opt/devops-project

# =============================================================================
# 7. Configure SSH (disable password authentication)
# =============================================================================
log "Configuring SSH..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# =============================================================================
# 8. Configure UFW Firewall
# =============================================================================
log "Configuring UFW Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 8080/tcp  # Jenkins / Application
ufw allow 30080/tcp # Kubernetes NodePort
echo "y" | ufw enable

# =============================================================================
# 9. Verify Installations
# =============================================================================
log "Verifying installations..."

echo "============================================" >> $LOG_FILE
echo "Installation Verification Report" >> $LOG_FILE
echo "Date: $(date)" >> $LOG_FILE
echo "============================================" >> $LOG_FILE

echo "Java Version:" >> $LOG_FILE
java -version 2>&1 | tee -a $LOG_FILE

echo "" >> $LOG_FILE
echo "Gradle Version:" >> $LOG_FILE
gradle --version 2>&1 | tee -a $LOG_FILE

echo "" >> $LOG_FILE
echo "Git Version:" >> $LOG_FILE
git --version 2>&1 | tee -a $LOG_FILE

echo "" >> $LOG_FILE
echo "UFW Status:" >> $LOG_FILE
ufw status verbose 2>&1 | tee -a $LOG_FILE

echo "============================================" >> $LOG_FILE

log "Setup completed successfully!"
log "Log file saved to: $LOG_FILE"
log "Please reboot the system to apply all changes."
