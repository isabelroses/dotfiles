flake := env('FLAKE', justfile_directory())

# rebuild is also set as a var so you can add --set to change it if you need to
rebuild := if os() == "macos" { "sudo darwin-rebuild" } else { "nixos-rebuild" }
system-args := if os() == "macos" { "" } else { "--elevate run0 --no-reexec" }

[private]
default:
    @just --list --unsorted

# rebuild group

[group('rebuild')]
[no-exit-message]
[private]
builder goal *args:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ rebuild }} {{ goal }} \
      --flake {{ flake }} \
      --log-format internal-json \
      {{ system-args }} \
      {{ args }} \
      |& nom --json

[group('rebuild')]
[no-exit-message]
[private]
deployer host goal *args:
    #!/usr/bin/env bash
    set -euo pipefail
    just builder {{ goal }} --target-host {{ host }} --use-substitutes {{ args }}
    lethe record {{ host }}

# deploy by switching the new system configuration
[group('rebuild')]
[no-exit-message]
deploy host *args: (deployer host "switch" args)
  lethe diff {{ host }}

# deploy by setting the boot configuration
[group('rebuild')]
[no-exit-message]
deploy-boot host *args: (deployer host "boot" args)
  lethe diff {{ host }}

[group('rebuild')]
[no-exit-message]
[private]
deployer-all goal:
    #!/usr/bin/env bash
    set -euo pipefail

    just deployer minerva {{ goal }}
    just deployer athena {{ goal }}
    just deployer aphrodite {{ goal }}
    just deployer skadi {{ goal }}
    just deployer isis {{ goal }}

    lethe diff minerva
    lethe diff athena
    lethe diff aphrodite
    lethe diff skadi
    lethe diff isis


# deploy to all hosts by switching
[group('rebuild')]
[no-exit-message]
deploy-all: (deployer-all "switch")

# deploy to all hosts by setting boot
[group('rebuild')]
[no-exit-message]
deploy-all-boot: (deployer-all "boot")

# rebuild the boot
[group('rebuild')]
[no-exit-message]
boot *args: (builder "boot" args)
  lethe diff $(hostname)

# test what happens when you switch
[group('rebuild')]
[no-exit-message]
test *args: (builder "test" args)

# switch the new system configuration
[group('rebuild')]
[no-exit-message]
switch *args:
    #!/usr/bin/env bash
    set -euo pipefail
    just builder switch {{ args }}
    lethe record --local
    lethe diff $(hostname)

[group('rebuild')]
[macos]
[no-exit-message]
provision host:
    sudo nix run github:LnL7/nix-darwin -- switch --flake {{ flake }}#{{ host }}
    sudo -i nix-env --uninstall lix # we need to remove the none declarative install of lix

# package group
# build the package, you must specify the package you want to build

# build the iso image, you must specify the image you want to build
[group('package')]
[no-exit-message]
iso image:
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{ flake }}#nixosConfigurations.{{ image }}.config.system.build.isoImage"
    if [ -n "${CI:-}" ]; then
      nix build "$target"
    else
      nom build "$target"
    fi

# build the tarball, you must specify the host you want to build
[group('package')]
[no-exit-message]
tar host:
    sudo nix run {{ flake }}#nixosConfigurations.{{ host }}.config.system.build.tarballBuilder

# dev group

# check the flake for errors
[group('dev')]
[no-exit-message]
check *args:
    nix flake check --option allow-import-from-derivation false {{ args }}

[group('dev')]
[no-exit-message]
repl-host host=`hostname`:
    nix repl .#nixosConfigurations.{{ host }}

# update a set of given inputs
[group('dev')]
[no-exit-message]
update *input:
    nix flake update {{ input }} \
      --refresh \
      --commit-lock-file \
      --commit-lockfile-summary "flake.lock: update {{ if input == "" { "all inputs" } else { input } }}" \
      --flake {{ flake }}

# build & serve the docs locally
[group('dev')]
[no-exit-message]
serve:
    nix run {{ flake }}#docs.serve

# push to the mirrors
[group('dev')]
[no-exit-message]
push-mirrors:
    git push git@gitlab.com:isabelroses/dotfiles.git
    git push --mirror ssh://git@codeberg.org/isabel/dotfiles.git
    git push --mirror git@tangled.org:isabelroses.com/dotfiles

# rotate all secrets
[group('dev')]
[no-exit-message]
roate-secrets:
    find secrets/ -name "*.yaml" | xargs -I {} sops rotate -i {}

# update the secret keys
[group('dev')]
[no-exit-message]
update-secrets:
    find secrets/ -name "*.yaml" | xargs -I {} sops updatekeys -y {}

# utils group

alias fix := repair

# verify the integrity of the nix store
[group('utils')]
[no-exit-message]
verify *args:
    nix-store --verify {{ args }}

# repairs the nix store from any breakages it may have
[group('utils')]
[no-exit-message]
repair: (verify "--check-contents --repair")

# clean the nix store and optimise it
[group('utils')]
[no-exit-message]
clean:
    nix-collect-garbage --delete-older-than 3d
    nix store optimise
