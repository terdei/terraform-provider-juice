terraform {
  required_providers {
    juice = {
      version = "~> 0.1"
      source = "terraform.in.pan-net.eu/juice/juice"
    }
  }
}

provider "juice" {
}

# Create sample project
resource "juice_project" "project" {
  # "cloud" attribute is automatically set from J_CLOUD env var
  # cloud = "juice-cloud" 
  name  = "tf-juice-test"
  description = "Test project for TF juice provider"
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
