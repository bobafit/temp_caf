data "azurerm_subscriptions" "lists" {
  for_each              = toset(flatten([for k in local.cpe_cmdb : k.subscription_list]))
  display_name_contains = each.value
}

locals {
  sub_ids = { for subname, details in data.azurerm_subscriptions.lists : subname => join("", [for sub in details.subscriptions : sub.subscription_id if sub.display_name == subname]) }
  lists_of_ids = { for cat, cat_details in local.cpe_cmdb : cat => [for subname in cat_details.subscription_list : local.sub_ids[subname]] }
  platform = "platform"
}

output "sub_list" {
  value = data.azurerm_subscriptions.lists
}


output "sub_ids" {
  value = local.sub_ids
}

output "sub_id_list" {
  value = local.lists_of_ids
}