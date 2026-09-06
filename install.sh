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

download() {
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL "$1"
	else
		wget -qO- "$1"
	fi
}

detect_platform() {
	platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

	case "${platform}" in
	linux) platform="linux" ;;
	darwin) platform="macos" ;;
	mingw* | msys* | cygwin*) platform="win32" ;;
	windows*) platform="win32" ;;
	esac

	printf '%s' "${platform}"
}

download_and_install() {
	platform="$(detect_platform)"
	tmp_dir="$(mktemp -d)" || abort "Tmpdir Error!"

	ohai "Downloading setup script for $platform"

	download "https://github.com/leorodriguesf/bootstrap/raw/refs/heads/main/platforms/$platform/setup.sh" >"$tmp_dir/setup.sh" 2>/dev/null || abort "Platform $platform does not have setup script. Consider adding one!"

	chmod +x "$tmp_dir/setup.sh"

	source "$tmp_dir/setup.sh"

	ohai "Cloning repository"

	git clone https://github.com/leorodriguesf/bootstrap.git "$tmp_dir/bootstrap"

	DEPS_DIR="$tmp_dir/bootstrap/platforms/$platform/dependencies"

	if [ -d "$DEPS_DIR" ]; then
		ohai "Installing dependencies from $DEPS_DIR"
		echo ""

		for script in "$DEPS_DIR"/*; do
			if [ -f "$script" ]; then
				$script
			fi
		done
	else
		echo "Platform $platform does not have dependencies. Consider adding at least one!"
	fi
}

download_and_install || abort "Install Error!"
