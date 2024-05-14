{ lib, pkgs, ... }:
let
  loadDashboard =
    file:
    lib.pipe file [
      lib.importJSON
      (
        { dashboard, ... }:
        rec {
          name = "provision-dashboard-${dashboard.uid}.json";
          path = builtins.toFile name (builtins.toJSON dashboard);
        }
      )
    ];

  dashboardsDir = pkgs.linkFarm "grafana-provisioning-dashboards" (
    map loadDashboard (lib.filesystem.listFilesRecursive ./dashboards)
  );
in
{
  services.grafana.provision.dashboards.settings = {
    providers = lib.singleton {
      options.path = dashboardsDir;
      allowUiUpdates = true;
    };
  };
}
