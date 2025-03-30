resource "helm_release" "open-webui" {
  depends_on  = [kubernetes_service.local_ai]
  name        = "open-webui"
  namespace   = kubernetes_namespace.gen_ai.metadata.0.name
  chart       = "open-webui"
  repository  = "https://open-webui.github.io/helm-charts"
  version     = "5.19.0"
  description = "Open WebUI - a self-hosted web-based user interface for your Generative AI models"

  values = [
    <<-EOT
    namespaceOverride: ${kubernetes_namespace.gen_ai.metadata.0.name}
    image:
      repository: ghcr.io/open-webui/open-webui
      tag: "git-6471f12"
      pullPolicy: "IfNotPresent"
    nodeSelector:
      "beta.kubernetes.io/arch": "arm64"
    ollama:
      enabled: false
    pipelines:
      enabled: false
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1024Mi"
        cpu: "1500m"
    persistence:
      enabled: true
      accessMode: "ReadWriteOnce"
      size: "8Gi"
    openaiBaseApiUrl: "https://${cloudflare_record.openai.hostname}"
    extraEnvVars:
      - name: "OPENAI_API_KEY"
        value: ${random_string.open_ai_api_key[0].result}
      - name: "ENABLE_LOGIN_FORM"
        value: "False"
      - name: "ENABLE_OAUTH_SIGNUP"
        value: "True"
      - name: "OAUTH_CLIENT_ID"
        value: ${data.keycloak_openid_client.personal_access.client_id}
      - name: "OAUTH_CLIENT_SECRET"
        value: ${data.keycloak_openid_client.personal_access.client_secret}
      - name: "OPENID_PROVIDER_URL"
        value: "https://auth.arkobasu.space/realms/personal/.well-known/openid-configuration"
      - name: "OAUTH_SCOPES"
        value: "openid email profile groups"
    EOT
  ]
}

