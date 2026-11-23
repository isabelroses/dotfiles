{ d }:
let
  inherit (d)
    q
    stat
    timeseries
    bargauge
    heading
    ;

  h = ''host=~"$host"'';

  disks = ''${h}, fstype!~"tmpfs|ramfs|devtmpfs|overlay|squashfs|vfat|efivarfs", mountpoint!~"/run.*|/boot.*|/nix/store"'';

  nics = ''${h}, device!~"lo|tailscale.*|veth.*|docker.*|br-.*|virbr.*|wpan.*"'';
in
d.dashboard {
  uid = "fleet";
  title = "Fleet";

  rows = [
    [
      (stat {
        title = "Reachable";
        w = 8;
        targets = [ (q ''up{job="node", ${h}}'' "{{host}}") ];
        fieldConfig = d.upDown;
      })
      (stat {
        title = "Uptime";
        w = 8;
        unit = "s";
        targets = [ (q "time() - node_boot_time_seconds{${h}}" "{{host}}") ];
      })
      (stat {
        title = "Failed units";
        w = 8;
        targets = [ (q ''sum by (host) (node_systemd_unit_state{${h}, state="failed"})'' "{{host}}") ];
        thresholds = [
          {
            color = "red";
            value = 1;
          }
        ];
      })
    ]

    [ (heading "Compute") ]
    [
      (timeseries {
        title = "CPU";
        unit = "percent";
        targets = [
          (q ''100 * (1 - avg by (host) (rate(node_cpu_seconds_total{${h}, mode="idle"}[$__rate_interval])))'' "{{host}}")
        ];
        fieldConfig = {
          min = 0;
          max = 100;
        };
      })
      (timeseries {
        title = "Memory";
        unit = "percent";
        targets = [
          (q "100 * (1 - node_memory_MemAvailable_bytes{${h}} / node_memory_MemTotal_bytes{${h}})" "{{host}}")
        ];
        fieldConfig = {
          min = 0;
          max = 100;
        };
      })
    ]
    [
      (timeseries {
        title = "Load per core";
        targets = [
          (q ''node_load5{${h}} / on (host) count by (host) (node_cpu_seconds_total{${h}, mode="idle"})'' "{{host}}")
        ];
      })
      (timeseries {
        title = "Hottest sensor";
        unit = "celsius";
        targets = [ (q "max by (host) (node_hwmon_temp_celsius{${h}})" "{{host}}") ];
      })
    ]

    [ (heading "Storage and network") ]
    [
      (bargauge {
        title = "Disk used";
        unit = "percent";
        h = 10;
        targets = [
          (q "max by (host, mountpoint) (100 * (1 - node_filesystem_avail_bytes{${disks}} / node_filesystem_size_bytes{${disks}}))" "{{host}} {{mountpoint}}")
        ];
        thresholds = [
          {
            color = "orange";
            value = 80;
          }
          {
            color = "red";
            value = 90;
          }
        ];
      })
      (timeseries {
        title = "Disk IO";
        unit = "Bps";
        h = 10;
        targets = [
          (q "sum by (host) (rate(node_disk_read_bytes_total{${h}}[$__rate_interval]))" "{{host}} read")
          (q "-sum by (host) (rate(node_disk_written_bytes_total{${h}}[$__rate_interval]))" "{{host}} write")
        ];
      })
    ]
    [
      (timeseries {
        title = "Network";
        unit = "bps";
        w = 24;
        targets = [
          (q "8 * sum by (host) (rate(node_network_receive_bytes_total{${nics}}[$__rate_interval]))" "{{host}} in")
          (q "-8 * sum by (host) (rate(node_network_transmit_bytes_total{${nics}}[$__rate_interval]))" "{{host}} out")
        ];
      })
    ]
  ];
}
