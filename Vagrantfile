# -*- mode: ruby -*-
# vi: set ft=ruby :

# set vagrant defaults
$boxes = []
$box = 'rancherio/rancheros'
$box_url = nil
$box_version = nil
$rancher_version = 'latest'
$ip_prefix = '192.168.33'
$disable_folder_sync = true

# install the vagrant-rancher provisioner plugin if
# it is not already installed
unless Vagrant.has_plugin?('vagrant-rancher')
  puts 'vagrant-rancher plugin not found, installing...'
  `vagrant plugin install vagrant-rancher`
  abort 'vagrant-rancher plugin installed, but you need to rerun the vagrant command'
end

# validate that at least one box is setup as a rancher server
def parse_boxes(boxes)
  servers = []
  agents = []
  boxes.each do |box|
    abort 'Must specify name for box' if box['name'].nil?
    if $box == 'rancherio/rancheros'
      if !box['memory'].nil? and box['memory'].to_i < 512
        puts 'WARNING: Running RancherOS on less than 512MB of RAM has been known to cause issues.'
      end
    end
    if !box['role'].nil? and box['role'] == 'server'
      servers.push(box)
    else
      agents.push(box)
    end
  end
  abort 'At least one server must be specified in the $boxes config' if servers.empty?
  return servers + agents
end

# loop through boxes and return the ip address of the
# first server box found
def get_server_ip(boxes, hostname='')
  default_server_ip = nil
  boxes.each_with_index do |box, i|
    if not box['role'].nil? and box['role'] == 'server'
      ip = box['ip'] ? box['ip'] : "#{$ip_prefix}.#{i+1}#{i+1}"
      default_server_ip = ip if default_server_ip.nil?
      if hostname == "#{box['name']}-%02d" % i
        return ip
      end
    end
  end
  return default_server_ip
end

# if there is a user-supplied config.rb use that otherwise
# default to the config_sample.rb
if File.exist?(File.join(File.dirname(__FILE__), 'config.rb'))
  CONFIG = File.join(File.dirname(__FILE__), 'config.rb')
else
  CONFIG = File.join(File.dirname(__FILE__), 'config_sample.rb')
end

# load the set config file
if File.exist?(CONFIG)
    require CONFIG
end

# require some capability overrides if the box is rancheros
if $box == 'rancherio/rancheros'
  require_relative 'lib/vagrant_rancheros_guest_plugin.rb'
end

# get a list of sorted boxes (starting with server)
$sorted_boxes = parse_boxes $boxes

# determine the default server ip
$default_server_ip = get_server_ip $sorted_boxes

Vagrant.configure(2) do |config|
  # configure box settings
  config.vm.box = $box
  config.vm.box_url = $box_url unless $box_url.nil?
  config.vm.box_version = $box_version unless $box_version.nil?

  if $disable_folder_sync
    config.vm.synced_folder '.', '/vagrant', disabled: true
  else
    # use rsync when box is rancheros
    # otherwise stick with the vagrant defaults
    if $box == 'rancherio/rancheros'
      config.vm.synced_folder ".", "/vagrant", type: "rsync",
        rsync__exclude: ".git/",
        rsync__args: ["--verbose", "--archive", "--delete", "--copy-links"],
        disabled: false
    else
      config.vm.synced_folder '.', '/vagrant', disabled: false
    end
  end

  $sorted_boxes.each_with_index do |box, box_index|
    # default to only one of each type of box
    count = box['count'] || 1

    # loop through the desired number of instances
    # for a given box
    (1..count).each do |i|

      # configure the hostname, ex. rancher-server-01
      hostname = "#{box['name']}-%02d" % i

      # configure node settings
      config.vm.define hostname do |node|
        # set the hostname
        node.vm.hostname = hostname

        # set the node ip address
        ip = box['ip'] ? box['ip'] : "#{$ip_prefix}.#{box_index+1}#{i}"
        node.vm.network 'private_network', ip: ip

        # override default memory allocation if set in config
        unless box['memory'].nil?
          node.vm.provider 'virtualbox' do |vb|
            vb.memory = box['memory']
          end
        end

        if !box['role'].nil? and box['role'] == 'server'
          node.vm.provision :rancher do |rancher|
            rancher.role = 'server'
            rancher.hostname = ip
            rancher.version = $rancher_version
            rancher.deactivate = true
            rancher.install_agent = box['install_agent'] || false
            rancher.labels = box['labels'] unless box['labels'].nil?
            rancher.project = box['project'] unless box['project'].nil?
            rancher.project_type = box['project_type'] unless box['project_type'].nil?
          end
        else
          node.vm.provision :rancher do |rancher|
            rancher.role = 'agent'
            rancher.hostname = box['server'] || $default_server_ip
            rancher.install_agent = box['install_agent'] unless box['install_agent'].nil?
            rancher.labels = box['labels'] unless box['labels'].nil?
            rancher.project = box['project'] unless box['project'].nil?
            rancher.project_type = box['project_type'] unless box['project_type'].nil?
          end
        end
      end
    end
  end
end
