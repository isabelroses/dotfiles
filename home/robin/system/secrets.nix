{ self, ... }:
let
  inherit (self.lib) mkUserSecret;
in
{
  age.secrets = {
    keys-gpg = mkUserSecret {
      file = "keys/robin-gpg";
    };
    keys-gh = mkUserSecret {
      file = "keys/robin-gh";
    };
    keys-gh-pub = mkUserSecret {
      file = "keys/robin-gh-pub";
    };
    keys-email = mkUserSecret {
      file = "keys/robin-email";
    };
  };
}
