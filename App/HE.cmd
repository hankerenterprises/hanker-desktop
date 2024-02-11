@echo off
title HE - Login
color 07
mode 55,18

SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in ('echo prompt $E ^| cmd') do ( set "ESC=%%a" )

for /f "delims=" %%a in ('findstr /i "DBSERVER=" F:\PHWin\Phw.ini') do set %%a
set DBSERVER=%DBSERVER%
for /f "delims=" %%a in ('findstr /i "CATALOG=" F:\PHWin\Phw.ini') do set %%a
set CATALOG=%CATALOG%

set pass=8048031010

REM Get today's date in the format YYYY-MM-DD
for /F "tokens=1-3" %%a in ('wmic.exe Path Win32_LocalTime Get Day^,Month^,Year /Format:table ^| findstr /r "^[0-9]"') do (
    set "YYYY=%%c"
    set "MM=%%b"
    set "DD=%%a"
)

REM Add leading zeros if needed
if %MM% LSS 10 set MM=0%MM%
if %DD% LSS 10 set DD=0%DD%

set "TODAY=%YYYY%-%MM%-%DD%"
set "MONTH_START=%YYYY%-%MM%-01"

set DATEF=%MONTH_START%
set DATET=%TODAY%


:login
cls
echo.
echo  ----------------------------------------------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                        %ESC%[33mLog In%ESC%[0m
echo  ----------------------------------------------------
echo.
set /p upass="%ESC%[33mEnter Password: %ESC%[30m"
if not %upass%==%pass% (
goto:login
)

:mainmenu
title Hanker Enterprises
cls
echo.
echo  %ESC%[0m------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo        [1] All               [4] Payments
echo        [2] Billed            [5] RxPay
echo        [3] Insurances        
echo.
echo.
echo      Date From: %ESC%[36m%DATEF%%ESC%[0m - Date To: %ESC%[36m%DATET%%ESC%[0m
echo         ------------------------------------
echo        [7] Set Server Name   [9] Set Date Range
echo        [8] Set Catalog Name  [0] Exit
echo.
echo      Server: %ESC%[32m%DBSERVER%%ESC%[0m Catalog: %ESC%[32m%CATALOG%%ESC%[0m
echo  ----------------------------------------------------
echo.
echo %ESC%[33mEnter a menu option:%ESC%[0m
choice /C:1234567890 /N
set _erl=%errorlevel%

if %_erl%==10 exit /b
if %_erl%==9 goto:datemenu
if %_erl%==8 goto:catalogmenu
if %_erl%==7 goto:servermenu
if %_erl%==6 goto:mainmenu
if %_erl%==5 goto:rxpay
if %_erl%==4 goto:payments
if %_erl%==3 goto:insurances
if %_erl%==2 goto:billed
if %_erl%==1 goto:all
goto:mainmenu


:billed
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo            Exporting Billed scripts. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT [DATEF],[DATEO],[RXNO],[NREFILL],[STATUS],[PATIENTNO],[PRESNPINO],[PRESLNM],[PRESFNM],[GROUPNO],[NDC],[DRGNAME],[STRONG],[FORM],[QUANT],[DAYS],[PICKEDUP],[DELIVERY],[PICKUPDATE] FROM [PharmSQL].[dbo].[RxDetails] WHERE [STATUS] = 'B';"  -o "%USERPROFILE%\Desktop\Prescriptions-Billed.csv" -W -s,
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                         Done
echo  -----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:insurances
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo          Exporting Insurance Profiles. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT [IC_CODE],[IC_NAME],[BIN_NO],[MAG_CODE],[ADDRESS] FROM [PharmSQL].[dbo].[INSCAR]"  -o "%USERPROFILE%\Desktop\Insurances.csv" -W -s,
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                         Done
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:payments
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                Exporting Payments. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT [RXNO],[NREFILL],[ClmStatus],[PriIns],[PriInsPaid],[SecIns],[SecInsPaid], [TerIns],[TerInsPaid],[TotalInsPaid],[TotalPatCoPay],[TotalRXAmount],[TotalCost] FROM [PharmSQL].[dbo].[ClaimPaymentView] WHERE [CLMSTATUS] = 'B';"  -o "%USERPROFILE%\Desktop\Payments.csv" -W -s,
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                         Done
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:all
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                   Exporting All. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT [DATEF],[DATEO],[RXNO],[NREFILL],[STATUS],[PATIENTNO],[PRESNPINO],[PRESLNM],[PRESFNM],[GROUPNO],[NDC],[DRGNAME],[STRONG],[FORM],[QUANT],[DAYS],[PICKEDUP],[DELIVERY],[PICKUPDATE] FROM [PharmSQL].[dbo].[RxDetails] WHERE [STATUS] = 'B';"  -o "%USERPROFILE%\Desktop\Prescriptions-Billed.csv" -W -s,
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT [IC_CODE],[IC_NAME],[BIN_NO],[MAG_CODE],[ADDRESS] FROM [PharmSQL].[dbo].[INSCAR]"  -o "%USERPROFILE%\Desktop\Insurances.csv" -W -s,
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT [RXNO],[NREFILL],[ClmStatus],[PriIns],[PriInsPaid],[SecIns],[SecInsPaid], [TerIns],[TerInsPaid],[TotalInsPaid],[TotalPatCoPay],[TotalRXAmount],[TotalCost] FROM [PharmSQL].[dbo].[ClaimPaymentView] WHERE [CLMSTATUS] = 'B';"  -o "%USERPROFILE%\Desktop\Payments.csv" -W -s,
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT * FROM [PharmSQL].[dbo].[RXPay];"  -o "%USERPROFILE%\Desktop\RXPay.csv" -W -s,
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                         Done
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:rxpay
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                 Exporting RxPay. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;SELECT * FROM [PharmSQL].[dbo].[RXPay];"  -o "%USERPROFILE%\Desktop\RxPay.csv" -W -s,
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                         Done
echo  -----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:servermenu
cls
echo.
echo  %ESC%[0m------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo     [1] Manual
echo     [2] Auto
echo.
echo.
echo                           [0] Main Menu
echo.
echo         ------------------------------------
echo.
echo.
echo.
echo     Server: %ESC%[32m%DBSERVER%%ESC%[0m
echo  ----------------------------------------------------
echo.
echo %ESC%[33mEnter a menu option:%ESC%[0m
choice /C:120 /N
set _erl=%errorlevel%

if %_erl%==1 goto:serverset
if %_erl%==3 goto:mainmenu
if %_erl%==2 for /f "delims=" %%a in ('findstr /i "DBSERVER=" F:\PHWin\Phw.ini') do set %%a
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     NEW Server Name: %ESC%[32m%DBSERVER%%ESC%[0m
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:serverset
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     Current Server Name: %ESC%[32m%DBSERVER%%ESC%[0m
echo  ----------------------------------------------------
echo.
set /p DBSERVER="  %ESC%[33mEnter NEW Server Name: %ESC%[0m"
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     NEW Server Name: %ESC%[32m%DBSERVER%%ESC%[0m
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:catalogmenu
cls
echo.
echo  %ESC%[0m------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo     [1] Manual
echo     [2] Auto
echo.
echo.
echo                           [0] Main Menu
echo.
echo         ------------------------------------
echo.
echo.
echo.
echo     Catalog: %ESC%[32m%CATALOG%%ESC%[0m
echo  ----------------------------------------------------
echo.
echo %ESC%[33mEnter a menu option:%ESC%[0m
choice /C:120 /N
set _erl=%errorlevel%

if %_erl%==1 goto:catalogset
if %_erl%==3 goto:mainmenu
if %_erl%==2 for /f "delims=" %%a in ('findstr /i "CATALOG=" F:\PHWin\Phw.ini') do set %%a
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     NEW Catalog Name: %ESC%[32m%CATALOG%%ESC%[0m
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:catalogset
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     Current Catalog Name: %ESC%[32m%CATALOG%%ESC%[0m
echo  ----------------------------------------------------
echo.
set /p CATALOG="  %ESC%[33mEnter NEW Catalog Name: %ESC%[0m"
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     NEW Catalog Name: %ESC%[32m%CATALOG%%ESC%[0m
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:datemenu
cls
echo.
echo  %ESC%[0m------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo     [1] Select Range
echo     [2] Default
echo.
echo.
echo                           [0] Main Menu
echo.
echo         ------------------------------------
echo.
echo.
echo.
echo     Date From: %ESC%[36m%DATEF%%ESC%[0m - Date To: %ESC%[36m%DATET%%ESC%[0m
echo  ----------------------------------------------------
echo.
echo %ESC%[33mEnter a menu option:%ESC%[0m
choice /C:120 /N
set _erl=%errorlevel%

if %_erl%==1 goto:dateset
if %_erl%==3 goto:mainmenu
if %_erl%==2 set DATEF=%MONTH_START%
set DATET=%TODAY%
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo   NEW Date From: %ESC%[36m%DATEF%%ESC%[0m - NEW Date To: %ESC%[36m%DATET%%ESC%[0m
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu

:dateset
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     Date From: %ESC%[36m%DATEF%%ESC%[0m - Date To: %ESC%[36m%DATET%%ESC%[0m
echo  ----------------------------------------------------
echo.          %ESC%[90mFormat is: YYYY-MM-DD%ESC%[0m
set /p DATEF="  %ESC%[33mEnter NEW Date From: %ESC%[0m"
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     New Date From: %ESC%[36m%DATEF%%ESC%[0m - Date To: %ESC%[36m%DATET%%ESC%[0m
echo  ----------------------------------------------------
echo.        %ESC%[90mFormat is: YYYY-MM-DD%ESC%[0m
set /p DATET="  %ESC%[33mEnter NEW Date To: %ESC%[0m"
cls
echo.
echo  ------------%ESC%[33mHanker Enterprises Extractor%ESC%[0m------------
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo     Date From: %ESC%[36m%DATEF%%ESC%[0m - NEW Date To: %ESC%[36m%DATET%%ESC%[0m
echo  ----------------------------------------------------
echo.%ESC%[33m
pause
%ESC%[0m
goto mainmenu