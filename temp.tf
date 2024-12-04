# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.

data "azurerm_subscriptions" "lists" {
  for_each              = toset(flatten([for k in local.cpe_cmdb : k]))
  display_name_contains = each.value
}

locals {
  sub_ids = { for subname, details in data.azurerm_subscriptions.lists : subname => join("", [for sub in details.subscriptions : sub.subscription_id if sub.display_name == subname]) }
  lists_of_ids = { for cat, subs in local.cpe_cmdb : cat => [for subname in subs : local.sub_ids[subname]] }
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.2.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = var.location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
  library_path   = "${path.root}/lib"

  deploy_core_landing_zones = false
  custom_landing_zones = {


    (var.root_id) = {
      display_name               = var.root_name
      parent_management_group_id = data.azurerm_client_config.core.tenant_id
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "root_entity"
        parameters     = {}
        access_control = {}
      }
    }

    "platform" = {
      display_name               = "Platform"
      parent_management_group_id = var.root_id
      subscription_ids           = local.lists_of_ids.platform
      archetype_config = {
        archetype_id   = "platform"
        parameters     = {}
        access_control = {}
      }
    }

    "projects" = {
      display_name               = "Projects"
      parent_management_group_id = var.root_id
      subscription_ids           = local.lists_of_ids.projects
      archetype_config = {
        archetype_id   = "projects"
        parameters     = {}
        access_control = {}
      }
    }

    

    "training" = {
      display_name               = "Training"
      parent_management_group_id = var.root_id
      subscription_ids           = local.lists_of_ids.training
      archetype_config = {
        archetype_id   = "training"
        parameters     = {}
        access_control = {}
      }
    }

    "decommissioned" = {
      display_name               = "Decommissioned"
      parent_management_group_id = var.root_id
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "decommissioned"
        parameters     = {}
        access_control = {}
      }
    }

    "crowdstrike-platform" = {
      display_name               = "Crowdstrike Deployment - Platform"
      parent_management_group_id = "platform"
      subscription_ids           = local.lists_of_ids.crowdstrike_platform
      archetype_config = {
        archetype_id   = "crowdstrike-platform"
        parameters     = {}
        access_control = {}
      }
    }

  }
}


# module "nested_lz" {
#   for_each = toset(local.project_list)
#   source  = "./modules/nested_lz"

#   project = each.value
#   lists_of_ids = local.lists_of_ids
#   root_id = var.root_id

#   providers = {
#     azurerm = azurerm
#   }


#   depends_on = [
#     module.enterprise_scale,
#   ]
# }



# variable "landing_zones" {
#   type = map(object({
#     display_name = string
#     parent_management_group_id = string
#     subscription_ids = list(string)
#     archetype_config = map(any)
#   }))
# }

variable "landing_zones" {
  default = {
    "default_dev" = {
      display_name = "Landing Zone 1"
      parent_management_group_id = "mgmt-group-1"
      subscription_ids = ["sub-id-1", "sub-id-2"]
      archetype_config = {
        archetype_id = "archetype-1"
        parameters = {
          param1 = "value1"
          param2 = "value2"
        }
      }
    }
    "landing_zone_2" = {
      display_name = "Landing Zone 2"
      parent_management_group_id = "mgmt-group-2"
      subscription_ids = ["sub-id-3"]
      archetype_config = {
        archetype_id = "archetype-2"
        parameters = {
          param1 = "value3"
          param2 = "value4"
        }
      }
    }
  }
}

module "enterprise_scale_nested_landing_zone" {
  source = "Azure/caf-enterprise-scale/azurerm"
  version = "<version>"

  for_each = var.landing_zones

  root_parent_id = "${each.value.parent_management_group_id}"
  root_id = each.key
  deploy_core_landing_zones = false
  library_path = "${path.root}/lib"
  custom_landing_zones = {
    "${each.key}-module-instance" = {
      display_name = each.value.display_name
      parent_management_group_id = each.value.parent_management_group_id
      subscription_ids = each.value.subscription_ids
      archetype_config = each.value.archetype_config
    }
  }
  depends_on = [module.enterprise_scale]
}



module "enterprise_scale_nested_landing_zone" {
  for_each = toset(local.project_list)

  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.2.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = var.location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }


  root_parent_id            = "project"
  root_id                   = var.root_id
  deploy_core_landing_zones = false
  library_path              = "${path.root}/lib"

  custom_landing_zones = {
    "${each.value}-prd" = {
      display_name               = "${each.value} project - PRD & STG env"
      parent_management_group_id = "projects"
      subscription_ids           = local.lists_of_ids["${each.value}_prd"]
      archetype_config = {
        archetype_id   = "prd"
        parameters     = {}
        access_control = {}
      }
    }

    "${each.value}-dev" = {
      display_name               = "${each.value} project - DEV"
      parent_management_group_id = "projects"
      subscription_ids           = local.lists_of_ids["${each.value}_dev"]
      archetype_config = {
        archetype_id   = "dev"
        parameters     = {}
        access_control = {}
      }
    }

    "${each.value}-crowdstrike" = {
      display_name               = "${each.value} project -Crowdstrike Deployment"
      parent_management_group_id = "projects"
      subscription_ids           = local.lists_of_ids["${each.value}_crowdstrike"]
      archetype_config = {
        archetype_id   = "crowdstrike"
        parameters     = {}
        access_control = {}
      }
    }
  }

  depends_on = [
    module.enterprise_scale,
  ]

}