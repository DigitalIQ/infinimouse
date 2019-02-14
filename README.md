# InfiniMouse

_Forked from @angel333 - bugfixed and extended by myself_

If you move mouse to one border, it will come back from the other. It's like PacMan with the cursor.

Works for multiple screens too, but will have issues if the screen layout doesn't make a perfect rectangle (e.g. for different resolutions).


## Settings

Settings are hardcoded in the script. By default, only left and right borders are used. Also the main loop delay is hardcoded.

Via tray icon context menu you can set the following:
- Enable/disable left, right, top and bottom border
- Enable/disable InfiniMouse
- Restart and exit InfiniMouse

Border settings will be stored in C:\Users\[your username]\AppData\Roaming\InfiniMouse\settings.ini after the first change of the settings via tray icon context menu. The saved settings are set at the next time InfiniMouse will be run.

## Installation

- Install SciTE4AutoIt3 (I would recommend)
- Open the file infinimouse.au3 with SciTE Editor
- Press F7 or click Tools > Build
  - This creates an infinimouse.exe file in the same folder of the infinimouse.au3 file
- Run the infinimouse.exe file
  - You'll see the tray icon :)

## Known issues
(which I'll maybe fix in a later version)

- [ ] _Is there something? Let me know!_

## License

MIT
