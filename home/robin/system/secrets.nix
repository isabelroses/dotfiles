{ self, ... }:
let
  mkUserSecret = self.lib.mkUserSecret "robin";
in
{
  sops.secrets = {
    keys-gpg = mkUserSecret { };
    keys-gh = mkUserSecret { };
    keys-gh-pub = mkUserSecret { };
    keys-email = mkUserSecret { };
  };
}
