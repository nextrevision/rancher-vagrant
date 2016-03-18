# -*- mode: ruby -*-
# vi: set ft=ruby :

# required for setting the guest capabilities
require_relative 'lib/vagrant_rancheros_guest_plugin.rb'

# load user config
if File.exist?(File.dirname(__FILE__), "config.rb")
  CONFIG = File.join(File.dirname(__FILE__), "config.rb")
else
  CONFIG = File.join(File.dirname(__FILE__), "config.rb.sample")
end

RANCHER_SERVER_IP = nil

# set rancher config
$boxes = []
$version = 'latest'
$ip_prefix = '192.168.33'
if File.exist?(CONFIG)
    require CONFIG
end

# install vagrant plugins
if not File.exist?('.vagrant_plugin_check')
  puts "Checking and installing vagrant plugins"
  `vagrant plugin list | grep vagrant-rancher || vagrant plugin install vagrant-rancher`
  File.open(".vagrant_plugin_check", "w") {}
end

Vagrant.configure(2) do |config|
  config.vm.box   = "rancherio/rancheros"
  config.vm.box_version = ">=0.4.1"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  $boxes.each_with_index do |box, box_index|
    count = box['count'] || 1
    server = box['server'] || true
    (1..count).each do |i|
      hostname = "#{box['name']}-%02d" % i
      config.vm.define hostname do |node|
        node.vm.hostname = hostname

        ip = box['ip'] ? box['ip'] : "#{$ip_prefix}.#{box_index+1}#{i}"
        node.vm.network "private_network", ip: ip

        unless box['memory'].nil?
          node.vm.provider "virtualbox" do |vb|
            vb.memory = box['memory']
          end
        end

        if server
          RANCHER_SERVER_IP = ip
          node.vm.provision :rancher do |rancher|
            rancher.hostname = RANCHER_SERVER_IP
            rancher.version = $version
            rancher.deactivate = true
            rancher.labels = box['labels'] || []
          end
        else
          node.vm.provision :rancher do |rancher|
            rancher.role = "agent"
            rancher.hostname = RANCHER_SERVER_IP
            rancher.version = $version
            rancher.labels = box['labels'] || []
          end
        end
      end
    end
  end
end
