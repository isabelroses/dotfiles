{
  lib,
  pkgs,
  ...
}:
{
  fonts.packages = lib.attrValues {
    inherit (pkgs)
      corefonts

      source-sans
      source-serif

      dejavu_fonts
      inter

      noto-fonts

      # fonts for none latin languages
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      # install some emoji fonts
      noto-fonts-color-emoji
      material-icons
      material-design-icons
      ;

    inherit (pkgs.nerd-fonts) symbols-only;
  };
}
