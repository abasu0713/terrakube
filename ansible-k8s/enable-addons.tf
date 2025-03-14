resource "ansible_playbook" "enable_addons" {
  depends_on = [
    ansible_playbook.join_cluster
  ]
  for_each   = var.cluster_operation == "create" ? toset(var.addons) : []
  playbook   = "./playbooks/enable-addons.yml"
  name       = ansible_group.k8s_cluster_group.children.0
  replayable = false
  extra_vars = {
    addon = each.value
  }
}

resource "ansible_playbook" "enable_acceleration" {
  depends_on = [ ansible_playbook.join_cluster ]
  for_each = { for server in var.servers : server.name => server if var.cluster_operation == "create" && lookup(server.labels, "accelerated", false) }
  playbook = "./playbooks/enable-addons.yml"
  name = each.key
  replayable = false
  extra_vars = {
    addon = "nvidia"
  }
}