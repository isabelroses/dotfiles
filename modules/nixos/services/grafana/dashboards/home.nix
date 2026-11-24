{ d }:
let
  inherit (d)
    q
    rate
    stat
    timeseries
    bargauge
    timeline
    heading
    ;

  sensor = name: "homeassistant_sensor_${name}";
in
d.dashboard {
  uid = "home";
  title = "Home";
  time = "now-24h";
  tags = [
    "fleet"
    "home"
  ];
  variables = [ ];

  rows = [
    [
      (stat {
        title = "Unavailable entities";
        w = 6;
        targets = [ (q "count(homeassistant_entity_available == 0) or vector(0)" "unavailable") ];
        thresholds = {
          orange = 1;
          red = 10;
        };
      })
      (stat {
        title = "Updates waiting";
        w = 6;
        targets = [ (q "sum(homeassistant_update_state)" "updates") ];
        thresholds.blue = 1;
      })
      (stat {
        title = "Ads blocked today";
        w = 6;
        unit = "percent";
        targets = [
          (q ''100 * sum(${sensor "unit_ads"}) / sum(${sensor "unit_queries"}{friendly_name="Pi-hole DNS queries"})'' "blocked")
        ];
      })
      (stat {
        title = "CO₂";
        w = 6;
        unit = "ppm";
        targets = [ (q (sensor "carbon_dioxide_ppm") "{{friendly_name}}") ];
        thresholds = {
          orange = 1000;
          red = 1400;
        };
      })
    ]

    [ (heading "Air") ]
    [
      (timeseries {
        title = "Temperature";
        w = 8;
        unit = "celsius";
        targets = [
          (q ''${sensor "temperature_celsius"}{friendly_name!~".*Battery.*"}'' "{{friendly_name}}")
        ];
      })
      (timeseries {
        title = "Humidity";
        w = 8;
        unit = "percent";
        targets = [ (q (sensor "humidity_percent") "{{friendly_name}}") ];
      })
      (timeseries {
        title = "CO₂ and PM2.5";
        w = 8;
        targets = [
          (q (sensor "carbon_dioxide_ppm") "{{friendly_name}} ppm")
          (q (sensor "pm25_u0xb5g_per_mu0xb3") "{{friendly_name}} µg/m³")
        ];
      })
    ]

    [ (heading "Outlets") ]
    [
      (timeline {
        title = "Power strip outlets";
        w = 24;
        h = 7;
        targets = [
          (q ''homeassistant_switch_state{friendly_name=~".*power (cord|extender).*"}'' "{{friendly_name}}")
        ];
      })
    ]
    [
      (timeseries {
        title = "Mains voltage";
        unit = "volt";
        targets = [
          (q ''avg by (device) (label_replace(${sensor "voltage_v"}{friendly_name=~".*Effective voltage.*"}, "device", "$1", "friendly_name", "(.*) Effective.*"))'' "{{device}}")
        ];
      })
      (timeseries {
        title = "Current draw";
        unit = "amp";
        stack = true;
        targets = [ (q (sensor "current_a") "{{friendly_name}}") ];
      })
    ]

    [ (heading "Network") ]
    [
      (timeseries {
        title = "Router throughput";
        w = 8;
        unit = "Mbits";
        targets = [
          (q ''${sensor "data_rate_mbit_per_s"}{friendly_name=~".*Total.*"}'' "{{friendly_name}}")
        ];
      })
      (timeseries {
        title = "DNS queries today";
        w = 8;
        targets = [
          (q (sensor "unit_queries") "{{friendly_name}}")
          (q (sensor "unit_ads") "{{friendly_name}}")
        ];
      })
      (timeseries {
        title = "Clients";
        w = 8;
        targets = [
          (q (sensor "unit_clients") "{{friendly_name}}")
        ];
      })
    ]

    [ (heading "Services, as gatus reports them to home assistant") ]
    [
      (timeline {
        title = "Endpoint checks";
        w = 24;
        h = 10;
        on = "up";
        off = "down";
        offColor = "red";
        targets = [
          (q ''homeassistant_binary_sensor_state{friendly_name=~"^(apps|dev|mail|social|web) .*"}'' "{{friendly_name}}")
        ];
      })
    ]

    [ (heading "Batteries and activity") ]
    [
      (bargauge {
        title = "Batteries";
        w = 8;
        unit = "percent";
        targets = [ (q (sensor "battery_percent") "{{friendly_name}}") ];
        thresholds = {
          base = "red";
          orange = 20;
          green = 40;
        };
      })
      (timeseries {
        title = "State changes per minute";
        w = 8;
        stack = true;
        targets = [ (q "60 * sum by (domain) (${rate "homeassistant_state_change_total"})" "{{domain}}") ];
      })
      (timeseries {
        title = "Automations fired";
        w = 8;
        stack = true;
        targets = [
          (q "sum by (friendly_name) (increase(homeassistant_automation_triggered_count_total[1h]))" "{{friendly_name}}")
        ];
      })
    ]
  ];
}
