# Changelog

## 1.13c Launch Fix (2024-10-31)
- Fixed a bug that allowed multiple instances of the application to be launched from a single executable file

## 1.13b Shutdown Fix (2024-10-30)
- Fixed a bug that prevented Windows from shutting down while the application is running

## 1.13 Automatic Startup (2024-10-29)
+ Added an option to automatically run the application at system startup

## 1.12 Tray Icon (2024-10-27)
+ Created the Tray unit to allow running the application in the system tray without displaying it in the taskbar

## 1.11b Window Visibility Fix (2024-10-23)
- Fixed a bug that caused the Auxiliary form to disappear when another application gained focus

## 1.11 Ping Chart (2024-10-22)
+ Added a colorful chart on the Auxiliary form to visually represent the latency and jitter values

## 1.10 Ping Jitter (2024-10-19)
+ Added a mechanism to determine ping jitter and display it in the log
- Fixed a bug that delayed sending the next ping after a timeout

## 1.9 Window Location (2024-10-16)
+ Added the ability to save window location in the INI file

## 1.8 Settings (2024-10-13)
+ Added the Settings class to store configuration inside an INI file
* Adjusted the color palette to improve visibility and distinguishability of the latency ranges

## 1.7 Window Snap (2024-10-12)
+ Added the ability to snap the Main form to the edge of the screen
* Bound the Auxiliary form to the Main form using a permanent snap
* Linked the positions of the Auxiliary form and Inspect Grid to the position of the Main form

## 1.6 Ping Log (2024-10-11)
+ Created the Auxiliary form displaying detailed information about recent ICMP echo replies

## 1.5b Repaint Fix (2024-10-10)
- Fixed a bug that caused the Inspect Grid to briefly appear blank after the Main form was obscured

## 1.5 Ping Throttle (2024-10-09)
+ Added a throttling mechanism to send more pings while maintaining a similar refresh rate
* Replaced the Timer component with an infinite loop inside the Ping Thread to gain more control over the process

## 1.4 Inspect Grid (2024-10-08)
+ Added a colorful grid to be able to visually inspect the last few latency values

## 1.3 Ping Thread (2024-10-07)
+ Added a separate execution thread to prevent blocking the UI while waiting for ICMP echo replies

## 1.2 Icon and Menu (2024-10-05)
+ Added high-definition application icon
+ Added popup menu
+ Added git-backup and update-version scripts

## 1.1b Page Fault Fix (2024-10-04)
- Fixed a bug with incremental Page Faults by refactoring the Ping class

## 1.1 Drag Move (2024-10-03)
+ Added a possibility to drag the Main form using a mouse

## 1.0 Initial Release (2024-10-02)
+ Created the Main form displaying a color-changing label reflecting the current latency value
+ Created the Ping class to handle ICMP echo requests
+ Included the appropriate LICENSE file
+ Included a basic README file
+ Included a CHANGELOG file
