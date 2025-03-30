resource "kubernetes_persistent_volume_claim" "local_ai" {
  metadata {
    name      = "local-ai-pvc"
    namespace = kubernetes_namespace.gen_ai.metadata.0.name
    labels = merge(
      var.self_hosted_gen_ai_labels,
      {
        "app.kubernetes.io/component" = "local-ai"
      }
    )
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "25Gi"
      }
    }
  }
}

resource "random_string" "open_ai_api_key" {
  count = 1
  length  = 32
  special = false
  upper   = false
}


resource "kubernetes_deployment" "local_ai" {
  metadata {
    name      = "local-ai"
    namespace = kubernetes_namespace.gen_ai.metadata.0.name
    labels = merge(
      var.self_hosted_gen_ai_labels,
      {
        "app.kubernetes.io/component" = "local-ai"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = merge(
        var.self_hosted_gen_ai_labels,
        {
          "app.kubernetes.io/component" = "local-ai"
        }
      )
    }

    template {
      metadata {
        name = "local-ai"
        labels = merge(
          var.self_hosted_gen_ai_labels,
          {
            "app.kubernetes.io/component" = "local-ai"
          }
        )
      }

      spec {
        runtime_class_name = "nvidia"

        container {
          name              = "local-ai"
          image             = "localai/localai:v2.26.0-cublas-cuda12-core"
          image_pull_policy = "IfNotPresent"

          args = [
            # "deepseek-coder-1.3b-instruct"
            "Qwen2.5-Coder-3B-Instruct"
          ]

          env {
            name  = "DEBUG"
            value = "true"
          }
          env {
            name = "LOCALAI_API_KEY"
            value = join(",", random_string.open_ai_api_key[*].result)
          }
          env {
            name = "GALLERIES"
            value = jsonencode([
              {
                name = "personal-coder-gallery"
                url  = "https://raw.githubusercontent.com/abasu0713/coder-model-gallery/refs/heads/master/curated-quantized-coder-models.yaml"
              }
            ])
          }

          resources {
            requests = {
              cpu    = "750m"
              memory = "1024Mi"
            }
            limits = {
              cpu              = "3"
              memory           = "8192Mi"
              "nvidia.com/gpu" = 1
            }
          }

          volume_mount {
            name       = "models-volume"
            mount_path = "/build/models"
          }
        }

        volume {
          name = "models-volume"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.local_ai.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "local_ai" {
  metadata {
    name      = "local-ai"
    namespace = kubernetes_namespace.gen_ai.metadata.0.name
    labels    = kubernetes_deployment.local_ai.metadata.0.labels
  }

  spec {
    selector = kubernetes_deployment.local_ai.spec.0.selector.0.match_labels

    type = "ClusterIP"

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}

output "open_ai_api_keys" {
  value = random_string.open_ai_api_key[*].result
}