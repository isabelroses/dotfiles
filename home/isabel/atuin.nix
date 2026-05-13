{ config, ... }:
{
  programs.atuin = {
    inherit (config.garden.profiles.workstation) enable;

    flags = [ "--disable-up-arrow" ];
    settings = {
      dialect = "uk";
      show_preview = true;
      inline_height = 30;
      style = "compact";
      update_check = false;
      sync_address = "https://atuin.isabelroses.com";
      sync_frequency = "5m";
    };
  };
}
