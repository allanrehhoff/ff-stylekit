# Firefox Custom UI Styling

A custom theme for Firefox's UI and internal pages using `userChrome.css` and `userContent.css`.
This setup customizes the accent color, UI elements, internal pages (like about:preferences).

## Automatic install
Run the following command from your Firefox profile folder.  
`curl -sL https://raw.githubusercontent.com/allanrehhoff/ff-stylekit/refs/heads/master/install.sh | bash`

## Manual install

1. **Find your Firefox profile folder**
   See instructions below

2. **Download contents**

   Copy the contents of the `src/` folder and place it inside the `chrome` folder of your Firefox profile.

3. **Enable user stylesheets in Firefox**

   Go to `about:config`, then:
   - Set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`
   - Restart Firefox (yes, you have to)

## Find your firefox profile folder
   - Open `about:profiles` in Firefox
   - Look for the **Root Directory** of your active profile
   - Open it in your file explorer
   - Create a `chrome` folder if it doesn’t already exist

## Customizing colors
1. **Customize your accent color**

   Open `custom.css` and change the values to your desired color codes.  

2. **Restart firefox**

   After changes, restart Firefox to apply the styles.