{ d }:
let
  inherit (d)
    q
    stat
    timeseries
    timeline
    bargauge
    heading
    ;

  # each gatus instance is its own status page: skadi's for isabel, isis' for tgc
  g = ''host=~"$host"'';
  endpoint = "{{group}} / {{name}}";
in
d.dashboard {
  uid = "uptime";
  title = "Uptime";
  time = "now-24h";
  variables = [ (d.hostVariable d.prometheus "label_values(gatus_results_endpoint_success, host)") ];

  rows = [
    [
      (stat {
        title = "Endpoints down";
        w = 6;
        targets = [ (q "count(gatus_results_endpoint_success{${g}} == 0) or vector(0)" "down") ];
        thresholds.red = 1;
      })
      (stat {
        title = "Availability in range";
        w = 6;
        unit = "percent";
        targets = [ (q "100 * avg(avg_over_time(gatus_results_endpoint_success{${g}}[$__range]))" "all") ];
        thresholds = {
          base = "red";
          orange = 99;
          green = 99.9;
        };
      })
      (stat {
        title = "Slowest now";
        w = 6;
        unit = "s";
        targets = [ (q "max(gatus_results_duration_seconds{${g}})" "max") ];
        thresholds = {
          orange = 1;
          red = 3;
        };
      })
      (stat {
        title = "Soonest certificate expiry";
        w = 6;
        unit = "s";
        targets = [ (q "min(gatus_results_certificate_expiration_seconds{${g}} > 0)" "min") ];
        thresholds = {
          base = "red";
          orange = 7 * 86400;
          green = 14 * 86400;
        };
      })
    ]

    [
      (timeline {
        title = "Endpoints";
        w = 24;
        h = 14;
        on = "up";
        off = "down";
        offColor = "red";
        targets = [ (q "gatus_results_endpoint_success{${g}}" endpoint) ];
      })
    ]

    [ (heading "Response") ]
    [
      (timeseries {
        title = "Response time";
        w = 16;
        unit = "s";
        targets = [ (q "gatus_results_duration_seconds{${g}}" endpoint) ];
      })
      (bargauge {
        title = "Availability by endpoint";
        w = 8;
        unit = "percent";
        targets = [
          (q "sort(100 * avg_over_time(gatus_results_endpoint_success{${g}}[$__range]))" endpoint)
        ];
        thresholds = {
          base = "red";
          orange = 99;
          green = 99.9;
        };
      })
    ]

    [ (heading "Expiry") ]
    [
      (bargauge {
        title = "Certificates";
        unit = "s";
        targets = [ (q "sort(gatus_results_certificate_expiration_seconds{${g}} > 0)" endpoint) ];
        fieldConfig.max = 90 * 86400;
        thresholds = {
          base = "red";
          orange = 7 * 86400;
          green = 14 * 86400;
        };
      })
      (bargauge {
        title = "Domains";
        unit = "s";
        targets = [ (q "sort(gatus_results_domain_expiration_seconds{${g}} > 0)" endpoint) ];
        fieldConfig.max = 365 * 86400;
        thresholds = {
          base = "red";
          orange = 14 * 86400;
          green = 30 * 86400;
        };
      })
    ]
  ];
}
