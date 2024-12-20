variable "subscription_name" {
  default = "Maishi_mgt"
}

locals {
  core_subs = jsondecode(file("${path.module}/core.json"))
  projects_subs = {
    for jsonfile in fileset("${path.module}/projects", "*.json") :
        # jsondecode(file("${path.module}/*/${jsonfile}"))
         replace(basename(jsonfile), ".json", "") => {
            for key, value in jsondecode(file("${path.module}/projects/${jsonfile}")) : 
            "${replace(basename(jsonfile), ".json", "")}_${key}" => value
        }
    
  }

  all_subs = merge(local.core_subs,[for content in local.projects_subs : content]...)

  projects_list = [for key, value in local.projects_subs: key]

  subscription_list = (lower(var.subscription_name) == "core" ? [] : 
                      lower(var.subscription_name) == "all" ? flatten([for k in local.all_subs : k]) : 
                      [var.subscription_name])

}

output "projects_subs" {
  value = [for key, value in local.projects_subs: key]
}

output "file_list" {
  value = flatten([for k in merge(local.core_subs,[for content in local.projects_subs : content]...) : k])
}