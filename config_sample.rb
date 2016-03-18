# Tag of the rancher/server image to run
# $version = 'latest'

# IP prefix to use when assigning box ip addresses
# $ip_prefix = '192.168.33'

# Boxes to run in the vagrant environment
$boxes = [
    {
      "name"   => "rancher-server",
      "server" => true,
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
