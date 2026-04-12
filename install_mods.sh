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
echo "Se copiaron $COUNT mod(s). Resolviendo incompatibilidades..."
echo

remove_if_exists() {
    local pattern=$1
    local reason=$2
    for f in "$MC_MODS"/$pattern*.jar; do
        [ -f "$f" ] || continue
        echo "Removiendo $(basename "$f") ($reason)..."
        rm -f "$f"
    done
}

# sodium e iris son incompatibles con embeddium
if ls "$MC_MODS"/sodium*.jar 2>/dev/null | grep -q .; then
    remove_if_exists "embeddium" "incompatible con Sodium"
fi
if ls "$MC_MODS"/iris*.jar 2>/dev/null | grep -q .; then
    remove_if_exists "embeddium" "incompatible con Iris"
fi

# embeddium es incompatible con sodium e iris
if ls "$MC_MODS"/embeddium*.jar 2>/dev/null | grep -q .; then
    remove_if_exists "sodium" "incompatible con Embeddium"
    remove_if_exists "iris" "incompatible con Embeddium"
fi

echo
echo "Listo! Mods instalados en:"
echo "$MC_MODS"
