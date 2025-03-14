resource "ansible_playbook" "get_kubeconfig" {
  count = var.cluster_operation == "create" ? 1 : 0
  depends_on = [
    ansible_playbook.join_cluster
  ]
  playbook   = "./playbooks/get-kubeconfig.yml"
  name       = ansible_group.k8s_cluster_group.children.0
  replayable = false
}