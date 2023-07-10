_: {
  programs = {
    ssh = {
      enable = true;
      hashKnownHosts = true;
      compression = true;
      extraConfig = ''
      Host *
	      Port 22
      '';
      matchBlocks = {
        # git clients
        "aur.archlinux.org" = {
          user = "aur";
          hostname = "aur.archlinux.org";
          identityFile = "~/.ssh/aur";
        };

        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = "~/.ssh/github";
        };

        # ORACLE vps'
        "openvpn" = {
          hostname = "132.145.55.42";
          user = "openvpnas";
          identityFile = "~/.ssh/openvpn";
        };

        "edalyn" = {
	        hostname = "141.147.113.225";
      	  user = "ubuntu";
	        identityFile = "~/.ssh/edalyn";
        };
        
        "king" = {
	        hostname = "150.230.117.215";
	        user = "ubuntu";
	        identityFile = "~/.ssh/king";
        };
        
        "luz" = {
	        hostname = "144.21.55.221";
	        user = "ubuntu";
	        identityFile = "~/.ssh/luz";
        };

        # my local servers / clients
        "alpha" = {
          hostname = "192.168.86.4";
	        user = "isabel";
	        identityFile = "~/.ssh/alpha";
        };

        "hydra" = {
          hostname = "192.168.86.3";
          user = "isabel";
	        identityFile = "~/.ssh/hydra";
        };
      };
    };
  };
}
