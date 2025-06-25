# Firefox Custom UI Styling

A custom theme for Firefox's UI and internal pages using `userChrome.css` and `userContent.css`.
This setup customizes the accent color, UI elements, internal pages (like about:preferences).

## Automatic install
> [!IMPORTANT]  
> **Configuration flag required**
> You must manually set `toolkit.legacyUserProfileCustomizations.stylesheets` to true in `about:config`
> Restart firefox after enabling this option.

The following command will attempt to automatically detect your Firefox profiles directory.  
If it fails, proceed to manual installation below.  

`curl -sL https://raw.githubusercontent.com/allanrehhoff/ff-stylekit/master/install.sh | bash`

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