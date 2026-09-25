# bridgelink-launcher
An open source Admin Launcher for BridgeLink (and OSS Mirth Connect)

## Windows Release (installer with embedded Java)

The Windows release ships as a single `.exe` installer (`BridgeLinkLauncher-<version>-windows-x64-setup.exe`)
that embeds a **private Java 17 runtime with JavaFX** (Zulu FX): end users do **not** need Java installed.

What it installs (under `%LocalAppData%\Programs\BridgeLinkLauncher`, no admin rights required):

- `BridgeLinkLauncher.exe` — native launcher (launch4j) bound to the embedded `jre\`
- `bridge-link-launcher-<version>.jar` — the application
- `jre\` — embedded JavaFX 17 runtime (this is the "Bundled Java 17" used at launch)
- `lib\java-console.jar` — helper for the "Show Java Console" option

Build it locally on a Windows machine with:

```powershell
powershell -ExecutionPolicy Bypass -File .\build\windows\build-installer.ps1
```

The script builds with Maven (`-Pwindows-release`), provisions the JRE, assembles the app folder
and compiles the installer with Inno Setup 6 (output in `build/windows/output/`).

CI does the same automatically on every GitHub release (see `.github/workflows/windows-release.yml`):
the installer is built on a Windows runner and attached to the release as an artifact.

Notes:

- The launcher prefers `javaw.exe` on Windows, so no extra console window appears.
- The installer is per-user; saved connections live in `data\` inside the install folder and
  are kept when upgrading (only `cache\` is removed on uninstall).
- Connections that use a **custom** Java home are unaffected; connections using "Bundled Java"
  will use the embedded runtime installed alongside the app.

## MacOS Specific Instructions
Because the application is not signed by Apple, you may get a security warning and have to manually override your security settings to grant an exception to the launcher.

**Known Issue:**
If you extract the BridgeLink Launcher application straight to your Downloads folder, it will give you an error about "Read-Only Filesystem" when you try to save an entry.

To prevent this, you can do one of the following:
- Move the application to a different folder, such as /Applications or ~/Applications
- Create a new folder inside downloads then move the application there
- Enable All Applications in MacOS Gatekeeper by following these steps:
  * Open up System Settings
  * In System Settings, navigate to "Privacy & Security". Leave Window Open in the Background
  * Open up Terminal (as separate window). DO NOT CLOSE System Settings
  * In Terminal, run "sudo spctl --master-disable" --> Type Password --> Click Enter
  * In System Settings, navigate out of "Privacy & Security" Page (For Example -- Click on "Lockscreen"), then navigate back to "Privacy & Security"
  * In System Settings --> Privacy & Security Page --> Scroll Down to bottom --> Select "Allow Application From" --> Select "Anywhere" (the option will now appear) --> Type Password
Completed

## Upgrading via macOS DMG

When installing a new version of BridgeLink Launcher using the macOS `.dmg`, your connection data is stored inside the application bundle and **will be overwritten** if you simply drag the new version into `/Applications`.

To preserve your connections and settings, follow these steps before upgrading:

1. **Before upgrading**, open Finder and navigate to your current application:
   - Right-click `BridgeLink Administrator Launcher.app` → **Show Package Contents**
   - Navigate to `Contents/Resources/app/data/`
   - Copy the entire `data` folder to a safe temporary location (e.g., your Desktop)

2. **Install the new version** by mounting the new `.dmg` and dragging the application to `/Applications`, replacing the old one.

3. **After upgrading**, restore your data:
   - Right-click the newly installed app → **Show Package Contents**
   - Navigate to `Contents/Resources/app/`
   - Copy your saved `data` folder back into this location, replacing the new empty one

Your connections and settings will now be restored in the upgraded application.


## License

This project is licensed under the Mozilla Public License 2.0 (MPL-2.0). 

You are free to use, modify, and distribute this software under the terms of the MPL-2.0 license. This license requires that if you distribute modified versions of this software, you must also make the source code of those modifications available under the MPL-2.0.

For full details, see the [LICENSE](LICENSE) file or visit the [MPL-2.0 documentation](https://www.mozilla.org/en-US/MPL/2.0/).
