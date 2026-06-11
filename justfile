flake := env('FLAKE', justfile_directory())

# rebuild is also set as a var so you can add --set to change it if you need to
rebuild := if os() == "macos" { "sudo darwin-rebuild" } else { "nixos-rebuild" }
system-args := if os() == "macos" { "" } else { "--elevate run0 --no-reexec" }

# without flakes we address a host by attribute path into ./default.nix
hostname := `hostname`
config-attr := if os() == "macos" { "darwinConfigurations" } else { "nixosConfigurations" }

# common build invocation: nom-monitored, pure-eval build from ./default.nix
build := "nom build"
build-args := "--file " + flake + "/default.nix --option pure-eval true"

[private]
default:
    @just --list --unsorted

# rebuild group

[group('rebuild')]
[no-exit-message]
[private]
builder host goal *args:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ rebuild }} {{ goal }} \
      --file {{ flake }}/default.nix \
      --attr {{ config-attr }}.{{ host }} \
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
    just builder {{ host }} {{ goal }} --target-host {{ host }} --use-substitutes {{ args }}
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
boot *args: (builder hostname "boot" args)
  lethe diff $(hostname)

# test what happens when you switch
[group('rebuild')]
[no-exit-message]
test *args: (builder hostname "test" args)

# switch the new system configuration
[group('rebuild')]
[no-exit-message]
switch *args:
    #!/usr/bin/env bash
    set -euo pipefail
    just builder {{ hostname }} switch {{ args }}
    lethe record --local
    lethe diff $(hostname)

[group('rebuild')]
[macos]
[no-exit-message]
provision host:
    sudo nix run github:LnL7/nix-darwin -- switch --file {{ flake }}/default.nix --attr darwinConfigurations.{{ host }}
    sudo -i nix-env --uninstall lix # we need to remove the none declarative install of lix

# package group
# build the package, you must specify the package you want to build

# build the iso image, you must specify the image you want to build
[group('package')]
[no-exit-message]
iso image:
    {{ build }} {{ build-args }} nixosConfigurations.{{ image }}.config.system.build.isoImage

# build the documentation site
[group('package')]
[no-exit-message]
docs:
    {{ build }} {{ build-args }} packages.docs

# build the tarball, you must specify the host you want to build
[group('package')]
[no-exit-message]
tar host:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$({{ build }} {{ build-args }} nixosConfigurations.{{ host }}.config.system.build.tarballBuilder --no-link --print-out-paths)
    sudo "$out"/bin/*

# dev group

# check the config for errors
[group('dev')]
[no-exit-message]
check *args:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ build }} {{ build-args }} checks \
      --option allow-import-from-derivation false {{ args }}

[group('dev')]
[no-exit-message]
repl-host host=hostname:
    nix repl --expr '(import {{ flake }}/default.nix { }).nixosConfigurations.{{ host }}'

# update a set of given pins (npins), defaulting to all of them
[group('dev')]
[no-exit-message]
update *input:
    #!/usr/bin/env bash
    set -euo pipefail
    npins --directory {{ flake }}/npins update {{ input }}
    git -C {{ flake }} add npins/sources.json
    git -C {{ flake }} commit -m "npins: update {{ if input == "" { "all sources" } else { input } }}"

# build & serve the docs locally
[group('dev')]
[no-exit-message]
serve:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$({{ build }} {{ build-args }} packages.docs.serve --no-link --print-out-paths)
    "$out"/bin/serve

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

# format the config
[group('dev')]
[no-exit-message]
fmt:
  treefmt

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
