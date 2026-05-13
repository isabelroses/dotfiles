{ config, ... }:
{
  programs.ripgrep = {
    inherit (config.garden.profiles.workstation) enable;

    # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!.git/*"
      "--smart-case"
    ];
  };
}
