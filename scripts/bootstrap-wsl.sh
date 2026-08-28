#!/bin/sh
# Run inside Ubuntu WSL, not PowerShell.
# Official: https://docs.postmarketos.org/pmbootstrap/main/installation.html
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ "$(uname -s)" != "Linux" ]; then
	echo "pmbootstrap only runs on Linux. Install WSL2 Ubuntu, then run this script there." >&2
	exit 1
fi

sudo apt-get update
sudo apt-get install -y git python3 openssl

if [ ! -d "$ROOT/pmbootstrap/.git" ]; then
	git clone --depth=1 https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git "$ROOT/pmbootstrap"
fi

mkdir -p "$HOME/.local/bin"
ln -sfn "$ROOT/pmbootstrap/pmbootstrap.py" "$HOME/.local/bin/pmbootstrap"

case ":$PATH:" in
	*:"$HOME/.local/bin":*) ;;
	*) echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile" ;;
esac

export PATH="$HOME/.local/bin:$PATH"
pmbootstrap --version

echo
echo "Next (interactive):"
echo "  pmbootstrap init"
echo "    work path: default is fine"
echo "    channel:   edge"
echo "    vendor:    xiaomi"
echo "    device:    sirius     (new device — let it scaffold, then we overwrite with overlay/)"
echo "    ui:        none       (console is enough for a server / bring-up)"
echo "Then:  ./scripts/sync-overlay.sh"
echo "Then:  pmbootstrap checksum device-xiaomi-sirius"
echo "Then:  pmbootstrap build device-xiaomi-sirius"
