---
title: Secrets
description: Managing encrypted secrets with sops-nix.
---

We use [`sops-nix`](https://github.com/Mic92/sops-nix) to manage secrets that
are not files. For the most part this will be SSH keys, API keys, and other
plaintext secrets.

To start, identify whether you are creating a system-level secret or a
user-level secret.

## User secrets

If you are adding a user-level secret, add your user to the list of users in
the `.sops.yaml` file. Then get your public key by running:

```bash
cat ~/.ssh/id_ed25519.pub
```

Then create your user's secrets file:

```bash
sops secrets/your_username.yaml
```

Where `your_username` is your actual username.

## System secrets

If you are adding system-level secrets, get the hostname and its accompanying
public key. To get the public key, run:

```bash
ssh-keyscan <host>
```

Where `<host>` is the IP address or hostname of the system you want to add.

Alternatively, if you are on the machine you can run:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Then create the system secrets file:

```bash
sops secrets/services/<service>.yaml
```

Replace `<service>` with the name of the service you are adding the secrets for.

## Rotating secrets

To rotate a secret file, run:

```bash
sops rotate -i secrets/<file>.yaml
```

Where `<file>` is the name of the file you want to rotate.

To rotate all the secrets, run:

```bash
find secrets/ -name "*.yaml" | xargs -I {} sops rotate -i {}
```

## Adding new owners to secrets

To add a new owner to a secret file, you must first add the new recipient to
the `.sops.yaml` file. Then run:

```bash
sops updatekeys secrets/<file>.yaml
```

Where `<file>` is the name of the file you want to update.

To batch update all secrets, run:

```bash
find secrets/ -name "*.yaml" | xargs -I {} sops updatekeys -y {}
```
