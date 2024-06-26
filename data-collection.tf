resource "azurerm_monitor_data_collection_rule" "vminsights" {
  name                = "${var.naming-prefix}-dcr"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  location            = azurerm_resource_group.bootcamp_rg.location
  tags                = var.tags

  data_flow {
    destinations = ["log-analytics"]
    streams      = ["Microsoft-Event"]
  }

  data_flow {
    destinations = ["log-analytics"]
    streams      = ["Microsoft-InsightsMetrics"]
  }

  data_flow {
    destinations = ["log-analytics"]
    streams      = ["Microsoft-ServiceMap"]
  }


  data_sources {
    extension {
      extension_name = "DependencyAgent"
      name           = "DependencyAgentDataSource"
      streams        = ["Microsoft-ServiceMap"]
    }

    performance_counter {
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "insights-metrics"
      sampling_frequency_in_seconds = 60
      streams = [
        "Microsoft-InsightsMetrics"
      ]
    }

    windows_event_log {
      name    = "windows-events"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }
  }

  destinations {

    log_analytics {
      name                  = "log-analytics"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vminsights" {
  name                    = "${var.naming-prefix}-dcra"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vminsights.id
  description             = "Monitor VM"
  target_resource_id      = azurerm_windows_virtual_machine.win_vm.id
}