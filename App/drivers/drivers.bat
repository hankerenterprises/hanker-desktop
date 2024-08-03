@echo off

ECHO Installing Driver. . . .
msiexec /i "%CD%\driver.msi"
ECHO Done.

ECHO .
ECHO Installing CLI Utilities. . . .
msiexec /i "%CD%\app.msi"
ECHO Done.

ECHO .
ECHO Run HE file before continuing. . . .
ECHO .
ECHO .
ECHO .

PAUSE

ECHO Uninstalling CLI Utilities. . . .
msiexec /i "%CD%\app.msi"
ECHO Done.
ECHO .

ECHO Uninstalling Driver. . . .
msiexec /i "%CD%\driver.msi"
ECHO Done.