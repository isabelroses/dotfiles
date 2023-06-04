{
  config,
  pkgs,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      git
      killall
      wget
      home-manager
      pipewire
      wireplumber
      pulseaudio
    ];
  };
  nixpkgs.config.allowUnfree = true;
}