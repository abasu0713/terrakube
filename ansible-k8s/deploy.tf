# resource "ansible_playbook" "install_microk8s" {
#   for_each   = var.cluster_operation == "create" ? { for host in ansible_group.k8s_cluster_group.children : host => host } : {}
#   playbook   = "./playbooks/install-microk8s.yml"
#   name       = each.key
#   replayable = false
#   timeouts {
#     create = "5m"
#   }
# }

# resource "ansible_playbook" "add_node_1" {
#   depends_on = [ansible_playbook.install_microk8s]
# #   for_each   = var.cluster_operation == "create" ? { for node in slice(ansible_group.k8s_cluster_group.children, 1, length(ansible_group.k8s_cluster_group.children)) : node => node } : {}
#   playbook   = "./playbooks/add-node.yml"
#   name       = ansible_group.k8s_cluster_group.children.0
#   replayable = false
#   verbosity  = 1
# }

# resource "ansible_playbook" "join_cluster_node1" {
#   depends_on = [
#     ansible_playbook.add_node_1
#     ]
# #   for_each   = var.cluster_operation == "create" ? { for node, _ in ansible_playbook.add_nodes : node => node } : {}
#   playbook   = "./playbooks/join-cluster.yml"
#   name       = ansible_group.k8s_cluster_group.children.1
#   replayable = false
#   extra_vars = {
#     join_token = "${element(element(regexall("microk8s join ([^\\s]+/[a-f0-9]+)", ansible_playbook.add_node_1.ansible_playbook_stdout), 0), 0)}"
#   }
# }

# resource "time_sleep" "wait_15_secs_after_join_node1" {
#   depends_on = [ansible_playbook.join_cluster_node1]

#   create_duration = "15s"
# }


# resource "ansible_playbook" "add_node_2" {
#   depends_on = [time_sleep.wait_15_secs_after_join_node1]
# #   for_each   = var.cluster_operation == "create" ? { for node in slice(ansible_group.k8s_cluster_group.children, 1, length(ansible_group.k8s_cluster_group.children)) : node => node } : {}
#   playbook   = "./playbooks/add-node.yml"
#   name       = ansible_group.k8s_cluster_group.children.0
#   replayable = false
#   verbosity  = 1
# }

# resource "ansible_playbook" "join_cluster_node2" {
#   depends_on = [
#     ansible_playbook.add_node_2
#   ]
# #   for_each   = var.cluster_operation == "create" ? { for node, _ in ansible_playbook.add_nodes : node => node } : {}
#   playbook   = "./playbooks/join-cluster.yml"
#   name       = ansible_group.k8s_cluster_group.children.2
#   replayable = false
#   extra_vars = {
#     join_token = "${element(element(regexall("microk8s join ([^\\s]+/[a-f0-9]+)", ansible_playbook.add_node_2.ansible_playbook_stdout), 0), 0)}"
#   }
# }

# resource "time_sleep" "wait_15_secs_after_join_node2" {
#   depends_on = [ansible_playbook.join_cluster_node2]

#   create_duration = "15s"
# }

# resource "ansible_playbook" "add_node_3" {
#   depends_on = [time_sleep.wait_15_secs_after_join_node2]
# #   for_each   = var.cluster_operation == "create" ? { for node in slice(ansible_group.k8s_cluster_group.children, 1, length(ansible_group.k8s_cluster_group.children)) : node => node } : {}
#   playbook   = "./playbooks/add-node.yml"
#   name       = ansible_group.k8s_cluster_group.children.0
#   replayable = false
#   verbosity  = 1
# }


# resource "ansible_playbook" "join_cluster_node3" {
#   depends_on = [
#     ansible_playbook.add_node_3
#   ]
# #   for_each   = var.cluster_operation == "create" ? { for node, _ in ansible_playbook.add_nodes : node => node } : {}
#   playbook   = "./playbooks/join-cluster.yml"
#   name       = ansible_group.k8s_cluster_group.children.3
#   replayable = false
#   extra_vars = {
#     join_token = "${element(element(regexall("microk8s join ([^\\s]+/[a-f0-9]+)", ansible_playbook.add_node_3.ansible_playbook_stdout), 0), 0)}"
#   }
# }

# resource "time_sleep" "wait_15_secs_after_join_node3" {
#   depends_on = [ansible_playbook.join_cluster_node3]

#   create_duration = "15s"
# }

resource "ansible_playbook" "install_microk8s" {
  for_each   = var.cluster_operation == "create" ? { for host in ansible_group.k8s_cluster_group.children : host => host } : {}
  playbook   = "./playbooks/install-microk8s.yml"
  name       = each.key
  replayable = false
  timeouts {
    create = "5m"
  }
}

resource "ansible_playbook" "add_nodes" {
  depends_on = [ansible_playbook.install_microk8s]
  count      = var.cluster_operation == "create" && length(ansible_group.k8s_cluster_group.children) > 1 ? length(ansible_group.k8s_cluster_group.children) - 1 : 0
  playbook   = "./playbooks/add-node.yml"
  name       = ansible_group.k8s_cluster_group.children.0
  replayable = false
  verbosity  = 1
}

resource "ansible_playbook" "join_cluster" {
  depends_on = [ansible_playbook.add_nodes]
  count      = var.cluster_operation == "create" && length(ansible_group.k8s_cluster_group.children) > 1 ? length(ansible_group.k8s_cluster_group.children) - 1 : 0
  playbook   = "./playbooks/join-cluster.yml"
  name       = ansible_group.k8s_cluster_group.children[count.index + 1]
  replayable = false
  extra_vars = {
    join_token = "${element(element(regexall("microk8s join ([^\\s]+/[a-f0-9]+)", element(ansible_playbook.add_nodes.*.ansible_playbook_stdout, count.index)), 0), 0)}"
  }
}