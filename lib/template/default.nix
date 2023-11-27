_: let
  template = {
    # this is a forced SSL template for Nginx
    # returns the attribute set with our desired settings
    ssl = {
      forceSSL = true;
      enableACME = true;
    };

    xdg = ./. + /xdg.nix;
  };
in {
  inherit template;
}
