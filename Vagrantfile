# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  #General config
  # config.vm.network "public_network", use_dhcp_assigned_default_route: true, bridge: "Intel(R) Wi-Fi 6E AX211 160MHz"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = "2"
  end
  config.ssh.insert_key = false

  config.vm.network "private_network", type: "dhcp"

  #Control
  config.vm.define "control" do |control|
    control.vm.box = "generic/ubuntu2004"
    control.vm.hostname = "control"
    # control.vm.network "private_network", type: "dhcp" #, ip: "192.168.2.11"
    control.vm.provision "get_ip", type: "host_shell", inline: <<-SHELL
      ./get-ip.sh
      SHELL
    
    control.vm.provision "copy_ip", type: "file",  after: "get_ip", source: "temp/control-ip", destination: "/home/vagrant/control-ip"

    #https://rancher.com/docs/k3s/latest/en/installation/network-options/#dual-stack-installation
    control.vm.provision "install_k3s", after: "copy_ip", type: "shell" ,inline: <<-SHELL
      control_ip=$(cat /home/vagrant/control-ip)
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=$control_ip" K3S_KUBECONFIG_MODE="644" sh -s -
      SHELL
    
    control.vm.provision "install_tools", after: "install_k3s", type: "shell" ,inline: <<-SHELL
      echo 'source <(kubectl completion bash)' >>/home/vagrant/.bash_profile
      echo 'alias k=kubectl' >>/home/vagrant/.bash_profile
      echo 'complete -F __start_kubectl k' >>/home/vagrant/.bash_profile
      source /home/vagrant/.bash_profile
      SHELL

    control.vm.provision "get_token", after: "install_k3s", type: "host_shell", inline: <<-SHELL
      ./get-token.sh
      SHELL
  end
  
  #Workers
  config.vm.define "worker1" do |worker|
    worker.vm.box = "generic/ubuntu2004"
    worker.vm.hostname = "worker1"
    # worker.vm.network "private_network"#, ip: "192.168.2.12"


    worker.vm.provision "file", source: "temp/node-token", destination: "/home/vagrant/node-token"
    worker.vm.provision "file", source: "temp/control-ip", destination: "/home/vagrant/control-ip"

    worker.vm.provision "shell" do |install_k3s|
      install_k3s.inline = <<-SHELL
        node_token=$(cat /home/vagrant/node-token)
        control_ip=$(cat /home/vagrant/control-ip)
        echo $node_token
        echo $control_ip
        curl -sfL http://get.k3s.io | K3S_URL=https://$control_ip:6443 K3S_TOKEN=$node_token sh -s - 
        echo 'source <(kubectl completion bash)' >>~/.bashrc
      SHELL
    end
  end

  config.vm.define "worker2" do |worker|
    worker.vm.box = "generic/ubuntu2004"
    worker.vm.hostname = "worker2"
    # worker.vm.network "private_network"#, ip: "192.168.2.13"

    worker.vm.provision "file", source: "temp/node-token", destination: "/home/vagrant/node-token"
    worker.vm.provision "file", source: "temp/control-ip", destination: "/home/vagrant/control-ip"

    worker.vm.provision "shell" do |install_k3s|
      install_k3s.inline = <<-SHELL
        node_token=$(cat /home/vagrant/node-token)
        control_ip=$(cat /home/vagrant/control-ip)
        echo $node_token
        echo $control_ip
        curl -sfL http://get.k3s.io | K3S_URL=https://$control_ip:6443 K3S_TOKEN=$node_token sh -s - 
        echo 'source <(kubectl completion bash)' >>~/.bashrc
      SHELL
    end
  end

  # #Update cacerts
  # config.vm.provision "apt-update", type: "shell", reboot: true ,inline: <<-SHELL
  #   sudo apt update && sudo apt upgrade -y
  # SHELL

  #Provision certs
  config.vm.provision "shell" do |install_certs|
    ssh_pub_key = File.readlines("vagrant_rsa.pub").first.strip
    install_certs.inline = <<-SHELL
      mkdir /p /root/.ssh/
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
      echo PubkeyAuthentication yes >> /etc/ssh/sshd_config
      echo PasswordAuthentication no >> /etc/ssh/sshd_config
      echo ChallengeResponseAuthentication no >> /etc/ssh/sshd_config
      sudo systemctl restart sshd
    SHELL
  end
end
