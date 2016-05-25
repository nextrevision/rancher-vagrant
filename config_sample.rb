# Box configuration details
# $box = "rancherio/rancheros"
# $box_version = '>=0.4.1'
#
# CoreOS can also be used instead of RancherOS
# $box = "coreos-stable"
# $box_url = "https://storage.googleapis.com/stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

# Tag of the rancher/server image to run
# $rancher_version = 'latest'

# IP prefix to use when assigning box ip addresses
# $ip_prefix = '192.168.33'

# Enable syncing of the current directory
# to the /vagrant path on the guest
# $disable_folder_sync = false

# Boxes to create in the vagrant environment
$boxes = [
    {
      "name"   => "rancher-server",
      "role"   => "server",
      "memory" => "1536",
      "labels" => [],
    },
    {
      "name"   => "rancher-agent",
      "count"  => 2,
      "memory" => "512",
      "labels" => ["type=general"]
    },
]
