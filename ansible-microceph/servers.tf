resource "ansible_group" "ceph_cluster_group" {
  name = "ceph-cluster"
  # children = [for h in ansible_host.ceph_cluster_hosts : h.name]
  children = [for h in ansible_host.nodes : h.name]
}

resource "ansible_group" "rgw_group" {
  name = "rgw-group"
  children = [for h in ansible_host.nodes : h.name if contains(var.rgw_nodes, h.name)]
}

resource "ansible_host" "nodes" {
  for_each = { for server in var.servers : server.name => server }

  name   = each.value.name
  groups = ["ceph-cluster"]
  variables = {
    ansible_host        = each.value.ip
    ansible_user        = each.value.ansible_user
    drives              = join(" ", each.value.drives)
    include_loop_drives = each.value.loop_drives.include
    loop_drives_size    = each.value.loop_drives.size
    loop_drives_count   = each.value.loop_drives.count
  }
}