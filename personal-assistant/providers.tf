terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
  required_version = "1.5.7"
  backend "s3" {
    bucket                      = "home-lab"
    key                         = "self-hosted-gen-ai/terraform.tfstate"
    region                      = "default"
    profile                     = "Terraform"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    # endpoint                    = "https://s3.arkobasu.space"
    endpoint = "http://192.168.5.81"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

provider "keycloak" {
  client_id     = "terraform"
  client_secret = var.keycloak_terraform_client_secret
  url           = "https://auth.arkobasu.space"
}

