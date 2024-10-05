@echo off
rem © 2024 Adrian 'Aksil' Nowacki
title Update Version Info
cls

for /f "skip=2 delims=" %%I in (CHANGELOG.md) do (
  set VERSION=%%I
  goto :break
)
:break

echo Latest version: & echo   %VERSION:~3% & echo.

for %%F in ("src\*.dof") do (
  if "%%~xF"==".dof" (
    set PROJECT=%%~nF
  )
)

set UPDATE=File does not exist

if exist "src\%PROJECT%.dof" (
  inifile "src\%PROJECT%.dof" [Version Info Keys] "ProductVersion=%VERSION:~3%"

  if %ERRORLEVEL% equ 0 (
    set UPDATE=Updated file
  ) else (
    set UPDATE=Update failed for file
  )
)

echo %UPDATE%: & echo   %PROJECT%.dof & echo.

set DELETE=File does not exist

if exist "src\%PROJECT%.res" (
  del /q /f "src\%PROJECT%.res"

  if %ERRORLEVEL% equ 0 (
    set DELETE=Deleted file
  ) else (
    set DELETE=Delete failed for file
  )
)

echo %DELETE%: & echo   %PROJECT%.res & echo.

echo Please reopen the project... & echo.

echo.
pause
