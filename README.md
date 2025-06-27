# Firefox Custom UI Styling

A custom style kit for Firefox's internal pages and elements using `userChrome.css` and `userContent.css`.
This stylekit customizes the generel appearance of Firefox.

Elements include (but not limited to):
- Highlight colors
- Sizes
- Tabs
- Urlbar
- Inputs
- Prompts (alert, confirm etc.)
- about:preferences
- about:config

Heavily inspired by Firefox proton design.  
Hides some duplicate buttons and annoying features when using vertical tabs.

## Automatic install
> [!NOTE]  
> **Windows support**  
> Windows support is limited, you must run this script from Windows Subsystem for Linux (WSL)

> [!IMPORTANT]  
> **Configuration flag required**  
> You must manually set `toolkit.legacyUserProfileCustomizations.stylesheets` to true in `about:config`  
> Restart firefox after enabling this option.

The following command will attempt to automatically detect your Firefox profiles directory.  
If it fails, proceed to manual installation below.  

**Command:**  
`curl -sL https://raw.githubusercontent.com/allanrehhoff/ff-stylekit/refs/heads/master/install.sh | bash`

## Manual install

1. **Find your Firefox profile folder**  
   - Open `about:profiles` in Firefox
   - Look for the **Root Directory** of your active profile
   - Open it in your file explorer
   - Create a `chrome` folder if it doesn’t already exist

2. **Download contents**  
   - Clone contents of this repository to you machine
   - Copy the contents of the `src/` folder and place it inside the `chrome` folder of your Firefox profile.

3. **Enable user stylesheets in Firefox**  
   - Go to `about:config`, then:
   - Set  to `true`
   - Restart Firefox

## Customizing colors
1. **Customize your accent color**  
   Open `custom.css` and change the values to your desired color codes.  

2. **Restart firefox**  
   After changes, restart Firefox to apply the styles.