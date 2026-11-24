{ d }:
let
  inherit (d)
    q
    rate
    stat
    timeseries
    heading
    ;

  h = ''host=~"$host"'';
in
d.dashboard {
  uid = "tailscale";
  title = "Tailscale";
  variables = [ (d.hostVariable d.prometheus "label_values(tailscaled_health_messages, host)") ];

  rows = [
    [
      (stat {
        title = "Health warnings";
        w = 8;
        targets = [ (q "sum by (host) (tailscaled_health_messages{${h}})" "{{host}}") ];
        thresholds.orange = 1;
      })
      (stat {
        title = "Relayed share of traffic";
        w = 8;
        unit = "percentunit";
        targets = [
          (q ''sum(${rate ''tailscaled_inbound_bytes_total{${h}, path="derp"}''}) / sum(${rate "tailscaled_inbound_bytes_total{${h}}"})'' "derp")
        ];
        thresholds.orange = 0.1;
      })
      (stat {
        title = "Unapproved routes";
        w = 8;
        targets = [
          (q "sum by (host) (tailscaled_advertised_routes{${h}} - tailscaled_approved_routes{${h}})" "{{host}}")
        ];
        thresholds.orange = 1;
      })
    ]

    [ (heading "Traffic") ]
    [
      # derp is relayed, not direct
      (timeseries {
        title = "Throughput by path";
        unit = "bps";
        targets = [
          (q "8 * sum by (path) (${rate "tailscaled_inbound_bytes_total{${h}}"})" "{{path}} in")
          (q "-8 * sum by (path) (${rate "tailscaled_outbound_bytes_total{${h}}"})" "{{path}} out")
        ];
      })
      (timeseries {
        title = "Throughput by host";
        unit = "bps";
        targets = [
          (q "8 * sum by (host) (${rate "tailscaled_inbound_bytes_total{${h}}"})" "{{host}} in")
          (q "-8 * sum by (host) (${rate "tailscaled_outbound_bytes_total{${h}}"})" "{{host}} out")
        ];
      })
    ]
    [
      (timeseries {
        title = "Dropped packets";
        targets = [
          (q "sum by (host, reason) (${rate "tailscaled_inbound_dropped_packets_total{${h}}"})" "{{host}} in {{reason}}")
          (q "-sum by (host, reason) (${rate "tailscaled_outbound_dropped_packets_total{${h}}"})" "{{host}} out {{reason}}")
        ];
      })
      (timeseries {
        title = "Home DERP region";
        targets = [ (q "tailscaled_home_derp_region_id{${h}}" "{{host}}") ];
      })
    ]
  ];
}
