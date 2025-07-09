{ self, config, ... }:
let
  inherit (self.lib) mkUserSecret;

  inherit (config.home) homeDirectory;
  inherit (config.xdg) configHome;

  sshDir = "${homeDirectory}/.ssh";
in
{
  age.secrets = {
    wakatime = mkUserSecret {
      file = "isabel/wakatime";
      path = configHome + "/wakatime/.wakatime.cfg";
    };

    nix-auth-tokens = mkUserSecret {
      file = "isabel/nix-auth-tokens";
    };

    # git ssh keys
    keys-gh = mkUserSecret {
      file = "keys/gh";
    };
    keys-gh-pub = mkUserSecret {
      file = "keys/gh-pub";
    };
    keys-aur = mkUserSecret {
      file = "keys/aur";
    };
    keys-aur-pub = mkUserSecret {
      file = "keys/aur-pub";
    };
    keys-tangled = mkUserSecret {
      file = "keys/tangled";
    };
    keys-tangled-pub = mkUserSecret {
      file = "keys/tangled-pub";
    };

    # extra uni stuff
    uni-gitconf = mkUserSecret {
      file = "uni/gitconf";
    };
    uni-ssh = mkUserSecret {
      file = "uni/ssh";
    };
    uni-central = mkUserSecret {
      file = "uni/central";
      path = sshDir + "/uni-central";
    };

    # ORACLE vps'
    keys-openvpn = mkUserSecret {
      file = "keys/openvpn";
    };
    keys-amity = mkUserSecret {
      file = "keys/amity";
    };

    # All nixos machines
    keys-nixos = mkUserSecret {
      file = "keys/nixos";
      path = sshDir + "/id_ed25519";
    };
    keys-nixos-pub = mkUserSecret {
      file = "keys/nixos-pub";
      path = sshDir + "/id_ed25519.pub";
    };
  };
}
