resource "ansible_playbook" "destroy_microk8s" {
  for_each   = var.cluster_operation == "destroy" ? { for host in ansible_group.k8s_cluster_group.children : host => host } : {}
  playbook   = "./playbooks/destroy-microk8s.yml"
  name       = each.key
  replayable = true
}