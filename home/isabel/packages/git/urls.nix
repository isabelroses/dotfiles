{ lib, self, ... }:
let
  inherit (lib.lists) map;
  inherit (lib.modules) mkMerge;
  inherit (self.lib.helpers) giturl;
in
{
  programs.git.extraConfig.url = mkMerge (
    map giturl [
      {
        domain = "github.com";
        alias = "github";
      }
      {
        domain = "gitlab.com";
        alias = "gitlab";
      }
      {
        domain = "aur.archlinux.org";
        alias = "aur";
        user = "aur";
      }
      {
        domain = "git.sr.ht";
        alias = "srht";
      }
      {
        domain = "codeberg.org";
        alias = "codeberg";
      }
      {
        domain = "git.isabelroses.com";
        alias = "me";
        port = 2222;
      }
      {
        domain = "git.auxolotl.org";
        alias = "aux";
        user = "forgejo";
      }
    ]
  );
}
