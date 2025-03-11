resource "ansible_playbook" "generate_admin_keyring" {
  count = var.cluster_operation == "create" ? 1 : 0
  depends_on = [
    ansible_playbook.add_nodes
  ]
  playbook   = "./playbooks/generate-admin-keyring.yml"
  name       = ansible_group.ceph_cluster_group.children.0
  replayable = false
}

resource "ansible_playbook" "generate_ceph_minimal_conf" {
  count = var.cluster_operation == "create" ? 1 : 0
  depends_on = [
    ansible_playbook.add_nodes
  ]
  playbook   = "./playbooks/generate-minimal-conf.yml"
  name       = ansible_group.ceph_cluster_group.children.0
  replayable = false
}