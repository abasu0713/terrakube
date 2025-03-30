resource "random_password" "tunnel_secret" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = var.cf_account_id
  name       = "Terraform managed cloudfare tunnel for self-hosted-gen-ai tools"
  secret     = base64sha256(random_password.tunnel_secret.result)
}

resource "cloudflare_record" "openai" {
  zone_id = var.cf_zone_id
  name    = "openai-api"
  content = cloudflare_zero_trust_tunnel_cloudflared.tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "personal_assistant" {
  zone_id = var.cf_zone_id
  name    = "personal-ai"
  content = cloudflare_zero_trust_tunnel_cloudflared.tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "genai_tunnel_config" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
  account_id = var.cf_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.openai.hostname
      service  = "http://${kubernetes_service.local_ai.metadata.0.name}:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.personal_assistant.hostname
      service  = "http://open-webui:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "kubernetes_deployment_v1" "cf_tunnel_gen_ai" {
  depends_on = [
    cloudflare_zero_trust_tunnel_cloudflared_config.genai_tunnel_config,
    helm_release.open-webui,
    kubernetes_service.local_ai
  ]
  metadata {
    name      = "cf-tunnel-gen-ai"
    namespace = kubernetes_namespace.gen_ai.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "cf-tunnel-gen-ai"
      }
    }
    template {
      metadata {
        labels = {
          app = "cf-tunnel-gen-ai"
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
            "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.tunnel_token}",
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