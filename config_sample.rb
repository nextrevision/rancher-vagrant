# Box configuration details
# $box = "rancherio/rancheros"
# $box_version = '>=0.4.1'
#
# Official CoreOS channel to download from.  Either alpha, beta or stable
#$update_channel = "alpha"
# Change the version of CoreOS to deploy.  Use "current" if unsure
#$image_version = "current"
# URL to pull CoreOS image from
#$box_url = "https://storage.googleapis.com/%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % [$update_channel, $image_version]

# Tag of the rancher/server image to run
# $rancher_version = 'latest'

# IP prefix to use when assigning box ip addresses
# $ip_prefix = '192.168.33'

# Enable syncing of the current directory to the /vagrant path on the guest
# $disable_folder_sync = false

# Boxes to create in the vagrant environment
$boxes = [
    {
      "name"   => "rancher-server",
      "role"   => "server",
      "memory" => "1024",
      "labels" => [],
    },
    {
      "name"   => "rancher-agent",
      "count"  => 1,
      "memory" => "512",
      "labels" => ["type=rancher-client"]
    },
]
