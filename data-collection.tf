resource "azurerm_monitor_data_collection_rule" "vminsights" {
  name                        = "ts-test-bootcamp-dcr"
  resource_group_name         = azurerm_resource_group.bootcamp_rg.name
  location                    = azurerm_resource_group.bootcamp_rg.location

  data_flow {
    destinations = [ "log-analytics" ]
    streams      = [ "Microsoft-Event" ]
  }

  data_flow {
    destinations = [ "log-analytics" ]
    streams      = [ "Microsoft-InsightsMetrics" ]
  }

  data_flow {
    destinations = [ "log-analytics" ]
    streams      = [ "Microsoft-ServiceMap" ]
  }

  # data_flow {
  #   destinations = [ "monitor-metrics" ]
  #   streams      = [ "Microsoft-InsightsMetrics" ]
  # }

  data_sources {
    extension {
      extension_name     = "DependencyAgent"
      name               = "DependencyAgentDataSource"
      streams            = [ "Microsoft-ServiceMap" ]
    }

    performance_counter {
      counter_specifiers            = [ "\\VmInsights\\DetailedMetrics" ]
      name                          = "insights-metrics"
      sampling_frequency_in_seconds = 60
      streams                       = [
        "Microsoft-InsightsMetrics"
      ]
    }

    windows_event_log {
      name           = "windows-events"
      streams        = [ "Microsoft-Event" ]
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