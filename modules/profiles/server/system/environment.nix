{
  environment = {
    # normally we wouldn't need any Xlibs on a headless server but for whatever reason
    # this affects whether or not some programs can build - such as pipewire
    # noXlibs = true;

    # print the URL instead on servers
    variables.BROWSER = "echo";
  };

  xdg = {
    sounds.enable = false;
    mime.enable = false;
    menus.enable = false;
    icons.enable = false;
    autostart.enable = false;
  };
}
