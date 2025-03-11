resource "ansible_playbook" "enable_rgw" {
  depends_on = [
    ansible_playbook.add_osd,
    ansible_playbook.add_loop_osd
  ]
  for_each   = var.enable_rgw && var.cluster_operation == "create" ? { for host in ansible_group.rgw_group.children : host => host } : {}
  playbook   = "./playbooks/enable-rgw.yml"
  name       = each.key
  replayable = false
}

resource "ansible_playbook" "create_rgw_admin_ops_user" {
    count = var.enable_rgw && var.cluster_operation == "create" ? 1 : 0 
    depends_on = [ ansible_playbook.enable_rgw ]
    playbook = "./playbooks/create-rgw-admin.yml"
    name = ansible_group.rgw_group.children.0
    replayable = false
    extra_vars = {
      rgw_admin_uid = "${var.rgw_admin_uid}"
    }
}

resource "ansible_playbook" "create_rgw_account_and_root_user" {
    count = var.enable_rgw && var.cluster_operation == "create"  ? 1 : 0
    depends_on = [ ansible_playbook.enable_rgw ]
    playbook = "./playbooks/rgw-account-ops.yml"
    name = ansible_group.rgw_group.children.0
    replayable = false
    extra_vars = {
      account_name = "${var.rgw_account.name}"
      account_email = "${var.rgw_account.email}"
      account_root_uid = "${var.rgw_account.root_uid}"
      account_root_display_name = "${var.rgw_account.root_uDisplayName}"
    }
}