_: {
  users.users.root = {
    initialPassword = "changeme";

    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEtTMRG9pfuOjlLmq/NybTZCIKL66tLNSM4CBILYda3''
    ];
  };
}
