#!/bin/bash

MODS_SRC="$(dirname "$0")/mods"

# Detectar carpeta de Minecraft según el OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    MC_MODS="$HOME/Library/Application Support/minecraft/mods"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    MC_MODS="$HOME/.minecraft/mods"
else
    echo "ERROR: Sistema operativo no soportado. Usa install_mods.bat en Windows."
    exit 1
fi

echo "== Instalador de mods =="
echo

if [ ! -d "$MODS_SRC" ]; then
    echo "ERROR: No se encontró la carpeta mods en el repo."
    exit 1
fi

mkdir -p "$MC_MODS"

COUNT=0
for f in "$MODS_SRC"/*.jar; do
    [ -f "$f" ] || continue
    echo "Copiando $(basename "$f")..."
    cp -f "$f" "$MC_MODS/"
    COUNT=$((COUNT + 1))
done

echo
echo "Listo! Se instalaron $COUNT mod(s) en:"
echo "$MC_MODS"
