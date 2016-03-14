# -*- mode: ruby -*-
# vi: set ft=ruby :

CONFIG = File.join(File.dirname(__FILE__), "config.rb")
$boxes = []
$rancher_version = 'latest'

# install vagrant plugin hostmanager
if not File.exist?('.vagrant_plugin_check')
  puts "Checking and installing vagrant plugins"
  `vagrant plugin list | grep vagrant-hostmanager || vagrant plugin install vagrant-hostmanager`
  File.open(".vagrant_plugin_check", "w") {}
end

require_relative 'vagrant_rancheros_guest_plugin.rb'

if File.exist?(CONFIG)
    require CONFIG
end

# To enable rsync folder share change to false
$rsync_folder_disabled = true

$configure_docker = <<SCRIPT
HOSTNAME=$1
sudo hostname $1
if ! sudo ros config get rancher.docker.args | grep -q 'tcp://0.0.0.0:2375'; then
  sudo ros config set rancher.docker.args \
    '[daemon, -H, unix:///var/run/docker.sock, -H, tcp://0.0.0.0:2375]'
  sudo ros service restart docker
  sleep 5
fi
SCRIPT

$download_jq = <<SCRIPT
if ! [ -f jq ]; then
  wget -q -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod +x jq
fi
SCRIPT

$start_rancher_server = <<SCRIPT
RANCHER_SERVER_IP=$(grep rancher-server-01 /etc/hosts | awk '{ print $1 }')
if ! docker inspect rancher-server &> /dev/null; then
  docker run --name rancher-server -d -p 8080:8080 rancher/server:#{$rancher_version}
  while ! wget -q http://localhost:8080/v1/ &> /dev/null; do sleep 10; done
  docker run --rm --net=host radial/busyboxplus:curl \
    curl -s http://localhost:8080/v1/projects > projects.txt
  PROJECT_ID=$(cat projects.txt | ./jq '.data[0].id')
  docker run --rm --net=host radial/busyboxplus:curl \
    curl -s -X POST -H "x-api-project-id: ${PROJECT_ID}" http://localhost:8080/v1/registrationtokens/
  docker run --rm --net=host radial/busyboxplus:curl \
    curl -s -X PUT -H "Content-Type: application/json" \
    -d "{\"value\":\"${RANCHER_SERVER_IP}:8080\"}" \
    http://localhost:8080/v1/activesettings/api.host
  sleep 3
fi
SCRIPT

$start_rancher_agent = <<SCRIPT
LABELS=$1
RANCHER_SERVER_IP=$(grep rancher-server-01 /etc/hosts | awk '{ print $1 }')
if ! docker inspect rancher-agent &> /dev/null; then
  docker run --rm --net=host radial/busyboxplus:curl \
    curl -s http://${RANCHER_SERVER_IP}:8080/v1/registrationtokens/ > registrationTokens.txt
  URL=$(cat registrationTokens.txt | ./jq '.data[0].registrationUrl' | sed 's/"//g')
  IMAGE=$(cat registrationTokens.txt | ./jq '.data[0].image' | sed 's/"//g')
  if [ -z "${URL}" ] || [ -z "${IMAGE}" ]; then
    echo "Could not get registration details from Rancher server"
    exit 1
  fi
  sudo docker run -d --add-host="rancher-server-01:${RANCHER_SERVER_IP}" \
    --privileged -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/rancher:/var/lib/rancher -e "CATTLE_HOST_LABELS=${LABELS}" ${IMAGE} ${URL}
fi
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box   = "rancherio/rancheros"
  config.vm.box_version = ">=0.4.1"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  $boxes.each_with_index do |box, box_index|
    (1..box['count']).each do |i|
      hostname = "#{box['name']}-%02d" % i
      config.vm.define hostname do |node|
        node.vm.provider "virtualbox" do |vb|
          vb.memory = box['memory']
        end

        ip = "172.19.8.#{box_index+1}#{i}"
        node.vm.network "private_network", ip: ip
        node.vm.hostname = hostname

        # Disabling compression because OS X has an ancient version of rsync installed.
        # Add -z or remove rsync__args below if you have a newer version of rsync on your machine.
        node.vm.synced_folder ".", "/opt/rancher", type: "rsync",
            rsync__exclude: ".git/", rsync__args: ["--verbose", "--archive", "--delete", "--copy-links"],
            disabled: $rsync_folder_disabled

        node.vm.provision "shell", inline: $configure_docker, args: ["#{hostname}"]
        node.vm.provision "shell", inline: $download_jq
        if box['name'] == "rancher-server"
          node.vm.provision "shell", inline: $start_rancher_server
        end
        node.vm.provision "shell", inline: $start_rancher_agent, args: ["#{box['labels'].join('&')}&environment=local"]
      end
    end
  end
end
