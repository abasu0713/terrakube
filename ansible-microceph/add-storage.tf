resource "ansible_playbook" "add_osd" {
  depends_on = [
    ansible_playbook.join_cluster
  ]
  for_each   = var.cluster_operation == "create" ? { for host in ansible_host.nodes : host.name => host } : {}
  playbook   = "./playbooks/add-osd.yml"
  name       = each.value.name
  replayable = false
  verbosity  = 1
  extra_vars = {
    drives = each.value.variables.drives
  }
}

resource "ansible_playbook" "add_loop_osd" {
  depends_on = [
    ansible_playbook.add_osd
  ]
  for_each   = var.cluster_operation == "create" ? { for host in ansible_host.nodes : host.name => host } : {}
  playbook   = "./playbooks/add-loop-osd.yml"
  name       = each.value.name
  replayable = false
  extra_vars = {
    loop_drives_size  = each.value.variables.loop_drives_size
    loop_drives_count = each.value.variables.loop_drives_count
  }
}