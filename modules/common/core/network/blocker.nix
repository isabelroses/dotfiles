_: {
  # this should block *most* junk sites
  networking = {
    stevenblack = {
      enable = true;
      block = [
        "fakenews"
        "gambling"
      ];
    };
  };
}
