resource "kubernetes_namespace" "gen_ai" {
  metadata {
    name = "gen-ai"
    labels = {
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}