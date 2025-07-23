# Git Crypt

In this repository, we utilize [`git-crypt`](https://github.com/AGWA/git-crypt)
to encrypt files that are meant only for some users. This allows us to keep this
repo public while still protecting sensitive information.

To add a new user to the repository, you need to:

```bash
git-crypt add-gpg-user USER_ID
```

Where `USER_ID` is the key ID, a full fingerprint, an email address, or
anything else that uniquely identifies a public key.

When cloning the repository, make sure that you run:

```bash
git-crypt unlock
```


This will decrypt the secrets that were encrypted with `git-crypt`.

# Sops Nix

We also use [`sops-nix`](https://github.com/Mic92/sops-nix) to manage secrets
that are not files. For the most part this will be ssh keys, api keys and other
plaintext secrets.

To start you should identify whether you are creating a system level secret or
a user level secret.

## User secrets

If you are adding a user level secret, you should add your user to the list of
users in the `.sops.yaml` file. Then you should get your public key by running:

```bash
ssh-to-age < ~/.ssh/id_ed25519.pub
```

Then you can create your users secrets file. To do so you should run the command:

```bash
sops secrets/your_username.yaml
```

Where `your_username` is your actual username.

## System secrets

If you are adding a system level secrets, you should get the hostname and its accompanied public key. To get the public key, you can run:

```bash
ssh-keyscan <host> | ssh-to-age
```

Where `<host>` is the ip address or hostname of the system you want to add.

Alternatively, if you are on the machine you can run:

```bash
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Then you can create the system secrets file. To do so you should run the command:

```bash
sops secrets/services/<service>.yaml
```

You should replace `<service>` with the name of the service you are adding the secrets for.

## Rotating secrets

To rotate a secret file all you have to run is:

```bash
sops rotate -i secrets/<file>.yaml
```

Where `<file>` is the name of the file you want to rotate.

To rotate all the secrets, you can run:

```bash
find secrets/ -name "*.yaml" | xargs -I {} sops rotate -i {}
```

## Adding new owners to secrets

To add a new owner to a secret file, you must first add the new recipent to the `.sops.yaml` file. Then you can run the command:

```bash
sops updatekeys secrets/<file>.yaml
```

Where `<file>` is the name of the file you want to update.

Futhermore, to batch update all secrets, you can run:

```bash
find secrets/ -name "*.yaml" | xargs -I {} sops updatekeys -y {}
```
