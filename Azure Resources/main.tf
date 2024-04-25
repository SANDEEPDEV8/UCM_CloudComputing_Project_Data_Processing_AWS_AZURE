terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.94.0"
    }
  }
}
# az provider register --namespace Microsoft.Web
# resource "azurerm_resource_provider_registration" "web" {
#   name = "Microsoft.Web"
# }
resource "azurerm_resource_provider_registration" "EventGrid" {
  name = "Microsoft.EventGrid"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {

  }
}

# Create a resource group
resource "azurerm_resource_group" "icc_project" {
  name     = "icc-project-rg"
  location = "northcentralus"
}

resource "azurerm_storage_account" "icc_st_account" {
  name                     = "iccstorageproject1"
  resource_group_name      = azurerm_resource_group.icc_project.name
  location                 = azurerm_resource_group.icc_project.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true #Azure Data Lake Storage Gen 2 

  tags = {
    environment = "dev"
  }

}

resource "azurerm_storage_data_lake_gen2_filesystem" "icc_dl_filesys" {
  name               = "input-adls"
  storage_account_id = azurerm_storage_account.icc_st_account.id
  lifecycle {
    prevent_destroy = false
  }

}

# resource "azurerm_storage_data_lake_gen2_path" "landing_folder" {
#   path               = "landing"
#   filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.icc_dl_filesys.name
#   storage_account_id = azurerm_storage_account.icc_st_account.id
#   resource           = "directory"
#   depends_on         = [azurerm_storage_data_lake_gen2_filesystem.icc_dl_filesys]
# }

# resource "null_resource" "folder_destroy" {
#   triggers = {
#     storage_account_name = azurerm_storage_account.icc_st_account.name
#     filesystem           = azurerm_storage_data_lake_gen2_path.landing_folder.filesystem_name
# folder_path          = azurerm_storage_data_lake_gen2_path.adl2.path
# }

#   provisioner "local-exec" {
#     when        = destroy
#     command     = <<-EOT
#       az storage fs file list \
#         --auth-mode login \
#         --account-name '${self.triggers.storage_account_name}' \
#         --file-system '${self.triggers.filesystem}' \
#         --path '${self.triggers.folder_path}' \
#         --recursive false \
#         --output tsv \
#         --query '[].name' | \
#       tr -d '\r' | \
#       while read to_delete_name ; do 
#         echo "Removing item $to_delete_name from folder ${self.triggers.folder_path}"
#         az storage fs directory delete \
#         --auth-mode login \
#         --yes \
#         --account-name '${self.triggers.storage_account_name}' \
#         --file-system '${self.triggers.filesystem}' \
#         --name "$to_delete_name"
#       done
#     EOT
#     working_dir = path.module
#     interpreter = ["bash", "-c"]
#   }
# }
