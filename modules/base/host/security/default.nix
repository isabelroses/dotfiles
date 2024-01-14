_: {
  imports = [
    ./auditd.nix # auditd
    ./clamav.nix # clamav antivirus
    ./kernel.nix # kernel hardening
    ./pam.nix # pam configuration
    ./polkit.nix # polkit configuration
    ./selinux.nix # selinux support + kernel patches
    ./sudo.nix # sudo rules and configuration
    ./virtualization.nix # hypervisor hardening
  ];
}
