{
  config,
  system,
  flakePath,
  ...
}: {
  xdg.configFile."wlogout" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/users/${system.currentUser}/config/wlogout";
    recursive = true;
  };
}