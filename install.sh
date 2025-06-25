#!/bin/bash

# Function to detect the platform
# Returns: linux, macos, windows, wsl, or unknown
detect_platform() {
	local uname_out
	uname_out="$(uname -s)"

	case "${uname_out}" in
		Linux*)
			if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
				echo "wsl"
			else
				echo "linux"
			fi
			;;
		Darwin*)
			echo "macos"
			;;
		MINGW*|MSYS*|CYGWIN*)
			echo "windows"
			;;
		*)
			echo $uname_out
			;;
	esac
}

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
	echo "❌ $1"
	await
	panic
}

# Files to download from the GitHub repo
BASE_URL="https://raw.githubusercontent.com/allanrehhoff/ff-stylekit/refs/heads/master/src"
FILES=(userChrome.css userContent.css custom.css)
PLATFORM=$(detect_platform)

# Detect profile base path
case "$PLATFORM" in
	linux)
		PROFILE_BASE="$HOME/.mozilla/firefox/Profiles"
		;;
	macos)
		PROFILE_BASE="$HOME/Library/Application Support/Firefox/Profiles"
		;;
	windows)
		WIN_APPDATA=$(cmd.exe /C "echo %APPDATA%" 2>/dev/null | tr -d '\r')
		PROFILE_BASE="$(echo "$WIN_APPDATA" | sed 's#\\#/#g')/Mozilla/Firefox/Profiles"
		;;
	wsl)
		WIN_APPDATA=$(cmd.exe /C "echo %APPDATA%" 2>/dev/null | tr -d '\r')
		PROFILE_BASE="$(wslpath "$WIN_APPDATA")/Mozilla/Firefox/Profiles"
		;;
	*)
		error "Unsupported platform: $PLATFORM"
		;;
esac

# Check base exists
if [[ ! -d "$PROFILE_BASE" ]]; then
	error "Profile directory not found: $PROFILE_BASE"
fi

# Get all folders (not files) in profile base
PROFILES=()
for dir in "$PROFILE_BASE"/*/; do
	[[ -d "$dir" ]] && PROFILES+=("$dir")
done

# Check if any profiles were found
if [[ ${#PROFILES[@]} -eq 0 ]]; then
	error "No profiles found in: $PROFILE_BASE"
fi

# If only one profile, use it
if [[ ${#PROFILES[@]} -eq 1 ]]; then
	PROFILE_DIR="${PROFILES[0]}"
	write "Using profile directory: $PROFILE_DIR"
else
	write "Multiple profiles found, select one"
	select PROFILE_DIR in "${PROFILES[@]}"; do
		if [[ -n "$PROFILE_DIR" ]]; then
			break
		else
			warn "Invalid choice. Try again."
		fi
	done
	clear
	write "Using profile directory: $PROFILE_DIR"
fi

cd "$PROFILE_DIR"

# Create chrome directory if it doesn't exist
mkdir -p chrome

# Clean previous files just in case
for file in "${FILES[@]}"; do
	if [[ -f "chrome/$file" ]]; then
		rm "chrome/$file"
	fi
done

write "Verifying remote files exist."
for file in "${FILES[@]}"; do
	HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -I "$BASE_URL/$file")
	if [[ "$HTTP_STATUS" != "200" ]]; then
		error "File was inaccessible: $file (HTTP $HTTP_STATUS)... Aborting"
	fi
done

# Grab the files from repository and dump them into chrome/'
write "Downloading files from repository."
for file in "${FILES[@]}"; do
	curl -fsSL "$BASE_URL/$file" -o "chrome/$file"
done

write
write "Files downloaded successfully."
write "Set 'toolkit.legacyUserProfileCustomizations.stylesheets' to true in about:config"
write "Then restart Firefox"
write

await