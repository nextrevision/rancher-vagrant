# -*- mode: ruby -*-
# vi: set ft=ruby :

# required for setting the guest capabilities
require_relative 'lib/vagrant_rancheros_guest_plugin.rb'

def validate_boxes(boxes)
  servers = []
  agents = []
  boxes.each do |box|
    if box.keys.include?('server') and box['server']
      servers.push(box)
    else
      agents.push(box)
    end
  end
  abort "At least one server must be specified in the $boxes config" if servers.empty?
  return servers + agents
end

# install vagrant plugins
if not File.exist?('.vagrant_plugin_check')
  puts "Checking and installing vagrant plugins"
  `vagrant plugin list | grep vagrant-rancher || vagrant plugin install vagrant-rancher`
  File.open(".vagrant_plugin_check", "w") {}
end

# load user config
if File.exist?(File.join(File.dirname(__FILE__), "config.rb"))
  CONFIG = File.join(File.dirname(__FILE__), "config.rb")
else
  CONFIG = File.join(File.dirname(__FILE__), "config_sample.rb")
end

# set rancher config
$boxes = []
$version = 'latest'
$ip_prefix = '192.168.33'
$server_ip = nil
if File.exist?(CONFIG)
    require CONFIG
end

$sorted_boxes = validate_boxes $boxes

Vagrant.configure(2) do |config|
  config.vm.box   = "rancherio/rancheros"
  config.vm.box_version = ">=0.4.1"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  $sorted_boxes.each_with_index do |box, box_index|
    count = box['count'] || 1
    server = box['server'] || false
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
          $server_ip = ip if $server_ip.nil?
          node.vm.provision :rancher do |rancher|
            rancher.hostname = $server_ip
            rancher.version = $version
            rancher.deactivate = true
            rancher.labels = box['labels'] || []
          end
        else
          node.vm.provision :rancher do |rancher|
            rancher.role = "agent"
            rancher.hostname = $server_ip
            rancher.version = $version
            rancher.labels = box['labels'] || []
          end
        end
      end
    end
  end
end
