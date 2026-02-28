## Installation

The setup mostly follows this guide: https://tonyteaches.tech/self-host-vaultwarden/

### 1. Create an Ubuntu VPS

### 2. Add DNS A record for your domain (`vault.neonkinkong.com)

- Recommended subdomain: `vault`
    - `vault.neonkingkong.com`
- Use the IP address assigned to your VPS

### 3. Create a Linux user (`warden`) and update server

- `ssh root@vault.neonkingkong.com`
- `apt update && apt upgrade`
- `adduser warden`
- `usermod -aG sudo warden`
- `su - warden`

### 3. Install Docker

- `curl -fsSL https://get.docker.com -o get-docker.sh`
- `sudo sh get-docker.sh`
- `sudo usermod -aG docker warden`
- `exit`
- `su - warden`
- `sudo apt install docker-compose -y`

### 4. Create a directory for Vaultwarden

- `mkdir ~/vaultwarden`

### 5. Upload files to VPS

- First, make sure the .env.prod exists, and it is correctly populated. See .env.example
- You'll also need to set up an SSH key to SSH into the VPS.
- `scp .env.prod Caddyfile compose.yml warden@vault.neonkingkong.com:~/vaultwarden`

### 6. Secure Your VPS with UFW

- `sudo ufw allow OpenSSH`
- `sudo ufw allow http`
- `sudo ufw allow https`
- `sudo ufw enable`
- `sudo ufw status verbose`

### 7. Create first user

- Visit `https://vault.neonkingkong.com` in your browser
- Create a new user

### 8. Disable public signups

Update `.env.prod`

```.env
SIGNUPS_ALLOWED=false
```

and re-upload and then restart the Docker services.

### 8. Complete configuration

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

### 9. Set up SSH keys and improve security

- Make changes to the Ubuntu security config to prohibit password authentication (use ssh keys instead) and disable root
  login.