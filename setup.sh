#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Minecraft Server Setup ===${NC}"
echo ""

# ── 1. Verificar Java ──────────────────────────────────────────────────────────
if ! command -v java &> /dev/null; then
    echo -e "${RED}Java no encontrado.${NC}"
    echo "Instalalo con Homebrew: brew install --cask temurin"
    echo "O descargalo desde: https://adoptium.net"
    exit 1
fi

JAVA_RAW=$(java -version 2>&1)
if ! echo "$JAVA_RAW" | grep -q "version"; then
    echo -e "${RED}Java no está instalado correctamente.${NC}"
    echo "Instalalo con: brew install --cask temurin"
    echo "O descargalo desde: https://adoptium.net"
    exit 1
fi

JAVA_VERSION=$(echo "$JAVA_RAW" | grep -oE '"[0-9]+' | head -1 | tr -d '"')
echo -e "Java ${JAVA_VERSION} detectado ✓"

if [ "$JAVA_VERSION" -lt 17 ]; then
    echo -e "${RED}Minecraft 1.17+ requiere Java 17 o mayor. Tenés Java ${JAVA_VERSION}.${NC}"
    echo "Actualizalo con: brew install --cask temurin"
    exit 1
fi

# ── 2. Crear carpetas ──────────────────────────────────────────────────────────
mkdir -p world backups logs plugins

# ── 3. Descargar Paper (fork de Minecraft con soporte de plugins) ──────────────
# Usamos Paper en vez de vanilla para poder cargar FastLogin + AuthMe,
# que permiten crossplay entre cuentas premium y no-premium.
if [ ! -f "server.jar" ]; then
    echo ""
    echo "Obteniendo última versión de Paper..."

    # API de PaperMC para obtener la última versión y build
    PAPER_VERSIONS=$(curl -s "https://api.papermc.io/v2/projects/paper")
    LATEST=$(echo "$PAPER_VERSIONS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['versions'][-1])")
    echo "Última versión: ${LATEST}"

    LATEST_BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${LATEST}/builds" | python3 -c "
import sys, json
d = json.load(sys.stdin)
builds = d['builds']
stable = [b for b in builds if b.get('channel') == 'default']
chosen = stable if stable else builds
print(chosen[-1]['build'])
")
    echo "Build: ${LATEST_BUILD}"

    JAR_NAME="paper-${LATEST}-${LATEST_BUILD}.jar"
    PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/${LATEST}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

    echo "Descargando Paper server (puede tardar un momento)..."
    curl -# -L "$PAPER_URL" -o server.jar
    echo -e "${GREEN}server.jar (Paper) descargado ✓${NC}"
else
    echo -e "server.jar ya existe, salteando descarga ✓"
fi

# ── 3b. Descargar plugins para crossplay premium/no-premium ───────────────────
# FastLogin: detecta si la cuenta es premium y la autentica automáticamente.
# AuthMe:    pide contraseña a los jugadores no-premium para proteger sus cuentas.

echo ""
echo "Descargando plugins de autenticación (crossplay)..."

if [ ! -f "plugins/FastLogin.jar" ]; then
    echo "  → FastLogin..."
    curl -# -L "https://api.spiget.org/v2/resources/14153/download" -o plugins/FastLogin.jar
    echo -e "  ${GREEN}FastLogin descargado ✓${NC}"
else
    echo -e "  FastLogin ya existe ✓"
fi

if [ ! -f "plugins/AuthMe.jar" ]; then
    echo "  → AuthMe..."
    curl -# -L "https://api.spiget.org/v2/resources/6269/download" -o plugins/AuthMe.jar
    echo -e "  ${GREEN}AuthMe descargado ✓${NC}"
else
    echo -e "  AuthMe ya existe ✓"
fi

# ── 4. Aceptar EULA ────────────────────────────────────────────────────────────
if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt 2>/dev/null; then
    echo ""
    echo -e "${YELLOW}Minecraft requiere aceptar la EULA (acuerdo de usuario final):${NC}"
    echo "https://aka.ms/MinecraftEULA"
    echo ""
    read -p "¿Aceptás los términos? (escribe 'si' para confirmar): " ACCEPT
    if [ "$ACCEPT" != "si" ]; then
        echo "Setup cancelado. Tenés que aceptar la EULA para continuar."
        exit 1
    fi
    echo "eula=true" > eula.txt
    echo -e "${GREEN}EULA aceptada ✓${NC}"
else
    echo -e "EULA ya aceptada ✓"
fi

# ── 5. Descargar playit.gg ────────────────────────────────────────────────────
# playit.gg crea un túnel público gratuito para que tus amigos se conecten
# sin que ellos instalen nada y sin abrir puertos en el router.
if [ ! -f "playit" ]; then
    echo ""
    echo "Descargando playit.gg (túnel para conexiones remotas)..."
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        PLAYIT_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-darwin-arm64"
    else
        PLAYIT_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-darwin-x86_64"
    fi
    curl -# -L "$PLAYIT_URL" -o playit
    chmod +x playit
    # macOS Gatekeeper: quitar cuarentena para poder ejecutarlo
    xattr -d com.apple.quarantine playit 2>/dev/null || true
    echo -e "${GREEN}playit.gg descargado ✓${NC}"
else
    echo -e "playit ya existe ✓"
fi

# ── 6. Copiar server.properties si no existe personalización ──────────────────
if [ ! -f "server.properties" ]; then
    echo ""
    echo -e "${YELLOW}No se encontró server.properties, se generará en el primer arranque.${NC}"
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup completo. Próximos pasos:${NC}"
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""
echo "  1. Ejecutá: ./start.sh"
echo ""
echo "  2. La PRIMERA vez que corra playit.gg te va a dar una URL del tipo:"
echo "     https://playit.gg/claim/XXXXXXXXXX"
echo "     → Abrila, creá una cuenta gratuita y vinculá el agente."
echo ""
echo "  3. En el dashboard de playit.gg agregá un túnel:"
echo "     Tipo: Minecraft Java  |  Puerto local: 25565"
echo ""
echo "  4. playit te va a dar una dirección como: abc123.joinmc.link:PORT"
echo "     → Compartí esa dirección con tus amigos. Listo."
echo ""
echo "  Para volver a arrancar en el futuro solo usá ./start.sh"
echo ""
