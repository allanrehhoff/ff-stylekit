#!/bin/bash

# Files to download from the GitHub repo
BASE_URL="https://raw.githubusercontent.com/allanrehhoff/ff-stylekit/refs/heads/master/src"
FILES=(userChrome.css userContent.css custom.css)

set -e

# Check if we’re inside a Firefox profile folder
if [[ ! -f "prefs.js" && ! -f "user.js" && ! -d "storage" ]]; then
  echo "❌ This doesn’t look like a Firefox profile folder... Aborting"
  exit 1
fi

echo "🧠 We’re in a Firefox profile folder."

# Create chrome directory if it doesn't exist
mkdir -p chrome

# Clean previous files just in case
for file in "${FILES[@]}"; do
  if [[ -f "chrome/$file" ]]; then
    rm "chrome/$file"
  fi
done

echo "🔍 Verifying files exist."
for file in "${FILES[@]}"; do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -I "$BASE_URL/$file")
  if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "❌ File was inaccessible: $file (HTTP $HTTP_STATUS)... Aborting"
    exit 1
  fi
done

# Grab the files from repository and dump them into chrome/'
echo "📦 Downloading files from GitHub."
for file in "${FILES[@]}"; do
  curl -fsSL "$BASE_URL/$file" -o "chrome/$file"
done

echo ""
echo "✅ All files downloaded to chrome/"
echo "⚙️ Set 'toolkit.legacyUserProfileCustomizations.stylesheets' to true in about:config"
echo "👉 Then restart Firefox"

echo ""
read -p "Press Enter to continue..."