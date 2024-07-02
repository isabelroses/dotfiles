{
  users = {
    mutableUsers = false;

    users = {
      root.initialPassword = "";

      nixos = {
        uid = 1000;
        isNormalUser = true;
        initialPassword = "nixos";
        extraGroups = [ "wheel" ];
      };
    };
  };
}
