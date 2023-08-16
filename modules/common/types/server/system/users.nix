_: {
  users.users.git = {
    isSystemUser = true;
    extraGroups = [];
    useDefaultShell = true;
    home = "/var/lib/gitea";
    group = "gitea";
  };
}
