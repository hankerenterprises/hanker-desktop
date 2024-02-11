@echo off
title HE - Login
color 07
mode 55,18

SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in ('echo prompt $E ^| cmd') do ( set "ESC=%%a" )

REM Check if Phw.ini file exists
if not exist "F:\PHWin\Phw.ini" (
    set "DBSERVER=ERROR"
    set "CATALOG=ERROR"
) else (
    REM Read DBSERVER and CATALOG from Phw.ini file
    for /f "usebackq delims=" %%a in ("F:\PHWin\Phw.ini") do (
        echo %%a | findstr /i "DBSERVER=" >nul && set %%a
        echo %%a | findstr /i "CATALOG=" >nul && set %%a
    )
)

REM Get today's date in the format YYYY-MM-DD
for /F "tokens=1-3" %%a in ('wmic.exe Path Win32_LocalTime Get Day^,Month^,Year /Format:table ^| findstr /r "^[0-9]"') do (
    set "YYYY=%%c"
    set "MM=%%b"
    set "DD=%%a"
)

REM Add leading zeros if needed
if %MM% LSS 10 set MM=0%MM%
if %DD% LSS 10 set DD=0%DD%

set "MONTH_START=%YYYY%-%MM%-01"
set "TODAY=%YYYY%-%MM%-%DD%"
set DATEF=%MONTH_START%
set DATET=%TODAY%
set pass=8048031010

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
echo        [1] Run Billed Report
echo.       [2] Run Unbilled Report
echo.
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
if %_erl%==5 goto:mainmenu
if %_erl%==4 goto:mainmenu
if %_erl%==3 goto:mainmenu
if %_erl%==2 goto:unbilled
if %_erl%==1 goto:all
goto:mainmenu

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
echo              Exporting Report. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;Select	rx.datef as 'DATE FILLED',rx.rxno as 'RX',rx.nrefill as 'REFILL',rx.ndc AS 'NDC',CONCAT(TRIM(drug.DRGNAME),' ',TRIM(drug.STRONG),' ',TRIM(drug.FORM)) as 'DRUG NAME',drug.QNTPACK as 'PKG SIZE',rx.quant as 'QTY',rx.QUANT/drug.QNTPACK as 'PKG FILLED',insPri.BIN_NO as 'PRI BIN',insPri.MAG_CODE as 'PRI PCN',claim.PriInsPaid as 'PRI PAID',insSec.BIN_NO as 'SEC BIN',insSec.MAG_CODE as 'SEC PCN',claim.secinspaid as 'SEC PAID',[STATUS] AS 'STATUS' from ((((PharmSQL.dbo.RxDetails as rx left join Pharmsql.dbo.ClaimPaymentView as claim on CONCAT_WS('.', claim.rxno , claim.nrefill) = CONCAT_WS('.', rx.rxno , rx.nrefill)) left join Pharmsql.dbo.Drug as drug on drug.drgndc = rx.ndc) left join PharmSQL.dbo.INSCAR as insPri on insPri.IC_CODE = claim.PriIns) left join PharmSQL.dbo.INSCAR as insSec on insSec.IC_CODE = claim.SecIns) WHERE [STATUS] = 'B' AND rx.DATEF >= '%DATEF%' AND RX.DATEF <= '%DATET%';"  -o "%USERPROFILE%\Desktop\HankerReport-%DATEF%-to-%DATET%.csv" -W -s,
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

:unbilled
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
echo              Exporting Unbilled Report. . . .
echo  ----------------------------------------------------
sqlcmd -U sa -P MMSPhW110 -S %DBSERVER% -d %CATALOG% -Q "set nocount on;Select	rx.datef as 'DATE FILLED',rx.rxno as 'RX',rx.nrefill as 'REFILL',rx.ndc AS 'NDC',CONCAT(TRIM(drug.DRGNAME),' ',TRIM(drug.STRONG),' ',TRIM(drug.FORM)) as 'DRUG NAME',drug.QNTPACK as 'PKG SIZE',rx.quant as 'QTY',rx.QUANT/drug.QNTPACK as 'PKG FILLED',insPri.BIN_NO as 'PRI BIN',insPri.MAG_CODE as 'PRI PCN',claim.PriInsPaid as 'PRI PAID',insSec.BIN_NO as 'SEC BIN',insSec.MAG_CODE as 'SEC PCN',claim.secinspaid as 'SEC PAID',[STATUS] AS 'STATUS' from ((((PharmSQL.dbo.RxDetails as rx left join Pharmsql.dbo.ClaimPaymentView as claim on CONCAT_WS('.', claim.rxno , claim.nrefill) = CONCAT_WS('.', rx.rxno , rx.nrefill)) left join Pharmsql.dbo.Drug as drug on drug.drgndc = rx.ndc) left join PharmSQL.dbo.INSCAR as insPri on insPri.IC_CODE = claim.PriIns) left join PharmSQL.dbo.INSCAR as insSec on insSec.IC_CODE = claim.SecIns) WHERE [STATUS] = 'U' AND rx.DATEF >= '%DATEF%' AND RX.DATEF <= '%DATET%';"  -o "%USERPROFILE%\Desktop\HankerUnbilledReport-%DATEF%-to-%DATET%.csv" -W -s,
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