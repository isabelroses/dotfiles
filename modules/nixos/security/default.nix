# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
# https://github.com/fort-nix/nix-bitcoin/blob/master/modules/presets/hardened-extended.nix
{
  imports = [
    ./apparmor.nix # apparmor
    ./auditd.nix # auditd
    ./kernel.nix # kernel hardening
    ./pam.nix # pam configuration
    ./polkit.nix # polkit configuration
    ./sudo.nix # sudo rules and configuration
  ];
}
