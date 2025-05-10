# Aragog

**Automated Infrastructure for Secure Web Servers in Educational Environments**

**Aragog** is a system designed to reproducibly deploy a hardened virtual machine based on Ubuntu Pro, with secure web containers using Apache or Nginx. Its goal is to provide a training environment where each student has an isolated, personalized, and standards-compliant secure web server.

## Key Features

- **Automated system hardening** using the CIS Level 1 Server Benchmark profile via Ubuntu Security Guide (USG).
- **Active protection** with:
  - **Fail2Ban** for brute-force protection.
  - **PortSentry** for port scanning detection.
- **Per-student Docker-based web server isolation**, supporting:
  - Apache or Nginx.
  - ModSecurity activated in both.
  - OWASP Core Rule Set (CRS) in Nginx (Apache uses integrated rules).
  - Secure HTTP headers (CSP, X-Frame-Options, etc.).
- **Full automation** from VM creation to per-student web environment deployment.
- **Individual containerization** with custom ports and usernames for complete isolation.
- **Custom scripts** for user creation and permission repair.
- **Automatic HTML audit report** generated after provisioning.

## Project Structure

├── apache/ # Dockerfile and security config for Apache container
├── nginx/ # Dockerfile and security config for Nginx container
├── crear_alumno.sh # Main script to deploy student environments
├── reparar_permisos.sh # Script to fix file permissions
├── fail2ban/ # Custom Fail2Ban configuration
├── portsentry/ # Custom PortSentry configuration
├── provision.sh # Provisioning script (USG, Docker, hardening, etc.)
├── Vagrantfile # VM configuration using Ubuntu Pro
└── README.md # This file


## Requirements

- Linux (Ubuntu 20.04+ recommended)
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- Git (to clone the repository)

## Quick Start

```bash
git clone https://github.com/cuxonet/aragog.git
cd aragog
nano provision.sh  # Replace 'xxxxxxxxx' with your actual Ubuntu Pro token in the 'sudo pro attach' line
vagrant up
Once the provisioning process completes, you can create a secure container for a student by running:
vagrant ssh
sudo bash /vagrant/crear_alumno.sh
Follow the interactive prompts to select the server type (Apache or Nginx) and enter the student's credentials. Each student will receive:

    A secure Docker container.

    An isolated port.

    A dedicated Linux user account.

    A personal folder to deploy web content.


# To perform a quick test with a student's container:
sudo su - STUDENT_ID
echo '<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Welcome</title></head>
<body><h1>Welcome to Aragog</h1></body>
</html>' > index.html
./reparar_permisos.sh

# Now you're ready — open your browser and visit the IP and port assigned by the system.
