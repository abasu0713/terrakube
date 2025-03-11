resource "ansible_playbook" "swap_off" {
  for_each   = var.cluster_operation == "create" ? { for host in ansible_group.ceph_cluster_group.children : host => host } : {}
  playbook   = "./playbooks/swap-off.yml"
  name       = each.key
  replayable = false
}