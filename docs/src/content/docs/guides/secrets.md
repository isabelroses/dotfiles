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

Hosts decrypt with the age key at `/var/lib/sops-nix/key.txt`, not their SSH
host keys. To get a host's public key, run this on the host:

```bash
run0 age-keygen -y /var/lib/sops-nix/key.txt
```

Add it under `keys:` in `.sops.yaml`, then create the system secrets file:

```bash
sops secrets/services/<service>.yaml
```

Replace `<service>` with the name of the service you are adding the secrets for.

### Which hosts can read a file

Each file in `secrets/services` is encrypted only to the hosts that run the
service using it. sops picks the **first** `creation_rules` entry whose
`path_regex` matches, so a new service file falls through to the last rule
and is readable by you alone until you add it to a host's rule.

When you enable a service on another host, add that host to the file's rule
and run `sops updatekeys`. Otherwise `sops-install-secrets` fails during
activation. To see which files a host uses:

```bash
nix eval --json .#nixosConfigurations.<host>.config.sops.secrets \
  --apply 's: map (v: baseNameOf (toString v.sopsFile)) (builtins.attrValues s)'
```

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

## Removing a host's access

`sops updatekeys` re-wraps the file's existing data key for the new set of
recipients. A host you removed can still decrypt the file from git history,
and the data key has not changed. To actually cut it off:

1. Remove the host from the rule in `.sops.yaml`.
2. `sops updatekeys -y <file>` then `sops rotate -i <file>`, which creates a
   new data key.
3. If the host may have been compromised, change the secret **values** too
   (passwords, tokens, keys) at the service, because the old values are still
   readable from history.
