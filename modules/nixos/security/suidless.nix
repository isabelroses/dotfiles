# WARNING: like all good experimental modules there is no guarantee you will
# even be able to login after enabling some of these options
# <https://hedgedoc.grimmauld.de/s/P2_wvU0w58>
{
  lib,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  security = {
    # sudo/su/sg. use run0
    sudo.enable = mkForce false;
    sudo-rs.enable = mkForce false;

    # polkit is a issue
    wrappers.pkexec.enable = false;

    # TODO: https://github.com/NixOS/nixpkgs/pull/453557
    account-utils.enable = true;

  };

  # https://github.com/NixOS/nixpkgs/pull/521536
  programs.fuse.enable = false;
}
