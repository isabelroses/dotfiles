_: {
  networking.nftables = {
    enable = false;
    tables = {
      # TODO: write a proper filter table
      #  accept: ssh, http, https and in the future, DNS
      #  block: everything else
      default-filter = {
        content = "";
        family = "inet";
      };
    };
  };
}
