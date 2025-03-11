variable "servers" {
  type = list(object({
    name         = string
    ip           = string
    ansible_user = string
    drives       = list(string)
    loop_drives = object({
      include = bool
      size    = string
      count   = number
    })
  }))
}

variable "cluster_operation" {
  type = string
  # add validation for allowed values: create, destroy
  validation {
    condition     = contains(["create", "destroy"], var.cluster_operation)
    error_message = "Invalid value for cluster_operation. Allowed values are create, destroy."
  }
}

variable "rgw_nodes" {
  type = list(string)
}

variable "rgw_admin_uid" {
  type    = string
}

variable "enable_rgw" {
  type    = bool
  default = true
}

variable "rgw_account" {
  type    = object({
    name = string
    email = string
    root_uid = string
    root_uDisplayName = string
  })
}

locals {
  bootstrap_node = element(var.servers, 0)
  worker_nodes   = slice(var.servers, 1, length(var.servers))
}