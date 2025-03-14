variable "servers" {
  type = list(object({
    name         = string
    ip           = string
    ansible_user = string
    labels       = map(string)
  }))
}

variable "cluster_operation" {
  type = string
  # add validation for allowed values: create, destroy
  validation {
    condition     = contains(["create", "destroy", "ping"], var.cluster_operation)
    error_message = "Invalid value for cluster_operation. Allowed values are create, destroy, ping."
  }
}

variable "addons" {
  type        = list(string)
  description = "List of addons to enable on the cluster"
}

variable "connect_external_ceph" {
  type        = bool
  description = "Connect to an external Ceph cluster"
}

locals {
  configure_external_ceph = contains(var.addons, "rook-ceph") && var.connect_external_ceph
}
