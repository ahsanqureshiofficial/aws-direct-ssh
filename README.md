# Universal SSH Configuration Script

This script provides automated configuration of SSH settings across different Linux distributions, with a focus on enabling password authentication and root login capabilities.

## 🚨 Security Notice

This script modifies SSH security settings to enable password authentication and root login. While this can be useful in specific scenarios, please understand the security implications:

- Enables root login with password
- Enables password authentication
- Disables PAM authentication
- Makes several other security-related changes

**Use this script only in environments where these settings are appropriate and necessary.**

## 🚀 Quick Start
- Run this command directly on your VPS logged in as root.

```bash
apt-get update && apt-get install -y dos2unix && wget https://raw.githubusercontent.com/ahsanqureshiofficial/aws-direct-ssh/refs/heads/main/aws-ssh.sh && dos2unix aws-ssh.sh && chmod +x aws-ssh.sh && ./aws-ssh.sh
```

## ✨ Features

- Automated SSH configuration
- Cross-distribution support (Ubuntu, Debian, CentOS, RHEL)
- Backup of existing SSH configuration
- User password management
- Firewall status checking
- System IP address display

## 📋 Configuration Changes

The script makes the following changes to `/etc/ssh/sshd_config`:

```bash
# Authentication settings
PermitRootLogin yes
PasswordAuthentication yes
UsePAM no
ChallengeResponseAuthentication no

# Environment settings
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*

# Connection settings
ClientAliveInterval 120
ClientAliveCountMax 720
MaxAuthTries 6
MaxSessions 10
LoginGraceTime 120
```

## 🔧 Usage

1. Run the script:
```bash
apt-get update && apt-get install -y dos2unix
wget https://raw.githubusercontent.com/ahsanqureshiofficial/aws-direct-ssh/refs/heads/main/aws-ssh.sh
dos2unix aws-ssh.sh
chmod +x aws-ssh.sh
./aws-ssh.sh
```

2. Follow the prompts to:
   - Confirm configuration changes
   - Set user passwords if desired
   - View firewall status
   - See system IP addresses

3. Test the new configuration:
```bash
# Test SSH login with password
ssh username@your_server_ip
```

## 🛡️ Security Recommendations

If you use this script, consider implementing these additional security measures:

1. Use very strong passwords
2. Implement fail2ban
3. Configure firewall rules to limit SSH access
4. Consider setting up SSH key authentication as a backup
5. Regularly monitor SSH login attempts
6. Keep your system and SSH updated

## 📝 Requirements

- Root or sudo privileges
- Linux-based operating system
- SSH server installed
- Basic system utilities (systemctl or service)

## 🔍 Troubleshooting

### Common Issues

1. **Service Restart Failed**
```bash
# Check SSH service status
sudo systemctl status ssh    # For Ubuntu/Debian
```

2. **Configuration Test Failed**
```bash
# Test SSH configuration
sudo sshd -t
```

3. **Permission Denied**
```bash
# Check script permissions
ls -l aws-ssh.sh
# Should show: -rwxr-xr-x
```

## 💡 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## ⚖️ License

MIT License - feel free to use and modify as needed.

## 🤝 Support

For support, please:
1. Check existing issues
2. Create a new issue with detailed information
3. Provide logs and system information

## ✨ Acknowledgments

- Original SSH configuration guidelines from OpenSSH documentation
- Security recommendations from various cybersecurity resources
- Community feedback and contributions

---
⚠️ **Disclaimer**: This script modifies security-sensitive settings. Use at your own risk and only in appropriate environments.
