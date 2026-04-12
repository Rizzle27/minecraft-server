@echo off
setlocal

set "MODS_SRC=%~dp0mods"
set "MC_MODS=%APPDATA%\.minecraft\mods"

echo == Instalador de mods ==
echo.

if not exist "%MODS_SRC%" (
    echo ERROR: No se encontro la carpeta mods en el repo.
    pause
    exit /b 1
)

if not exist "%MC_MODS%" (
    echo Creando carpeta mods en %MC_MODS%...
    mkdir "%MC_MODS%"
)

set COUNT=0
for %%f in ("%MODS_SRC%\*.jar") do (
    echo Copiando %%~nxf...
    copy /Y "%%f" "%MC_MODS%\" >nul
    set /a COUNT+=1
)

echo.
echo Listo! Se instalaron %COUNT% mod(s) en:
echo %MC_MODS%
echo.
pause
