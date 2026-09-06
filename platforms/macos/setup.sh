#!/usr/bin/env sh

# From https://github.com/Homebrew/install/blob/master/install.sh
abort() {
	printf "%s\n" "$@"
	exit 1
}

# string formatters
if [ -t 1 ]; then
	tty_escape() { printf "\033[%sm" "$1"; }
else
	tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

ohai() {
	printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$1"
}

# End from https://github.com/Homebrew/install/blob/master/install.sh

set -e

# Keep sudo alive
sudo -v

# Prevent the system from sleeping while the script is running
caffeinate -s -u -w $$ &

install_required_dependencies() {
	ohai "Installing required dependencies"

	if [ ! -f /opt/homebrew/bin/brew ]; then
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	if ! command -v brew >/dev/null 2>&1; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
}

install_required_dependencies || abort "Error installing required dependencies"
