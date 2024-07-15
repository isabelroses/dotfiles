{
  environment = {
    # normally we wouldn't need any Xlibs on a headless server but for whatever reason
    # this affects whether or not some programs can build - such as pipewire
    noXlibs = true;

    # print the URL instead on servers
    variables.BROWSER = "echo";
  };
}
