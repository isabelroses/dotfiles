{ self, config, ... }:
{
  # sign locally built store paths so they can be copied to other hosts
  # without needing trusted-users on the target
  # <https://github.com/NixOS/nix/issues/2127>
  sops.secrets.nix-signing-key = self.lib.mkSecret {
    file = "nix";
    key = "signing-key";
  };

  nix.settings.secret-key-files = [ config.sops.secrets.nix-signing-key.path ];
}
