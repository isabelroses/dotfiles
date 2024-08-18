{
  # https://github.com/NixOS/nixpkgs/issues/72394#issuecomment-549110501
  # the service is enabled by default, but this is not set. so by default, you will see the error
  # why?
  environment.etc."mdadm.conf".text = ''
    MAILADDR root
  '';
}
