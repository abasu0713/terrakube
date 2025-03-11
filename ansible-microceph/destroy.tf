resource "ansible_playbook" "destroy_ceph" {
  for_each   = var.cluster_operation == "destroy" ? { for host in ansible_group.ceph_cluster_group.children : host => host } : {}
  playbook   = "./playbooks/destroy-cluster.yml"
  name       = each.key
  replayable = true
}