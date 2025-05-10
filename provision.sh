#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo "Instalando herramientas básicas..."
sudo apt install -y curl wget net-tools whois tcpd \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold"

echo "Activando Ubuntu Pro..."
# Reemplaza 'xxxxxxxxx' con tu token de Ubuntu Pro. Puedes obtenerlo desde https://ubuntu.com/pro
sudo pro attach   xxxxxxxxx  

echo "Activando Ubuntu Security Guide (usg)..."
sudo pro enable usg

echo "Instalando USG..."
sudo apt update
sudo apt install -y usg

echo "Aplicando hardening CIS Level 1 Server..."
sudo usg fix cis_level1_server

echo "Instalando Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

echo "Creando usuario base adminserver..."
sudo adduser --disabled-password --gecos "" adminserver
sudo usermod -aG sudo adminserver

echo "Agregando usuarios a grupo docker..."
sudo usermod -aG docker adminserver
sudo usermod -aG docker vagrant

echo "Creando carpeta base para alumnos..."
sudo mkdir -p /home/WEBS_ALUMNOS
sudo chmod 755 /home/WEBS_ALUMNOS

echo "Bloqueando acceso SSH remoto para root y adminserver..."
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
echo "DenyUsers root adminserver" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl reload sshd

echo "Creando alias para crear_alumno..."
if [ -f /vagrant/crear_alumno.sh ]; then
  sudo ln -sf /vagrant/crear_alumno.sh /usr/local/bin/crear_alumno
  sudo chmod +x /vagrant/crear_alumno.sh
fi

echo "Agregando script de auditoría post-reinicio..."
cat <<'EOF' | sudo tee /etc/profile.d/post-reboot-audit.sh > /dev/null
#!/bin/bash
if [ ! -f /vagrant/usg_audit_report.html ]; then
  sudo usg audit cis_level1_server --html-file /vagrant/usg_audit_report.html
fi
EOF

sudo chmod +x /etc/profile.d/post-reboot-audit.sh

echo "Instalando y configurando Fail2Ban..."
sudo apt install -y fail2ban
sudo cp /vagrant/fail2ban/jail.local /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Instalando y configurando PortSentry..."

sudo DEBIAN_FRONTEND=noninteractive apt install -y portsentry

# Copiar archivos de configuración personalizados
sudo cp /vagrant/portsentry/portsentry.conf /etc/portsentry/portsentry.conf
sudo cp /vagrant/portsentry/portsentry.default /etc/default/portsentry

# Habilitar el servicio al inicio
sudo systemctl enable portsentry

# Iniciar el servicio manualmente
sudo systemctl restart portsentry

echo "Provisionamiento completo."
