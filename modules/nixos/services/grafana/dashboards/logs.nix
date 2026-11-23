{ d }:
let
  inherit (d) q timeseries logs;

  selector = ''{host=~"$host"}'';
  search = ''|~ "(?i)$search"'';
in
d.dashboard {
  uid = "logs";
  title = "Logs";
  time = "now-1h";
  tags = [
    "fleet"
    "logs"
  ];

  variables = [
    (d.hostVariable d.loki "label_values(host)")
    {
      name = "search";
      label = "Search (regex)";
      type = "textbox";
      query = "";
      current = {
        text = "";
        value = "";
      };
    }
  ];

  rows = [
    [
      (timeseries {
        title = "Lines per host";
        datasource = d.loki;
        stack = true;
        targets = [ (q "sum by (host) (count_over_time(${selector} ${search} [$__auto]))" "{{host}}") ];
      })
      (timeseries {
        title = "Lines that look like trouble";
        datasource = d.loki;
        stack = true;
        targets = [
          (q ''sum by (host) (count_over_time(${selector} |~ "(?i)(error|fail|panic|denied|segfault|oom)" [$__auto]))'' "{{host}}")
        ];
      })
    ]
    [
      (logs {
        title = "Journal";
        targets = [ (q "${selector} ${search}" "") ];
      })
    ]
  ];
}
