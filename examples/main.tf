terraform {
  required_providers {
    juice = {
      version = "~> 0.1"
      source = "terraform.in.pan-net.eu/juice/juice"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}

provider "juice" {
}

provider "random" {
}

resource "random_password" "password" {
  length   = 20
  special  = false
}

# Create sample project
resource "juice_project" "project" {
  # "cloud" attribute is automatically set from J_CLOUD env var
  # cloud = "juice-cloud" 
  name  = "tf-juice-test"
  description = "Test project for TF juice provider"
}

# Create project user
resource "juice_user" "project_user" {
  # "cloud" attribute is automatically set from J_CLOUD env var
  # cloud = "juice-cloud" 
  username    = "tf-juice-test-user1"
  password    = random_password.password.result
  description = "Test user for TF juice provider"
}

# Add a member user
resource "juice_project_member" "project_member" {
  juice_project_id = juice_project.project.id
  username = juice_user.project_user.username
  # user_domain = "users_domain"
  depends_on = [
    juice_user.project_user
  ]
}

# Set project quotas
resource "juice_quota" "quota" {
  juice_project_id = juice_project.project.id

  # compute quotas
  instances            = 6
  cores                = 2
  ram                  = 2
  # key_pairs            = 5
  # injected_files       = 5
  # injected_file_size   = 5
  # injected_path_size   = 2
  # fixed_ips            = 9
  # server_group_members = -1
  # server_groups        = -1

  # volume quotas
  gigabytes            = 4
  per_volume_gigabytes = 4
  volumes              = 2
  # snapshots            = 5
  # backups              = 6
  # backup_gigabytes     = 9

  # network quotas
  networks             = 2
  subnets              = 2
  ports                = -1
  routers              = 2
  floatingips          = 1
  security_groups      = -1
  security_group_rules = -1
}

# Create RBAC for external network
resource "juice_extnet_rbac" "pi-net" {
  juice_project_id = juice_project.project.id
  network = "external_pi-net_provider"
}

resource "juice_flavor" "test-flavor" {
  juice_project_id = juice_project.project.id
  name  = "tf-juice-test-flavor1"
  vcpus = 1
  ram   = 1024
  disk  = 20
  extra_specs = {
    "aggregate_instance_extra_specs:compute_role": "shared",
    "aggregate_instance_extra_specs:consumer": "all",
    # "aggregate_instance_extra_specs:hw_family": "Be",
    "aggregate_instance_extra_specs:cpu_vendor": "intel",
  }
}

# Create provider VLAN network
resource "juice_network" "net1" {
  juice_project_id = juice_project.project.id
  name = "tf-juice-test-net1"
  description = "TF juice test VLAN net"
  physical_network = "physnet1"
  segmentation_id = 1039
  # mtu = 8000
}

resource "juice_network" "net2" {
  juice_project_id = juice_project.project.id
  name = "tf-juice-test-net2"
  description = "TF juice test Geneve net"
  network_type = "geneve"
  # mtu = 8000
}

# Create subnet
resource "juice_subnet" "subnet1" {
  juice_network_id = juice_network.net1.id
  name = "tf-juice-test-net1.subnet0"
  description = "TF juice test subnet"
  cidr = "192.168.1.0/24"
  dns_nameservers = [ "192.168.1.1", "192.168.1.2" ]
  allocation_pool {
    start = "192.168.1.5"
    end   = "192.168.1.100"
  }
  host_route {
    destination = "10.235.0.0/16"
    nexthop = "192.168.1.1"
  }
}
