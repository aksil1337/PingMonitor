@echo off
rem © 2018 Adrian 'Aksil' Nowacki
title Git Backup Branch
cls

for /f %%I in ('git rev-parse --abbrev-ref HEAD') do (
  set ORIGINAL=%%I
)

echo Original branch: & echo   %ORIGINAL% & echo.

echo Postfix for backup branch?
set POSTFIX=backup
set /p POSTFIX="> "
echo.

if "%POSTFIX%"=="backup" (
  git branch -D %ORIGINAL%_backup >nul 2>&1
  set ACTION=Deleted and recreated
) else (
  set ACTION=Created new
)

git checkout -b %ORIGINAL%_%POSTFIX% >nul 2>&1

for /f %%I in ('git rev-parse --abbrev-ref HEAD') do (
  set BACKUP=%%I
)

if "%BACKUP%"=="%ORIGINAL%_%POSTFIX%" (
  echo %ACTION% branch: & echo   %BACKUP% & echo.

  git checkout %ORIGINAL% >nul 2>&1

  echo Backup time: & echo   %DATE% %TIME% & echo.
  echo Switched to original branch... & echo.
) else (
  echo Backup failed! & echo.
  echo Branch '%ORIGINAL%_%POSTFIX%' may already exist... & echo.
)

echo.
pause
