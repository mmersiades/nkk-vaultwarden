## Installation

The setup mostly follows this guide: https://tonyteaches.tech/self-host-vaultwarden/

### 1. Create an Ubuntu VPS

### 2. Add DNS A record for your domain

- Recommended subdomain: `vault`
    - `vault.your-domain.com`
- Use the IP address assigned to your VPS

### 3. Create a Linux user (`warden`) and update server

- `ssh root@vault.your-domain.com`
- `apt update && apt upgrade`
- `adduser warden`
- `usermod -aG sudo warden`
- `su - warden`

### 4. Install Docker

- `curl -fsSL https://get.docker.com -o get-docker.sh`
- `sudo sh get-docker.sh`
- `sudo usermod -aG docker warden`
- `exit`
- `su - warden`
- `sudo apt install docker-compose -y`

### 5. Create a directory for Vaultwarden

- `mkdir ~/vaultwarden`

### 6. Upload files to VPS

- First, make sure the .env.prod exists, and it is correctly populated. See .env.example
- You'll also need to set up an SSH key to SSH into the VPS.
- `scp .env.prod Caddyfile compose.yml listen_backup.sh warden@vault.your-domain.com:~/vaultwarden`

### 7. Secure Your VPS with UFW

- `sudo ufw allow OpenSSH`
- `sudo ufw allow http`
- `sudo ufw allow https`
- `sudo ufw enable`
- `sudo ufw status verbose`

### 8. Create first user

- Visit `https://vault.your-domain.com` in your browser
- Create a new user

### 9. Disable public signups

Update `.env.prod`

```.env
SIGNUPS_ALLOWED=false
```

and re-upload and then restart the Docker services.

### 10. Complete configuration

Update `.env.prod` to set the configuration you want. Keys to pain particular attention to:

- ORG_ATTACHMENT_LIMIT
- USER_ATTACHMENT_LIMIT
- USER_SEND_LIMIT
- SMTP_HOST
- SMTP_FROM
- SMTP_FROM_NAME
- SMTP_USERNAME
- SMTP_PASSWORD
- SMTP_SECURITY
- SMTP_PORT

### 11. Set up SSH keys and improve security

- Make changes to the Ubuntu security config to prohibit password authentication (use ssh keys instead) and disable root
  login.

### 12. Set up backup notifications

The `vaultwarden-backup` Docker container will create daily backups of your Vaultwarden database (Change CRON_TIME to
change the cron job). In this section, you can set up a notifier service that will send an email with each new backup.

#### 12.1 Create a .muttrc file

Create a git-ignored file called `.muttrc` in the project root directory. Base it on `.muttrc.example` and complete it
with your SMTP provider details.

#### 12.2 Upload files

- `scp .muttrc etc/systemd/system/vaultwarden-backup-notifier.service warden@vault.neonkingkong.com:~`

#### 12.3 Install apps

- `sudo apt install inotify-tools`
- `sudo apt install mutt`

#### 12.4 Test mutt configuration

- `echo "This is a test email from Mutt using SMTP2Go" | mutt -s "SMTP2Go Test" -- your-recipient@email.com`

#### 12.5 Move the service file to systemd

- `sudo mv ~/vaultwarden-backup-notifier.service /etc/systemd/system/`

#### 12.6 Modify file permissions

- `sudo chmod 644 /etc/systemd/system/vaultwarden-backup-notifier.service`
- `chmod +x listen_backup.sh`
- `sudo systemctl daemon-reload`

#### 12.7 Enable and start the service

- `sudo systemctl enable vaultwarden-backup-notifier.service`
- `sudo systemctl start vaultwarden-backup-notifier.service`

