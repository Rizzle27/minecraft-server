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
echo Se copiaron %COUNT% mod(s). Resolviendo incompatibilidades...
echo.

:: sodium e iris son incompatibles con embeddium
for %%f in ("%MC_MODS%\sodium*.jar") do (
    for %%g in ("%MC_MODS%\embeddium*.jar") do (
        echo Removiendo %%~nxg (incompatible con Sodium^)...
        del "%%g"
    )
)
for %%f in ("%MC_MODS%\iris*.jar") do (
    for %%g in ("%MC_MODS%\embeddium*.jar") do (
        echo Removiendo %%~nxg (incompatible con Iris^)...
        del "%%g"
    )
)

:: embeddium es incompatible con sodium e iris
for %%f in ("%MC_MODS%\embeddium*.jar") do (
    for %%g in ("%MC_MODS%\sodium*.jar") do (
        echo Removiendo %%~nxg (incompatible con Embeddium^)...
        del "%%g"
    )
    for %%g in ("%MC_MODS%\iris*.jar") do (
        echo Removiendo %%~nxg (incompatible con Embeddium^)...
        del "%%g"
    )
)

echo.
echo Listo! Mods instalados en:
echo %MC_MODS%
echo.
pause
