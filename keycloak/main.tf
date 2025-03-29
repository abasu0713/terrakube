resource "kubernetes_namespace" "keycloak_namespace" {
  metadata {
    name = var.keycloak_namespace
    labels = {
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}

resource "helm_release" "keycloak" {
  name        = var.keycloak_deployment_name
  namespace   = kubernetes_namespace.keycloak_namespace.metadata.0.name
  chart       = "keycloak"
  repository  = "oci://registry-1.docker.io/bitnamicharts"
  version     = "24.4.9"
  description = "Keycloak - an open source identity and access management solution"

  set = [
    {
      name  = "auth.adminPassword"
      value = var.keycloak_admin_user_password
    }
  ]
  values = [
    <<-EOT
    image: 
      tag: 26.0.7-debian-12-r0

    auth:
      adminUser: admin-temp

    extraEnvVars:
      - name: KEYCLOAK_FRONTEND_URL
        value: https://auth.arkobasu.space

    # Uncomment if you have custom themes and change the URL from where to download it
    # initContainers:
    #   - name: realm-ext-provider
    #     image: curlimages/curl
    #     imagePullPolicy: IfNotPresent
    #     command:
    #       - sh
    #     args:
    #       - -c
    #       - |
    #         mkdir -p /emptydir/app-providers-dir
    #         curl -L -f -S -o /emptydir/app-providers-dir/keycloak-theme.jar https://s3.arkobasu.space/keycloak-themes/keycloak-theme-for-kc-all-other-versions.jar

    #     volumeMounts:
    #       - name: empty-dir
    #         mountPath: /emptydir

    tls:
      enabled: true
      autoGenerated: true

    # Uncomment if you have a prometheus operator installed
    # metrics:
    #   enabled: true
    #   serviceMonitor:
    #     enabled: true
    #     namespace: monitoring

    proxy: edge
    EOT
  ]
  timeout = 600
}