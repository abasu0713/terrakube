terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
  # required_version = "1.5.7"
}

provider "ansible" {}