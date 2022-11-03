# Growtopia Auto Updater

Growtopia Auto Updater can automatically detect if a new version of Growtopia is available, as well as to download and silent-install the updated version, without needing the user to manually download the update themselves.

Growtopia Auto Updater currently only supports Windows.

#### Growtopia Auto Updater by sadfaceman
<a href="https://discord.gg/2QY3dck9RY" target=_blank><img src="https://drive.google.com/thumbnail?id=1vBtDJR6I7AmdS3tf9UtPhj2dWnrFEgsE" alt="Discord" width="16" height="16" style="float:left">**Sad's Multiverse of Sadness**</img>

## How to install
### Windows
1. [Install AutoHotkey](https://www.autohotkey.com "Install AutoHotkey") (Optional)
2. Close Growtopia if it's running
3. Extract the contents of `GTAutoUpdater-Installer.zip`
4. Run `GTAutoUpdater-Installer.exe` (or `GTAutoUpdater-Installer.ahk` if AutoHotkey is installed, both are identical)

The installer will install Growtopia Auto Updater to your Growtopia directory, and a new shortcut will be created on your desktop. To launch Growtopia Auto Updater, simply double click the shortcut.

Remarks :

- Growtopia Auto Updater obtains the version info from two sources, the current installed version from the Growtopia.exe executable, and the latest version from the Google Play Store page of Growtopia. If the Google Play Store page falls out of sync with the Windows latest version, this program will function incorrectly
- Growtopia Auto Updater does ***not*** continuously check for a new version of growtopia. Instead, it only checks for a new version when it is launched, after which the program closes. This is done to avoid rate limiting done by Google Play Store
- Launching Growtopia Auto Updater will automatically launch Growtopia. To disable this, press `e` while Growtopia Auto Updater is running, or open `Growtopia\GTAutoUpdater\AutoLaunchGT` file and change the `1` to a `0`
