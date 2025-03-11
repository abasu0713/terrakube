resource "ansible_playbook" "install_and_hold_ceph" {
  depends_on = [ansible_playbook.swap_off]
  for_each   = var.cluster_operation == "create" ? { for host in ansible_group.ceph_cluster_group.children : host => host } : {}
  playbook   = "./playbooks/install-ceph.yml"
  name       = each.key
  replayable = false
}

resource "ansible_playbook" "bootstrap_ceph" {
  count      = var.cluster_operation == "create" ? 1 : 0
  depends_on = [ansible_playbook.install_and_hold_ceph]
  playbook   = "./playbooks/bootstrap.yml"
  name       = ansible_group.ceph_cluster_group.children.0
  replayable = false
}

resource "ansible_playbook" "add_nodes" {
  depends_on = [ansible_playbook.bootstrap_ceph]
  for_each   = var.cluster_operation == "create" ? { for node in slice(ansible_group.ceph_cluster_group.children, 1, length(ansible_group.ceph_cluster_group.children)) : node => node } : {}
  playbook   = "./playbooks/add-nodes.yml"
  name       = ansible_group.ceph_cluster_group.children.0
  extra_vars = {
    worker_node = each.key
  }
  replayable = false
  verbosity  = 1
}

resource "ansible_playbook" "join_cluster" {
  depends_on = [ansible_playbook.add_nodes]
  for_each   = var.cluster_operation == "create" ? { for node, _ in ansible_playbook.add_nodes : node => node } : {}
  playbook   = "./playbooks/join-cluster.yml"
  name       = each.key
  replayable = false
  extra_vars = {
    join_token = "${element(element(regexall("\"stdout_lines\": \\[\"([^\"]+)\"\\]", ansible_playbook.add_nodes[each.key].ansible_playbook_stdout), 0), 0)}"
  }
}