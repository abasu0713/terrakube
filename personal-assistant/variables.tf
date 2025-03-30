variable "self_hosted_gen_ai_labels" {
  description = "Labels for self-hosted-gen-ai"
  type        = map(string)
  default = {
    "app.kubernetes.io/name"     = "self-hosted-gen-ai"
    "app.kubernetes.io/instance" = "self-hosted-gen-ai"
  }
}

variable "cf_zone_id" {
  type        = string
  description = "cloudflare zone id"
}

variable "cf_account_id" {
  sensitive   = true
  description = "cloudflare account id"
}

variable "cf_domain" {
  description = "cloudflare domain"
}

variable "cf_api_token" {
  description = "cloudflare API Token"
  sensitive   = true
  type        = string
}

variable "keycloak_terraform_client_secret" {
  description = "value of the keycloak terraform client secret"
  sensitive   = true
}

variable "keycloak_realm_id" {
  description = "value of the keycloak realm id"
}

variable "keycloak_oidc_client_id" {
  description = "value of the keycloak oidc client id"
  sensitive   = true
}