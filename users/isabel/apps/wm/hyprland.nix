{
  config,
    pkgs,
    lib,
    inputs,
    ...
}: {
  #imports = [ ./hyprland-config.nix ];
  home = {
    packages = with pkgs; [
      #inputs.hyprpaper.packages.${pkgs.system}.hyprpaper
      inputs.hyprpicker.packages.${pkgs.system}.hyprpicker
      brightnessctl
      wl-clipboard
      wlsunset
      grim
      slurp
      swappy
      xdg-desktop-portal-hyprland
    ];
  };
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    #nvidiaPatches = true;
    extraConfig = builtins.readFile ../../config/hypr/hyprland.conf;
  };
}
