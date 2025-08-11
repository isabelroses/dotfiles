# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
# https://github.com/fort-nix/nix-bitcoin/blob/master/modules/presets/hardened-extended.nix
{
  imports = [
    # keep-sorted start
    ./apparmor.nix # apparmor
    ./auditd.nix # auditd
    ./login-defs.nix # login.defs configuration
    ./pam.nix # pam configuration
    ./polkit.nix # polkit configuration
    ./sudo.nix # sudo rules and configuration
    # keep-sorted end
  ];
}
