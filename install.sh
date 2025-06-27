#!/usr/bin/env bash

# Print functions
write() {
	if [[ -n "$1" ]]; then
		echo "👉 $1"
	else
		echo ""
	fi
}

warn() {
	echo "⚠️ $1"
}

await() {
	if [ -t 0 ]; then
		read -p "Press Enter to continue..."
	fi
}

panic() {
	exit 1
}

error() {
	echo "❌ $1" >&2
	await
	panic
}

# Check if running in WSL
# This function checks if the parent process is a Windows terminal or WSL.
# Required because windows terminals like PowerShell can hand over control to WSL,
# when piping to bash, preventing the script from reading /dev/stdin and /dev/tty.
is_wsl() {
	ppid=$(ps -o ppid= -p $$ | tr -d ' ')
	parent_proc=$(ps -o comm= -p "$ppid" | tr '[:upper:]' '[:lower:]')

	if [[ "$parent_proc" =~ ^(powershell|cmd|bash|zsh|fish|curl|wget)$ ]]; then
		return 0
	else
		return 1
	fi
}

# Check platform and set profiles directory
get_profiles() {
	if [[ "$(uname -s)" == "Linux" ]]; then
		if grep -qiE 'microsoft|wsl' /proc/version; then
			# Because WSL can be run from a Windows terminal, we need to check if we are in WSL
			# If we are in WSL, we can use the Windows AppData path to find the Firefox profiles.
			# If we are in a Windows terminal, we cannot use /dev/tty or /dev/stdin
			is_wsl || error "This script must be run from WSL, windows terminals are not supported"

			WIN_APPDATA=$(cmd.exe /C "echo %APPDATA%" 2>/dev/null | tr -d '\r')
			PROFILES_DIR="$(wslpath "$WIN_APPDATA")/Mozilla/Firefox/Profiles"
		else
			PROFILES_DIR="$HOME/.mozilla/firefox/Profiles"
		fi
	elif [[ "$(uname -s)" == "Darwin" ]]; then
		PROFILES_DIR="$HOME/Library/Application Support/Firefox/Profiles"
	else
		error "Unsupported operating system: $(uname -s)"
	fi

	if [[ ! -d "$PROFILES_DIR" ]]; then
		error "Could not find Firefox profiles directory"
	fi
}

# Lets user pick the profile
set_profiles() {
	cd "$PROFILES_DIR" || error "Failed to enter profiles directory"

	profiles=()
	while IFS= read -r dir; do
		profiles+=("$dir")
	done < <(find . -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

	if [[ ${#profiles[@]} -eq 0 ]]; then
		error "No Firefox profiles found."
	elif [[ ${#profiles[@]} -eq 1 ]]; then
		SELECTED_PROFILE="${profiles[0]}"
		write "Found profile: $SELECTED_PROFILE"
	else
		# Maybe use a different input to select profile?
		# WSL is wierd with /dev/tty
		# if [ -r /dev/tty ] && [ -w /dev/tty ]; then
		# 	input_source="/dev/tty"
		# else
		# 	input_source="/dev/stdin"
		# fi
		write "Select install profile:"

		PS3='Enter number: '
		select SELECTED_PROFILE in "${profiles[@]}"; do
			if [[ -n "${SELECTED_PROFILE}" ]]; then
				break
			fi
		done < /dev/tty

		if [[ -z "$SELECTED_PROFILE" ]]; then
			error "No profile selected"
		fi

		clear
		write "Using profile: $SELECTED_PROFILE"
	fi
}

# Check remote files exist
verify() {
	BASE_URL="https://raw.githubusercontent.com/allanrehhoff/ff-stylekit/refs/heads/master/src"
	files=(userChrome.css userContent.css custom.css)

	write "Verifying remote files exists"
	for file in "${files[@]}"; do
		if ! curl --head --silent --fail "$BASE_URL/$file" > /dev/null; then
			error "File $file does not exist at the remote URL"
		fi
	done
}

# Download and install
install() {
	TARGET="$PROFILES_DIR/$SELECTED_PROFILE/chrome"
	mkdir -p "$TARGET" || error "Failed to create chrome/ directory"

	rm -f "$TARGET"/*.css || error "Failed to clean chrome/ directory"

	write "Downloading files from repository"

	for file in "${files[@]}"; do
		curl -fsSL "$BASE_URL/$file" -o "$TARGET/$file" || error "Failed to download $file."
	done
}

# Main logic
main() {
	get_profiles
	set_profiles
	verify
	install

	write ""
	write "Installed in: $PROFILES_DIR/$SELECTED_PROFILE/chrome"
	write "Set 'toolkit.legacyUserProfileCustomizations.stylesheets' to true in about:config"

	await
	exit 0
}

main
