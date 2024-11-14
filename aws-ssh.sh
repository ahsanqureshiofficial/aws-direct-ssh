#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Function to detect OS
detect_os() {
    log "Detecting operating system..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
        OS_ID=$ID
    else
        error "Unable to detect operating system"
    fi
    log "Detected: $OS_NAME $OS_VERSION"
}

# Function to backup SSH config
backup_ssh_config() {
    local config_path="/etc/ssh/sshd_config"
    local backup_path="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_path" "$backup_path" || error "Failed to create backup of sshd_config"
    log "Created backup of sshd_config at $backup_path"
}

# Function to verify SSH config
verify_ssh_config() {
    log "Verifying SSH configuration..."
    if command -v sshd >/dev/null; then
        sshd -t || error "SSH configuration test failed"
        log "SSH configuration verified successfully"
    else
        error "SSH server (sshd) not found"
    fi
}

# Function to restart SSH service
restart_ssh() {
    log "Restarting SSH service..."
    if [ "$OS_ID" = "ubuntu" ] || [ "$OS_ID" = "debian" ]; then
        systemctl restart ssh || service ssh restart || error "Failed to restart SSH service"
    else
        systemctl restart sshd || service sshd restart || error "Failed to restart SSH service"
    fi
    log "SSH service restarted successfully"
}

# Function to configure SSH
enable_password_auth() {
    log "Configuring SSH with specified settings..."
    
    backup_ssh_config
    
    local config_path="/etc/ssh/sshd_config"
    
    # Backup and clear existing settings
    cp "$config_path" "${config_path}.bak"
    
    # Write new configuration
    cat > "$config_path" << 'EOF'
# SSH Configuration
Port 22
Protocol 2

# Authentication settings
PermitRootLogin yes
PasswordAuthentication yes
UsePAM no
ChallengeResponseAuthentication no

# Environment settings
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*

# Subsystem
Subsystem sftp /usr/lib/openssh/sftp-server

# Connection settings
ClientAliveInterval 120
ClientAliveCountMax 720
MaxAuthTries 6
MaxSessions 10
LoginGraceTime 120
StrictModes yes
PidFile /run/sshd/sshd.pid
EOF

    chmod 644 "$config_path"
    log "SSH configuration updated successfully"
}

# Function to show firewall info
show_firewall_info() {
    log "Checking firewall status..."
    if command -v ufw >/dev/null; then
        ufw status | grep "22"
    elif command -v firewall-cmd >/dev/null; then
        firewall-cmd --list-ports | grep "22"
    fi
}

# Function to set user password
set_user_password() {
    read -p "Enter username to set password for: " username
    if id "$username" >/dev/null 2>&1; then
        passwd "$username"
    else
        error "User $username does not exist"
    fi
}

# Main execution
main() {
    log "Starting SSH Configuration with specified settings..."
    
    detect_os
    enable_password_auth
    verify_ssh_config
    restart_ssh
    
    log "SSH has been configured with the specified settings"
    
    read -p "Would you like to set a password for a user? (y/n): " set_pass
    case $set_pass in
        [Yy]*)
            set_user_password
            ;;
    esac
    
    show_firewall_info
    
    log "Configuration complete! Settings applied:"
    log "1. Root login enabled with password"
    log "2. Password authentication enabled"
    log "3. PAM authentication disabled"
    log "4. Challenge-Response authentication disabled"
    
    warning "Important Security Notes:"
    warning "1. Root login with password is enabled - ensure strong passwords"
    warning "2. PAM authentication is disabled as requested"
    warning "3. Test new login method before closing this session"
    
    # Display IP information
    info "System IP Addresses:"
    hostname -I
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run as root or with sudo privileges"
fi

# Run main function
main
