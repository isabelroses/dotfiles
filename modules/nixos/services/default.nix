{
  imports = [
    # services that a server may provide
    # e.g. nextcloud a web application
    ./selfhosted

    # system services
    # e.g. thermald, for monitoring CPU temperature
    ./system
  ];
}
