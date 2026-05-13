{ pkgs, ... }:
{
  wrappers.atuin = {
    basePackage = pkgs.atuin;

    env.ATUIN_CONFIG_DIR.value = pkgs.writers.writeTOML {
      dialect = "uk";
      show_preview = true;
      inline_height = 30;
      style = "compact";
      update_check = false;
      sync_address = "https://atuin.isabelroses.com";
      sync_frequency = "5m";
      daemon.enabled = true;
    };
  };
}
