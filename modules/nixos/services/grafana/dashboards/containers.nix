{ d }:
let
  inherit (d)
    q
    rate
    stat
    timeseries
    logs
    heading
    ;

  # cadvisor reports the host's own cgroups too, which have no name
  c = ''name!="", host=~"$host"'';
  docker = ''job="docker", host=~"$host"'';

  # error and above, by the level fluent-bit parses out of each line
  errors = ''${docker}, level=~"error|fatal"'';
in
d.dashboard {
  uid = "containers";
  title = "Containers";
  variables = [ (d.hostVariable d.prometheus "label_values(container_last_seen, host)") ];

  rows = [
    [
      (stat {
        title = "Running";
        w = 8;
        targets = [ (q "count by (host) (container_last_seen{${c}})" "{{host}}") ];
      })
      (stat {
        title = "Error lines in range";
        w = 8;
        datasource = d.loki;
        targets = [ (q "sum(count_over_time({${errors}} [$__range])) or vector(0)" "errors") ];
        thresholds.orange = 1;
      })
      (stat {
        title = "OOM kills in range";
        w = 8;
        targets = [ (q "sum(increase(container_oom_events_total{${c}}[$__range])) or vector(0)" "oom") ];
        thresholds.red = 1;
      })
    ]

    [ (heading "Resources") ]
    [
      (timeseries {
        title = "CPU (cores)";
        targets = [ (q "sum by (name) (${rate "container_cpu_usage_seconds_total{${c}}"})" "{{name}}") ];
      })
      (timeseries {
        title = "Memory";
        unit = "bytes";
        stack = true;
        targets = [ (q "sum by (name) (container_memory_working_set_bytes{${c}})" "{{name}}") ];
      })
    ]
    [
      (timeseries {
        title = "Network";
        unit = "bps";
        targets = [
          (q "8 * sum by (name) (${rate "container_network_receive_bytes_total{${c}}"})" "{{name}} in")
          (q "-8 * sum by (name) (${rate "container_network_transmit_bytes_total{${c}}"})" "{{name}} out")
        ];
      })
      (timeseries {
        title = "Disk IO";
        unit = "Bps";
        targets = [
          (q "sum by (name) (${rate "container_fs_reads_bytes_total{${c}}"})" "{{name}} read")
          (q "-sum by (name) (${rate "container_fs_writes_bytes_total{${c}}"})" "{{name}} write")
        ];
      })
    ]

    [ (heading "Logs") ]
    [
      (timeseries {
        title = "Lines by level";
        datasource = d.loki;
        stack = true;
        targets = [ (q "sum by (level) (count_over_time({${docker}} [$__auto]))" "{{level}}") ];
      })
      (timeseries {
        title = "Errors by container";
        datasource = d.loki;
        stack = true;
        targets = [ (q "sum by (container) (count_over_time({${errors}} [$__auto]))" "{{container}}") ];
      })
    ]
    [
      (logs {
        title = "Warnings and errors";
        targets = [ (q ''{${docker}, level=~"warn|error|fatal"}'' "") ];
      })
    ]
  ];
}
