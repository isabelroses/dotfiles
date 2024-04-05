_: let
  template = {
    # this is a forced SSL template for Nginx
    # returns the attribute set with our desired settings
    ssl = domain: {
      quic = true;
      forceSSL = true;
      enableACME = false;
      useACMEHost = domain;
    };

    xdg = ./. + /xdg.nix;
  };
in {
  inherit template;
}
