#!/bin/sh
# Add the chainscope APT repository, then install with:
#
#   sudo apt install chainscope        # dependency-free static CLI (default)
#   sudo apt install chainscope-gui    # desktop application
#   sudo apt install chainscope-cli    # the CLI build, explicitly
#
# chainscope-cli and chainscope-gui both provide /usr/bin/chainscope and are mutually
# exclusive; installing one replaces the other.
set -eu

BASE_URL="https://rng70.github.io/chainscope-apt"
SUITE="stable"
COMPONENT="main"
NAME="chainscope"

KEYRING_DIR=/etc/apt/keyrings
KEYRING="$KEYRING_DIR/$NAME.gpg"
SOURCES="/etc/apt/sources.list.d/$NAME.list"

SUDO=""
[ "$(id -u)" = 0 ] || SUDO="sudo"

for c in curl gpg; do
    command -v "$c" >/dev/null 2>&1 || {
        echo "installing missing prerequisite: $c" >&2
        $SUDO apt-get update -qq
        $SUDO apt-get install -y curl gnupg
        break
    }
done

ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64|arm64|armhf) ;;
    *) echo "error: no $NAME packages for architecture '$ARCH'" >&2; exit 1 ;;
esac

echo "Adding the repository signing key to $KEYRING"
$SUDO install -d -m 0755 "$KEYRING_DIR"
curl -fsSL "$BASE_URL/$NAME.asc" | $SUDO gpg --dearmor --yes -o "$KEYRING"
$SUDO chmod 0644 "$KEYRING"

echo "Adding the package source to $SOURCES"
printf 'deb [arch=%s signed-by=%s] %s %s %s\n' \
    "$ARCH" "$KEYRING" "$BASE_URL" "$SUITE" "$COMPONENT" \
    | $SUDO tee "$SOURCES" >/dev/null

$SUDO apt-get update

cat <<MSG

Done. Install with:

    sudo apt install $NAME          # static CLI, no dependencies
    sudo apt install $NAME-gui      # desktop application

MSG
