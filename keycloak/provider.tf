terraform {
  backend "s3" {
    bucket                      = "home-lab"
    key                         = "keycloak-app/terraform.tfstate"
    region                      = "default"
    profile                     = "Terraform"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    endpoint                    = "http://192.168.5.81"
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    random = {
      source = "hashicorp/random"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre1"
    }
  }
  required_version = "1.5.7"
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}