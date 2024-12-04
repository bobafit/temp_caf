# Use variables to customize the deployment

variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
  default     = "ips"
}

variable "root_name" {
  type        = string
  description = "Sets the value used for the \"intermediate root\" management group display name."
  default     = "Idemia Public Security"
}

variable "location" {
  type        = string
  description = "Sets the location for resources to be created in."
  default     = "westeurope"
}

variable "cpe_cmdb_file" {
  type        = string
  description = "cmdb file to load"
  default = "./subscription_management_dev.json"
}



locals {
  # cpe_cmdb_dev = jsondecode(file("lib/cpe_cmdb_dev.json"))
  # cpe_cmdb_prd = jsondecode(file("lib/cpe_cmdb_prd.json"))
  cpe_cmdb = jsondecode(file(var.cpe_cmdb_file))
  test = jsondecode(file("./project_list.json"))
  archetype_definition_cpe_root = {}

}
















variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
  default     = "northeurope"
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
  default     = ""
}

variable "subscription_id_identity" {
  type        = string
  description = "Subscription ID to use for \"identity\" resources."
  default     = ""
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = "f7e5670c-46ea-4c17-b593-425c8b8cba08"
}

variable "email_security_contact" {
  type        = string
  description = "Set a custom value for the security contact email address."
  default     = "test.user@replace_me"
}

variable "log_retention_in_days" {
  type        = number
  description = "Set a custom value for how many days to store logs in the Log Analytics workspace."
  default     = 60
}

variable "enable_ddos_protection" {
  type        = bool
  description = "Controls whether to create a DDoS Network Protection plan and link to hub virtual networks."
  default     = false
}

variable "connectivity_resources_tags" {
  type        = map(string)
  description = "Specify tags to add to \"connectivity\" resources."
  default = {
    deployedBy = "terraform/azure/caf-enterprise-scale/examples/l400-multi"
    demo_type  = "Deploy connectivity resources using multiple module declarations"
  }
}

variable "management_resources_tags" {
  type        = map(string)
  description = "Specify tags to add to \"management\" resources."
  default = {
    deployedBy = "terraform/azure/caf-enterprise-scale/examples/l400-multi"
    demo_type  = "Deploy management resources using multiple module declarations"
  }
}

variable "subscription_id" {
  type = string
  default = "f7e5670c-46ea-4c17-b593-425c8b8cba08"
}
