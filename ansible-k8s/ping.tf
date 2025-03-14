resource "ansible_playbook" "ping" {
  for_each   = var.cluster_operation == "ping" ? { for host in ansible_group.k8s_cluster_group.children : host => host } : {}
  playbook   = "./playbooks/ping.yml"
  name       = each.key
  replayable = true
  timeouts {
    create = "1m"
  }
}