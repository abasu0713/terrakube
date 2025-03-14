resource "ansible_playbook" "label_nodes" {
  depends_on = [ansible_playbook.join_cluster]
  for_each   = { for server in var.servers : server.name => server if var.cluster_operation == "create" && length(server.labels) > 0 }

  playbook   = "./playbooks/label-nodes.yml"
  name       = ansible_group.k8s_cluster_group.children.0
  replayable = false
  extra_vars = {
    host  = each.value.name
    labels = join(" ", [for key, value in each.value.labels : "${key}=${value}"])
  }
}
