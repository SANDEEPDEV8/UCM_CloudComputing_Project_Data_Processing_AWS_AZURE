resource "azurerm_data_factory_custom_dataset" "s3_vehicle_data_json_ds" {
  name            = "s3_vehicle_data_json_ds"
  data_factory_id = azurerm_data_factory.icc_adf.id
  type            = "Json"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.icc_adf_la_to_s3.name
    parameters = {
      key1 = "value1"
    }
  }
  parameters = {
    s3folderPath : "@concat(formatDateTime(utcNow(),'yyyy'),'/',formatDateTime(utcNow(),'MM'),'/',formatDateTime(utcNow(),'dd'),'/')"
  }
  type_properties_json = <<JSON
{
  "location": {
    "type": "AmazonS3Location",
                "bucketName": "iotvehicledata5566",
                "folderPath": "@dataset().s3folderPath",
                "fileName": "Customer_Valid.json"
  },
  "encodingName":"UTF-8"
}
JSON

}

resource "azurerm_data_factory_dataset_json" "adls_landing_ds" {
  name                = "adls_landing_ds"
  data_factory_id     = azurerm_data_factory.icc_adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_to_adls_ls.name

  azure_blob_storage_location {
    container = "input-adls"
    path      = "@dataset().landingFolder"
    filename  = ""
  }
  //@concat('landing/',formatDateTime(utcNow(),'yyyy'),'/',formatDateTime(utcNow(),'MM'),'/',formatDateTime(utcNow(),'dd'),'/')
  parameters = {
    landingFolder = ""
  }
  encoding = "UTF-8"
}

resource "azurerm_data_factory_dataset_json" "adls_staging_ds" {
  name                = "adls_staging_ds"
  data_factory_id     = azurerm_data_factory.icc_adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_to_adls_ls.name

  azure_blob_storage_location {
    container = "input-adls"
    path      = "staging"
    filename  = ""
  }
  //@concat('landing/',formatDateTime(utcNow(),'yyyy'),'/',formatDateTime(utcNow(),'MM'),'/',formatDateTime(utcNow(),'dd'),'/')
  # parameters = {
  #   landingFolder = ""
  # }
  encoding = "UTF-8"
}

resource "azurerm_data_factory_dataset_sql_server_table" "icc_vehicle_sql_ds" {
  name                = "icc_vehicle_sql_ds"
  data_factory_id     = azurerm_data_factory.icc_adf.id
  linked_service_name = azurerm_data_factory_linked_service_azure_sql_database.adf_to_sql_ls.name
  table_name          = "VehicleData1"
}

resource "azurerm_data_factory_pipeline" "icc_data_copy_s3_to_adls" {
  name            = "icc-data-copy-s3-adls"
  data_factory_id = azurerm_data_factory.icc_adf.id
  variables = {
    "bob" = "item1"
  }
  activities_json = <<JSON
[
    {
                "name": "Copy data1",
                "type": "Copy",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "source": {
                        "type": "JsonSource",
                        "storeSettings": {
                            "type": "AmazonS3ReadSettings",
                            "recursive": true,
                            "enablePartitionDiscovery": false
                        },
                        "formatSettings": {
                            "type": "JsonReadSettings"
                        }
                    },
                    "sink": {
                        "type": "JsonSink",
                        "storeSettings": {
                            "type": "AzureBlobFSWriteSettings"
                        },
                        "formatSettings": {
                            "type": "JsonWriteSettings"
                        }
                    },
                    "enableStaging": false
                },
                "inputs": [
                    {
                        "referenceName": "${azurerm_data_factory_custom_dataset.s3_vehicle_data_json_ds.name}",
                        "type": "DatasetReference",
                        "parameters": {
                            "aaaa": "aaaa"
                        }
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "adls_landing_ds",
                        "type": "DatasetReference",
                        "parameters": {
                            "landingFolder": {
                                "value": "@concat('landing/',formatDateTime(utcNow(),'yyyy'),'/',formatDateTime(utcNow(),'MM'),'/',formatDateTime(utcNow(),'dd'),'/')",
                                "type": "Expression"
                            }
                        }
                    }
                ]
            }
]
  JSON
}

# resource "azurerm_data_factory_trigger_blob_event" "alds_sql_trigger_for_staging_json" {
#   name                  = "alds-sql-trigger-for-staging-json"
#   data_factory_id       = azurerm_data_factory.icc_adf.id
#   storage_account_id    = azurerm_storage_account.icc_st_account.id
#   events                = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobDeleted"]
#   blob_path_begins_with = "input-adls/staging"
#   blob_path_ends_with   = ".json"
#   ignore_empty_blobs    = true
#   activated             = true
#   additional_properties = {

#   }
#   pipeline {
#     name = azurerm_data_factory_pipeline.icc_data_copy_adls_to_sql.name
#   }
# }


resource "azurerm_data_factory_pipeline" "icc_data_copy_adls_to_sql" {
  name            = "icc-data-copy-adls-to-sql"
  data_factory_id = azurerm_data_factory.icc_adf.id
  variables = {
    "bob" = "item1"
  }
  activities_json = <<JSON
[
            {
                "name": "copy-adls-to-sql",
                "type": "Copy",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "source": {
                        "type": "JsonSource",
                        "storeSettings": {
                            "type": "AzureBlobFSReadSettings",
                            "recursive": true,
                            "wildcardFileName": "*.json",
                            "enablePartitionDiscovery": false
                        },
                        "formatSettings": {
                            "type": "JsonReadSettings"
                        }
                    },
                    "sink": {
                        "type": "SqlServerSink",
                        "writeBehavior": "insert",
                        "sqlWriterUseTableLock": false
                    },
                    "enableStaging": false
                },
                "inputs": [
                    {
                        "referenceName": "adls_staging_ds",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "icc_vehicle_sql_ds",
                        "type": "DatasetReference"
                    }
                ]
            }
        ]
  JSON
}
