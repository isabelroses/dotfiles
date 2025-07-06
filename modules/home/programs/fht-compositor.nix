{
  lib,
  pkgs,
  config,
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.fht-compositor.homeModules.default ];

  config = lib.mkIf config.programs.fht-compositor.enable {
    programs.fht-compositor.settings = {
      cursor = { inherit (config.home.pointerCursor) name size; };

      autostart = [
        "wl-paste --type text --watch cliphist store" # Stores only text data
        "wl-paste --type image --watch cliphist store" # Stores only image data
      ];

      input.keyboard = {
        layout = osConfig.garden.device.keyboard;
        repeat-rate = 50;
        repeat-delay = 250;
      };
    };

    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland satellite service";
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
        BindsTo = [ config.wayland.systemd.target ];
        Requisite = [ config.wayland.systemd.target ];
      };
      Service = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        StandardOutput = "journal";
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
  };
}
