# data "azurerm_subscriptions" "lists" {
#   for_each              = toset(flatten([for k in local.all_subs : k]))
#   display_name_contains = each.value
# }

# locals {
#   sub_ids = { for subname, details in data.azurerm_subscriptions.lists : subname => join("", [for sub in details.subscriptions : sub.subscription_id if sub.display_name == subname]) }
#   lists_of_ids = { for cat, subs in local.all_subs : cat => [for subname in subs : local.sub_ids[subname]] }
# }



# output "sub_ids" {
#   value = local.sub_ids
# }

# output "lists_of_ids" {
#   value = local.lists_of_ids
# }


output "test" {
  value = local.test
}

output "core_subs" {
  value = local.core_subs
}

output "list_subs" {
  value = toset(flatten([for k in local.core_subs : k]))
}



locals {
  # subscription_id   = data.azurerm_subscription.current.subscription_id

  # # we define setup_managment_subscription and setup_security_subscription to true or false depending of the value of subscription_name variable
  # setup_managment_subscription = lower(var.subscription_name) == "all" || var.subscription_name == var.mgt_sub_name
  # setup_security_subscription = lower(var.subscription_name) == "all" || var.subscription_name == var.sec_sub_name
  
  core_sub_path = "./lib/subscriptions/baratotsuk"
  core_subs = jsondecode(file("${local.core_sub_path}/core.json"))
  projects_subs = {
    for jsonfile in fileset("${local.core_sub_path}/projects", "*.json") :
         replace(basename(jsonfile), ".json", "") => jsondecode(file("${local.core_sub_path}/projects/${jsonfile}"))
    
  }
  
  #create a map of all subscription per management group
  # all_subs = merge(local.core_subs,[for project,content in local.projects_subs : content]...)
  all_subs = merge(local.core_subs,{ projects = local.projects_subs})
  

  projects_list = [for key, value in local.projects_subs: key]

  # projects_subs_ids = { for project, mgts in local.projects_subs : project => {
  #   for mgt, subs in mgts : mgt =>  [for subname in subs : local.sub_ids[subname]] }}
  


  
  # {
  #   for jsonfile in fileset("${local.core_sub_path}/projects", "*.json") :
  #        replace(basename(jsonfile), ".json", "") => {
  #           for key, subs in jsondecode(file("${local.core_sub_path}/projects/${jsonfile}")) : 
  #           "${replace(basename(jsonfile), ".json", "")}_${key}" => [for subname in subs : local.sub_ids[subname]] 
  #       }
    
  # }




  # projects_list = jsondecode(file("./lib/subscriptions/nested_management_groups/project_list.json"))

  # subscription_list = (lower(var.subscription_name) == "core" ? [] : 
  #                     lower(var.subscription_name) == "all" ? flatten([for k in local.all_subs : k]) : 
  #                     [var.subscription_name])
}

output "projects_subs" {
  value = local.projects_subs
}

output "all_subs" {
  value = local.all_subs
  
}

output "projects_list" {
  value = local.projects_list
  
}

# output "projects_subs_ids" {
  
#   value = local.projects_subs_ids
# }