@echo off
setlocal

echo Copying required Visual C++ DLLs from plugins folder...

REM List of DLLs to copy
set DLLS=VCRUNTIME140.dll MSVCP140.dll VCRUNTIME140_1.dll

REM Target system folder
set SYSTEM32=%SystemRoot%\System32

REM Check if running as admin
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo This script must be run as Administrator!
    pause
    exit /b
)

REM Loop through each DLL in plugins folder
for %%D in (%DLLS%) do (
    if exist "%~dp0plugins\%%D" (
        echo Copying %%D to %SYSTEM32%...
        copy /Y "%~dp0plugins\%%D" "%SYSTEM32%\" 
    ) else (
        echo WARNING: %%D not found in "%~dp0plugins"
    )
)

echo Done copying DLLs.
echo.

REM -------------------------------
REM Ask user for the serial number on the next line
REM -------------------------------
echo Please enter your serial number:
set /p SERIAL=


REM Delete Serialnumber.bin if it exists
REM -------------------------------
if exist "%~dp0Serialnumber.bin" (
    echo Updating existing Serialnumber.bin...
    attrib -h -r "%~dp0Serialnumber.bin" 2>nul
    del /f /q "%~dp0Serialnumber.bin"
)

REM -------------------------------
REM Create a new .bin file containing the serial number
REM -------------------------------
echo %SERIAL% > "%~dp0Serialnumber.bin"

REM Make the file hidden
attrib +h "%~dp0Serialnumber.bin"

echo.
echo Serial number saved successfully!
pause

endlocal