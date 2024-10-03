{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in
{
  # This is enabled by default, but we don't want it
  # NOTE: this will break some programs that call `man` for you like `nix-collect-garbage`
  programs.man.enable = false;

  # I don't use docs, so just disable them
  #
  # the docs also create issues that are really hard to debug
  # such as ones where lib does not get passed correctly,
  # see an example of me complaining and then finding this as the fix
  # https://akko.isabelroses.com/notice/AkdGj5udRhYIKqTeng
  manual = mapAttrs (_: mkForce) {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };
}
