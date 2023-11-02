_: let
  # this is a forced SSL template for Nginx
  # returns the attribute set with our desired settings
  sslTemplate = {
    forceSSL = true;
    enableACME = true;
  };
in {
  inherit sslTemplate;
}
