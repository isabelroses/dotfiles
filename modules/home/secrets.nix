{
  root,
  name,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.sops.home ];

  config = {
    sops = {
      defaultSopsFile = root + /secrets/${name}.yaml;
      age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };
}
