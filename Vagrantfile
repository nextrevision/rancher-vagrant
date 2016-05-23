# -*- mode: ruby -*-
# vi: set ft=ruby :

# required for setting the guest capabilities
require_relative 'lib/vagrant_rancheros_guest_plugin.rb'

unless Vagrant.has_plugin?("vagrant-rancher")
  puts "vagrant-rancher plugin not found, installing..."
  `vagrant plugin install vagrant-rancher`
  abort "vagrant-rancher plugin installed, but you need to rerun the vagrant command"
end

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

def get_server_ip(boxes)
  boxes.each_with_index do |box, i|
    if box.keys.include?('server') and box['server']
      return box['ip'] ? box['ip'] : "#{$ip_prefix}.#{i+1}#{i+1}"
    end
  end
  return nil
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
if File.exist?(CONFIG)
    require CONFIG
end

$sorted_boxes = validate_boxes $boxes
$server_ip = get_server_ip $sorted_boxes

Vagrant.configure(2) do |config|
  config.vm.box   = "rancherio/rancheros"
  config.vm.box_version = ">=0.4.1"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  $sorted_boxes.each_with_index do |box, box_index|
    count = box['count'] || 1
    server = box['server'] || false
    project = box['project'] || nil
    project_type = box['project_type'] || nil
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
            rancher.project = project if project
            rancher.project_type = project_type if project_type
          end
        else
          node.vm.provision :rancher do |rancher|
            rancher.role = "agent"
            rancher.hostname = $server_ip
            rancher.version = $version
            rancher.labels = box['labels'] || []
            rancher.project = project if project
            rancher.project_type = project_type if project_type
          end
        end
      end
    end
  end
end
