# rancheros-vagrant

Vagrant environment for running Rancher server and RancherOS.

## Usage

```
git clone https://github.com/nextrevision/rancher-vagrant-env
cd rancher-vagrant-env
vagrant up
```

Assuming the defaults, browse to [http://192.168.33.11:8080](http://192.168.33.11:8080) to access your Rancher server.

## Configuration

You can configure the environment by setting up a custom `config.rb` file in the root of the repository. The available configuration options to you are displayed below:

- `boxes` - an array of guests to boot up in the environment
    - `name` (**required**, *string*) - name of the box
    - `count` (optional, *int*) - number of boxes to create based on these settings
    - `server` (optional, *bool*) - set to true of the box should be configured as a Rancher server
    - `memory` (optional, *string*) - amount of memory to dedicate to the box (if running as a Rancher server, it's best to set this to a higher value, maybe '1536')
    - `labels` (optional, *array*) - labels to apply to the host when registering in 'key=value' format
    - `ip` (optional, *string*) - ip to set for the box (typically good to leave this alone)
    - `project` (optional, *string*) - name of the project to place the guest in (will be created if it doesn't exist)
    - `project_type` (optional, *string*) - type of project to create (default: cattle; can be kubernetes or swarm)

- `ip_prefix` (optional, *string*) - the first three octets of the IP to use when configuring boxes
- `version` (optional, *string*) - Rancher server version (Docker tag) to deploy

## Example

See config_sample.rb
