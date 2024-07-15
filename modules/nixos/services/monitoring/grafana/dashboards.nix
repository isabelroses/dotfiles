{ lib, pkgs, ... }:
let
  inherit (lib.lists) map singleton;
  inherit (lib.trivial) pipe importJSON;
  inherit (lib.filesystem) listFilesRecursive;

  loadDashboard =
    file:
    pipe file [
      importJSON
      (
        { dashboard, ... }:
        rec {
          name = "provision-dashboard-${dashboard.uid}.json";
          path = builtins.toFile name (builtins.toJSON dashboard);
        }
      )
    ];

  dashboardsDir = pkgs.linkFarm "grafana-provisioning-dashboards" (
    map loadDashboard (listFilesRecursive ./dashboards)
  );
in
{
  services.grafana.provision.dashboards.settings.providers = singleton {
    options.path = dashboardsDir;
    allowUiUpdates = true;
  };
}
