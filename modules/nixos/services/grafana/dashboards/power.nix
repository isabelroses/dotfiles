{ d }:
let
  inherit (d)
    q
    stat
    timeseries
    heading
    ;

  h = ''host=~"$host"'';

  cpu = "sum by (host) (rate(node_rapl_package_joules_total{${h}}[$__rate_interval]))";
  gpu = "sum by (host) (nvidia_smi_power_draw_watts{${h}})";

  cpuEnergy = "sum by (host) (increase(node_rapl_package_joules_total{${h}}[$__range])) / 3.6e6";
  gpuEnergy = "sum by (host) (avg_over_time(nvidia_smi_power_draw_watts{${h}}[$__range])) * $__range_s / 3.6e6";
in
d.dashboard {
  uid = "power";
  title = "Power";
  time = "now-24h";

  rows = [
    [
      (stat {
        title = "CPU now";
        w = 6;
        unit = "watt";
        targets = [ (q cpu "{{host}}") ];
      })
      (stat {
        title = "GPU now";
        w = 6;
        unit = "watt";
        targets = [ (q gpu "{{host}}") ];
      })
      (stat {
        title = "CPU + GPU energy in range";
        w = 6;
        unit = "kwatth";
        targets = [ (q "${cpuEnergy} + (${gpuEnergy} or ${cpuEnergy} * 0)" "{{host}}") ];
      })
      (stat {
        title = "Wall energy in range";
        w = 6;
        unit = "kwatth";
        targets = [ (q "sum(increase(homeassistant_sensor_energy_kwh[$__range]))" "all plugs") ];
      })
    ]

    [ (heading "Measured by the hosts") ]
    [
      (timeseries {
        title = "CPU package";
        unit = "watt";
        targets = [ (q cpu "{{host}}") ];
      })
      (timeseries {
        title = "GPU board";
        unit = "watt";
        targets = [ (q gpu "{{host}}") ];
      })
    ]
    [
      (timeseries {
        title = "CPU + GPU, stacked";
        unit = "watt";
        stack = true;
        targets = [
          (q cpu "{{host}} cpu")
          (q gpu "{{host}} gpu")
        ];
      })
      (timeseries {
        title = "GPU load and temperature";
        unit = "percent";
        targets = [
          (q "100 * nvidia_smi_utilization_gpu_ratio{${h}}" "{{host}} load")
          (q "nvidia_smi_temperature_gpu{${h}}" "{{host}} °C")
        ];
      })
    ]

    [ (heading "At the wall") ]
    [
      (timeseries {
        title = "Smart plugs";
        unit = "watt";
        stack = true;
        targets = [ (q "homeassistant_sensor_power_w" "{{friendly_name}}") ];
      })
      (timeseries {
        title = "Plug energy per hour";
        unit = "kwatth";
        stack = true;
        targets = [
          (q "sum by (friendly_name) (increase(homeassistant_sensor_energy_kwh[1h]))" "{{friendly_name}}")
        ];
      })
    ]
  ];
}
