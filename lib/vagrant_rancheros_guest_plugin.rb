require 'ipaddr'

## Hacking this until we get a real plugin

# Borrowing from http://stackoverflow.com/questions/1825928/netmask-to-cidr-in-ruby
IPAddr.class_eval do
  def to_cidr
    self.to_i.to_s(2).count("1")
  end
end

module VagrantPlugins
  module GuestLinux
    class Plugin < Vagrant.plugin("2")
      guest_capability("linux", "change_host_name") do
        Cap::ChangeHostName
      end

      guest_capability("linux", "configure_networks") do
        Cap::ConfigureNetworks
      end
    end
  end
end

module VagrantPlugins
    module GuestLinux
        module Cap
            class ConfigureNetworks
                def self.configure_networks(machine, networks)
                    machine.communicate.tap do |comm|
                        interfaces = []
                        comm.sudo("ip link show|grep eth[1-9]|awk '{print $2}'|sed -e 's/:$//'") do |_, result|
                            interfaces = result.split("\n")
                        end

                        networks.each do |network|
                            iface = interfaces[network[:interface].to_i - 1]

                            if network[:type] == :static
                              cidr = IPAddr.new(network[:netmask]).to_cidr
                              comm.sudo("ros config set rancher.network.interfaces.#{iface}.address #{network[:ip]}/#{cidr}")
                              comm.sudo("ros config set rancher.network.interfaces.#{iface}.match #{iface}")
                              comm.sudo("ros config set rancher.network.interfaces.#{iface}.dhcp false")
                            else
                              comm.sudo("ros config set rancher.network.interfaces.#{iface}.dhcp true")
                            end
                        end

                        comm.sudo("system-docker restart network")
                    end
                end
            end
        end
    end
end

module VagrantPlugins
    module GuestLinux
        module Cap
            class ChangeHostName
                def self.change_host_name(machine, name)
                    machine.communicate.tap do |comm|
                        if !comm.test("sudo hostname --fqdn | grep '#{name}'")
                            comm.sudo("echo '#cloud-config' > /var/lib/rancher/conf/cloud-config.yml")
                            comm.sudo("echo 'hostname: #{name}' >> /var/lib/rancher/conf/cloud-config.yml")
                            comm.sudo("ros config set cloud_init.datasources '[file:/var/lib/rancher/conf/cloud-config.yml]'")
                            comm.sudo("system-docker restart cloud-init")
                            comm.sudo("cloud-init -execute")
                        end
                    end
                end
            end
        end
    end
end
