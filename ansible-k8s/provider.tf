terraform {
  backend "s3" {
    bucket                      = "home-lab"
    key                         = "ansible-k8s/terraform.tfstate"
    region                      = "default"
    profile                     = "Terraform"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    endpoint                    = "http://192.168.5.81"
    # endpoint                    = "https://s3.arkobasu.space"
  }
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
  required_version = "1.5.7"
}
provider "ansible" {}