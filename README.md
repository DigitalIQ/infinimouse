# InfiniMouse

_Forked from @angel333 - bugfixed and extended by myself_

If you move the cursor to one screen border, it will come back from the other side. It's like PacMan.

Works for multiple screens too, but will have issues if the screen layout doesn't make a perfect rectangle (e.g. for different screen resolutions).


## Settings

By default, only left and right borders are enabled. The main loop delay is set on default by 50ms.

Via tray icon context menu you can set the following:
- Enable/disable left, right, top and bottom border
- Change the Delay of catching the cursor at the borders and beam it to the other side
- Enable/disable InfiniMouse (it's like pausing it)
- If InfiniMouse is installed you're able to uninstall it from here

Border settings will be stored in C:\Users\[your username]\AppData\Roaming\InfiniMouse\settings.ini after the first change of the settings via tray icon context menu. The saved settings will be set at the next time InfiniMouse is executed.

## Installation

- Install SciTE4AutoIt3 (I would recommend)
- Open the file infinimouse.au3 with SciTE Editor
- Press F7 or click Tools > Build
  - This creates an infinimouse.exe file in the same folder of the infinimouse.au3 file
- Run the infinimouse.exe file
  - You'll be asked if you want to install InfiniMouse persitant or run it as a portable app.
  - You'll see the tray icon with its settings menu :)

## Known issues
(which I'll maybe fix in a later version)

- [ ] _Is there something? Let me know!_
- [ ] Settings.ini will be stored always in the AppData folder, even though you start the program without installing it as a portable app. Storing the settings.ini should be stored in the workfolder when you run it portable.
- [x] Settings are not hardcoded anymore or can be at least changed.
- [x] Fixing the bug that cause problems with catching the cursor when the screen size changes (e.g. by attaching/detaching additional displays.
- [x] If the installation process fails for whatever reason, the already created files will be deleted.

## License

MIT
