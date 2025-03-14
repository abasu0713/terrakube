resource "ansible_playbook" "configure_external_ceph" {
    depends_on = [ ansible_playbook.enable_addons ]
    count = local.configure_external_ceph ? 1 : 0
    playbook = "./playbooks/configure-external-ceph.yml"
    name = ansible_group.k8s_cluster_group.children.0
    replayable = false
}