{
  lib,
  pkgs,
  self',
  config,
  # extpkgs,
  ...
}:
let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;

  izshell = self'.legacyPackages.izshell;
  hyprland = config.programs.hyprland.package;
  sessionData = config.services.displayManager.sessionData.desktops;
  cacheDir = "/var/cache/izshell-greeter";

  # a bare hyprland whose only job is the greeter. once the greeter hands a
  # session to greetd it exits, and hyprland follows so greetd can start it
  greeterConfig = pkgs.writeText "greeter.lua" ''
    hl.env("GREETER_SESSIONS", "${sessionData}/share/wayland-sessions:${sessionData}/share/xsessions")
    hl.env("XDG_CACHE_HOME", "${cacheDir}")

    hl.config({
      input = { kb_layout = "${config.garden.device.keyboard}", numlock_by_default = true },
      cursor = { invisible = true },
      misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = "rgb(000000)",
      },
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd("${getExe' izshell "izshell-greeter"}; ${getExe' hyprland "hyprctl"} dispatch 'hl.dsp.exit()'")
    end)
  '';
in
{
  services.greetd = {
    inherit (config.garden.profiles.graphical) enable;
    restart = true;

    settings.default_session = {
      user = "greeter";
      command = "${getExe' hyprland "start-hyprland"} -- --config ${greeterConfig}";

      # command = lib.strings.concatStringsSep " " [
      #   (lib.meta.getExe extpkgs.tuigreet)
      #   "--time"
      #   "--remember"
      #   "--remember-user-session"
      #   "--asterisks"
      #   "--sessions '${sessionData}/share/xsessions:${sessionData}/share/wayland-sessions'"
      # ];
    };
  };

  # the account picture izshell keeps in sync, so the greeter can show it
  services.accounts-daemon.enable = config.services.greetd.enable;

  # the greeter user's home is /var/empty; quickshell and hyprland want a cache
  systemd.tmpfiles.settings.izshell-greeter = mkIf config.services.greetd.enable {
    ${cacheDir}.d = {
      user = "greeter";
      group = "greeter";
      mode = "0750";
    };
  };
}
