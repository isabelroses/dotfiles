{ lib }:
let
  inherit (lib.lists)
    elemAt
    foldl'
    imap0
    imap1
    ;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) sort;
  inherit (lib.trivial) max;

  prometheus = {
    type = "prometheus";
    uid = "prometheus";
  };

  loki = {
    type = "loki";
    uid = "loki";
  };

  refIds = [
    "A"
    "B"
    "C"
    "D"
    "E"
    "F"
  ];

  q = expr: legendFormat: { inherit expr legendFormat; };

  rate = expr: "rate(${expr}[$__rate_interval])";

  # for gauges that only ever grow, like prowlarr's running totals
  increase = expr: "increase(${expr}[$__rate_interval])";

  # { orange = 80; red = 90; } as grafana's ascending steps; base colours
  # everything under the lowest one
  steps =
    {
      base ? "green",
      ...
    }@levels:
    {
      mode = "absolute";
      steps = [
        {
          color = base;
          value = null;
        }
      ]
      ++ sort (a: b: a.value < b.value) (
        mapAttrsToList (color: value: { inherit color value; }) (removeAttrs levels [ "base" ])
      );
    };

  upDown = {
    mappings = [
      {
        type = "value";
        options = {
          "0".text = "down";
          "1".text = "up";
        };
      }
    ];
    thresholds = steps {
      base = "red";
      green = 1;
    };
  };

  withRefIds = imap0 (i: target: target // { refId = elemAt refIds i; });

  base =
    {
      title,
      type,
      targets,
      datasource ? prometheus,
      w ? 12,
      h ? 8,
      unit ? "short",
      fieldConfig ? { },
      options ? { },
      ...
    }:
    {
      inherit
        title
        type
        datasource
        w
        h
        options
        ;
      targets = map (t: { inherit datasource; } // t) (withRefIds targets);
      fieldConfig = {
        defaults = {
          inherit unit;
        }
        // fieldConfig;
        overrides = [ ];
      };
    };

  timeseries =
    {
      stack ? false,
      ...
    }@args:
    base (
      args
      // {
        type = "timeseries";
        fieldConfig = {
          custom = {
            fillOpacity = if stack then 60 else 10;
            lineWidth = 1;
            showPoints = "never";
            stacking.mode = if stack then "normal" else "none";
          };
        }
        // args.fieldConfig or { };
        options = {
          legend = {
            displayMode = "table";
            placement = "bottom";
            calcs = [
              "mean"
              "max"
              "lastNotNull"
            ];
          };
          tooltip = {
            mode = "multi";
            sort = "desc";
          };
        };
      }
    );

  stat =
    {
      thresholds ? { },
      ...
    }@args:
    base (
      {
        h = 4;
      }
      // args
      // {
        type = "stat";
        fieldConfig = {
          thresholds = steps thresholds;
        }
        // args.fieldConfig or { };
        options = {
          reduceOptions.calcs = [ "lastNotNull" ];
          colorMode = "background";
          graphMode = "area";
          textMode = "value_and_name";
          justifyMode = "center";
        };
      }
    );

  bargauge =
    {
      thresholds ? { },
      ...
    }@args:
    base (
      args
      // {
        type = "bargauge";
        fieldConfig = {
          min = 0;
          max = 100;
          thresholds = steps thresholds;
        }
        // args.fieldConfig or { };
        options = {
          reduceOptions.calcs = [ "lastNotNull" ];
          displayMode = "gradient";
          orientation = "horizontal";
          showUnfilled = true;
        };
      }
    );

  # a stat of 0/1 series, shown as down/up
  status = args: stat ({ fieldConfig = upDown; } // args);

  # 0/1 series as coloured bands over time
  timeline =
    {
      on ? "on",
      off ? "off",
      offColor ? "transparent",
      ...
    }@args:
    base (
      removeAttrs args [
        "on"
        "off"
        "offColor"
      ]
      // {
        type = "state-timeline";
        fieldConfig = {
          mappings = [
            {
              type = "value";
              options = {
                "0" = {
                  text = off;
                  color = offColor;
                };
                "1" = {
                  text = on;
                  color = "green";
                };
              };
            }
          ];
          color.mode = "thresholds";
        };
        options = {
          showValue = "never";
          mergeValues = true;
          rowHeight = 0.8;
          legend.showLegend = false;
        };
      }
    );

  logs =
    args:
    base (
      {
        datasource = loki;
        w = 24;
        h = 18;
      }
      // args
      // {
        type = "logs";
        options = {
          showTime = true;
          wrapLogMessage = true;
          sortOrder = "Descending";
          enableLogDetails = true;
        };
      }
    );

  heading = title: {
    type = "row";
    inherit title;
    collapsed = false;
    panels = [ ];
    w = 24;
    h = 1;
  };

  layout =
    rows:
    let
      placed =
        (foldl'
          (
            acc: row:
            let
              height = foldl' (m: p: max m p.h) 0 row;
              inRow =
                (foldl'
                  (s: p: {
                    x = s.x + p.w;
                    panels = s.panels ++ [
                      (
                        removeAttrs p [
                          "w"
                          "h"
                        ]
                        // {
                          gridPos = {
                            inherit (s) x;
                            inherit (acc) y;
                            inherit (p) w h;
                          };
                        }
                      )
                    ];
                  })
                  {
                    x = 0;
                    panels = [ ];
                  }
                  row
                ).panels;
            in
            {
              y = acc.y + height;
              panels = acc.panels ++ inRow;
            }
          )
          {
            y = 0;
            panels = [ ];
          }
          rows
        ).panels;
    in
    imap1 (id: p: p // { inherit id; }) placed;

  hostVariable = datasource: query: {
    name = "host";
    label = "Host";
    type = "query";
    inherit datasource query;
    refresh = 2;
    includeAll = true;
    multi = true;
    allValue = ".+";
    current = {
      text = "All";
      value = "$__all";
    };
    sort = 1;
  };

  dashboard =
    {
      uid,
      title,
      rows,
      variables ? [ (hostVariable prometheus "label_values(up, host)") ],
      time ? "now-6h",
      tags ? [ "fleet" ],
    }:
    {
      inherit uid title tags;
      editable = true;
      refresh = "1m";
      schemaVersion = 39;
      graphTooltip = 1;
      time = {
        from = time;
        to = "now";
      };
      templating.list = variables;
      panels = layout rows;
    };
in
{
  inherit
    loki
    prometheus
    q
    rate
    increase
    timeseries
    stat
    status
    bargauge
    timeline
    logs
    heading
    hostVariable
    dashboard
    ;

  panel = base;
}
