# Changelog

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
