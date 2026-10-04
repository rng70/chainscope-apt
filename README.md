# chainscope APT repository

Signed Debian/Ubuntu packages for **chainscope** — a call-graph chain explorer:
load per-artifact `*_cg.json` call graphs, pick a source and a sink function, and
see every call chain between them, within one graph or stitched across several
through stub↔definition bridges (GUI + CLI).

This repository holds **only the published packages and their indices**. It is generated
and pushed by `scripts/release.sh` in the upstream repository; nothing here is edited by
hand.

## Install

```bash
curl -fsSL https://rng70.github.io/chainscope-apt/install.sh | sudo sh
sudo apt install chainscope-gui     # desktop application
sudo apt install chainscope         # or: the dependency-free static CLI
```

The script adds the signing key to `/etc/apt/keyrings/chainscope.gpg`, writes
`/etc/apt/sources.list.d/chainscope.list`, and runs `apt update`. If you would rather do
it by hand:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://rng70.github.io/chainscope-apt/chainscope.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/chainscope.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/chainscope.gpg]" \
     "https://rng70.github.io/chainscope-apt stable main" \
  | sudo tee /etc/apt/sources.list.d/chainscope.list
sudo apt update
```

## Packages

| Package | Contents | Dependencies |
|---------|----------|--------------|
| `chainscope` | metapackage — installs the CLI build | — |
| `chainscope-cli` | fully static build, GUI compiled out | none at all |
| `chainscope-gui` | GUI build, plus a desktop entry and icon | X11/Wayland/OpenGL runtime libraries |

`chainscope-cli` and `chainscope-gui` both provide `/usr/bin/chainscope` and both declare
`Provides: chainscope-bin`, so they are **mutually exclusive** — installing one replaces
the other:

```bash
sudo apt install chainscope        # → chainscope-cli, no X11 dependencies at all
sudo apt install chainscope-gui    # → replaces chainscope-cli, adds the desktop app
```

`apt install chainscope` is equally satisfied by an existing `chainscope-gui` install, so
it will not swap the GUI build out from under you.

Pick `chainscope-cli` for servers, containers and CI gates (`chainscope check`): it is
statically linked and pulls in nothing. Pick `chainscope-gui` for a workstation — it
needs the X11/Wayland and OpenGL client libraries, which apt installs for you.

## Supported releases

| Architecture | `chainscope-cli` | `chainscope-gui` |
|--------------|------------------|------------------|
| `amd64`, `arm64`, `armhf` | any Debian / Ubuntu | Debian 10+ / Ubuntu 20.04+ |

One set of packages serves every release: the GUI build has its glibc floor pinned to
2.17 with [zig](https://ziglang.org/) as the linker, and the CLI build is fully static,
so there is nothing to rebuild per distribution. The GUI package's floor comes from the
names of the X11/Wayland/GL runtime packages it depends on. The repository publishes a
single `stable` suite with one `main` component.

## Verifying the signature

The `Release` file is signed both inline (`InRelease`) and detached (`Release.gpg`) with
this key:

```
pub   rsa4096 2026-10-04 [SC]
      4CEA 0461 8929 D963 88B1  2C5D FEB4 0741 3771 32DD
uid   chainscope APT repository signing key <tanin@openrefactory.com>
```

To check it before trusting anything:

```bash
curl -fsSL https://rng70.github.io/chainscope-apt/chainscope.asc | gpg --show-keys --fingerprint
```

This key signs the repository indices only. It is not a code-signing key and says nothing
about the provenance of the binaries beyond "this repository published them".

## Uninstalling

```bash
sudo apt purge chainscope chainscope-cli chainscope-gui
sudo rm /etc/apt/sources.list.d/chainscope.list /etc/apt/keyrings/chainscope.gpg
sudo apt update
```

## Layout

```
dists/stable/Release            signed index (InRelease + Release.gpg alongside)
dists/stable/main/binary-amd64/ Packages, Packages.gz, Packages.xz
dists/stable/main/binary-arm64/
dists/stable/main/binary-armhf/
pool/main/c/chainscope/         the .deb files themselves
chainscope.asc                  the repository signing key, ASCII-armored
install.sh                      the bootstrap script served to end users
```

The repository is cumulative: indices are regenerated over whatever the pool already
contains, so previously published versions stay installable.

## Other formats

`.rpm` packages and an `AppImage` of the GUI are attached to each GitHub release of the
upstream repository, along with plain `.tar.gz` binaries.

## Source and licence

chainscope is licensed **GPL-3.0-or-later**; the same licence covers the packaging files
in this repository, and its full text is in [LICENSE](LICENSE). The corresponding source
for the binaries published here lives in the upstream repository. If you have received a
binary from this repository and cannot access that repository, you are entitled to the
corresponding source under section 6 of the GPL — request it from
<tanin@openrefactory.com>.
