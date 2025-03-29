# Using random_password resource to make the secret sensative
resource "random_password" "tunnel_secret" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "keycloak_tunnel" {
  account_id = var.cf_account_id
  name       = "Terraform managed cloudfare tunnel for self managed Keycloak deployment"
  secret     = base64sha256(random_password.tunnel_secret.result)
}

resource "cloudflare_record" "keycloak_app" {
  zone_id = var.cf_zone_id
  name    = var.keycloak_deployment_name
  content = cloudflare_zero_trust_tunnel_cloudflared.keycloak_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "keycloak_tunnel_config" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.keycloak_tunnel.id
  account_id = var.cf_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.keycloak_app.hostname
      # this is going to be format: helm_release.keycloak.name
      service = "https://${var.keycloak_deployment_name}-keycloak:443"
      origin_request {
        no_tls_verify = true
      }
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "kubernetes_deployment_v1" "cf_tunnel_keycloak" {
  depends_on = [helm_release.keycloak]
  metadata {
    name      = "cf-tunnel-keycloak-auth"
    namespace = kubernetes_namespace.keycloak_namespace.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "cf-tunnel-keycloak-auth"
      }
    }
    template {
      metadata {
        labels = {
          app = "cf-tunnel-keycloak-auth"
        }
      }
      spec {
        security_context {
          run_as_user     = 1000
          run_as_group    = 3000
          fs_group        = 2000
          run_as_non_root = true
        }
        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:latest"
          command = [
            "cloudflared",
            "tunnel",
            "--metrics",
            "0.0.0.0:2880",
            "--no-autoupdate"
          ]
          args = [
            "run",
            "--token",
            "${cloudflare_zero_trust_tunnel_cloudflared.keycloak_tunnel.tunnel_token}",
          ]
          security_context {
            allow_privilege_escalation = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
            run_as_non_root = true
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }
          liveness_probe {
            http_get {
              path = "/ready"
              port = 2880
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            failure_threshold     = 1
          }
        }
      }
    }
  }
}

