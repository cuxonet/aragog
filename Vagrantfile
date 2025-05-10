Vagrant.configure("2") do |config|
  # Imagen base
  config.vm.box = "ubuntu/jammy64"

  # Red privada DHCP
  config.vm.network "private_network", type: "dhcp"

  # Recursos de la máquina virtual
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
  end

  # Script de provisionamiento
  config.vm.provision "shell", path: "provision.sh"
end
