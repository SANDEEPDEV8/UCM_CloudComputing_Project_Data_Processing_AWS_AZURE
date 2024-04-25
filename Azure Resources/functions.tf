resource "azurerm_service_plan" "vehicle_iot_plan" {
  name                = "vehicle-iot-service-plan"
  resource_group_name = azurerm_resource_group.icc_project.name
  location            = azurerm_resource_group.icc_project.location
  os_type             = "Linux"
  sku_name            = "S1"
}
# data "archive_file" "python_function_package" {
#   type        = "zip"
#   source_file = "./processVehicleIotData.py"
#   output_path = "processVehicleIotData.zip"
# }


resource "azurerm_application_insights" "process_vehicle_landing_data_App_Insights" {
  name                = "process-vehicle-landing-data-App-Insights"
  location            = azurerm_resource_group.icc_project.location
  resource_group_name = azurerm_resource_group.icc_project.name
  application_type    = "Node.JS"
}

resource "azurerm_linux_function_app" "process_vehicle_landing_data" {
  name                       = "process-vehicle-iot-landing-data"
  resource_group_name        = azurerm_resource_group.icc_project.name
  location                   = azurerm_resource_group.icc_project.location
  storage_account_name       = azurerm_storage_account.icc_st_account.name
  storage_account_access_key = azurerm_storage_account.icc_st_account.primary_access_key
  service_plan_id            = azurerm_service_plan.vehicle_iot_plan.id
  https_only                 = true
  #   zip_deploy_file            = data.archive_file.python_function_package.output_path
  site_config {
    application_stack {
      # dotnet_version = "6.0"
      node_version = "18"
    }
    cors {
      allowed_origins = ["https://portal.azure.com"]
    }

    application_insights_connection_string = azurerm_application_insights.process_vehicle_landing_data_App_Insights.connection_string
    application_insights_key               = azurerm_application_insights.process_vehicle_landing_data_App_Insights.instrumentation_key
  }
  app_settings = {

  }

}

resource "azurerm_function_app_function" "process_vehicle_landing_data_func1" {
  name            = "IOTFunction1"
  function_app_id = azurerm_linux_function_app.process_vehicle_landing_data.id
  language        = "Javascript"

  test_data = jsonencode({
    "name" = "Azure"
  })


  config_json = jsonencode(
    {
      "bindings" : [
        {
          "authLevel" : "function",
          "direction" : "in",
          "name" : "input",
          "path" : "input-adls/landing/{name}",
          "storage_account_connection" : "iccstorageproject1",
          "type" : "blobTrigger",
          "connection" : "iccstorageproject1_STORAGE"
        },
        {
          "connection" : "iccstorageproject1_STORAGE",
          "direction" : "out",
          "methods" : [],
          "name" : "stagingFolder",
          "path" : "input-adls/staging/{rand-guid}.json",
          "type" : "blob"
        },
        {
          "connection" : "iccstorageproject1_STORAGE",
          "direction" : "out",
          "methods" : [],
          "name" : "rejectedFolder",
          "path" : "input-adls/rejected/{rand-guid}.json",
          "type" : "blob"
        }
      ]
    }
    # {

    # "bindings" = [
    #   {
    #     "authLevel" = "function"
    #     "direction" = "in"
    #     # "methods" = [
    #     #   "get",
    #     #   "post",
    #     # ]
    #     "name"                       = "inputBlob"
    #     "type"                       = "blobTrigger"
    #     "path"                       = "${azurerm_storage_data_lake_gen2_filesystem.icc_dl_filesys.name}/landing"
    #     "storage_account_connection" = "iccstorageproject1"
    #   },
    #   {
    #     "name" : "statgingfolder",
    #     "direction" : "out",
    #     "type" : "blob",
    #     "path" : "${azurerm_storage_data_lake_gen2_filesystem.icc_dl_filesys.name}/staging/{rand-guid}",
    #     "methods" : [],
    #     "connection" : "iccstorageproject1_STORAGE"
    #   },
    #   {
    #     "name" : "rejectedFolder",
    #     "direction" : "out",
    #     "type" : "blob",
    #     "path" : "${azurerm_storage_data_lake_gen2_filesystem.icc_dl_filesys.name}/rejectedFolder/{rand-guid}",
    #     "methods" : [],
    #     "connection" : "iccstorageproject1_STORAGE"
    #   }
    #   #   {
    #   #     "direction" = "out"
    #   #     "name"      = "$return"
    #   #     "type"      = "http"
    #   #   },
    # ]
    # }
  )
}


# resource "azurerm_function_app" "example" {
#   name                       = "example-functionapp"
#   location                   = azurerm_resource_group.icc_project.location
#   resource_group_name        = azurerm_resource_group.icc_project.name
#   app_service_plan_id        = azurerm_service_plan.vehicle_iot_plan.id
#   storage_account_name       = azurerm_storage_account.icc_st_account.name
#   storage_account_access_key = azurerm_storage_account.icc_st_account.primary_access_key
#   #   storage_connection_string = azurerm_storage_account.icc_st_account.primary_connection_string
# }
