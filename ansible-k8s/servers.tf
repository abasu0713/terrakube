resource "ansible_host" "k8s_cluster_hosts" {
  for_each = { for server in var.servers : server.name => server }

  name   = each.value.name
  groups = ["microk8s-cluster"]
  variables = {
    ansible_host = each.value.ip
    ansible_user = each.value.ansible_user
  }
}

resource "ansible_group" "k8s_cluster_group" {
  name     = "microk8s-cluster"
  children = [for h in ansible_host.k8s_cluster_hosts : h.name]
}