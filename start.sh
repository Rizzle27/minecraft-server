#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ── Verificar que el setup fue hecho ──────────────────────────────────────────
if [ ! -f "server.jar" ]; then
    echo -e "${RED}No se encontró server.jar. Ejecutá ./setup.sh primero.${NC}"
    exit 1
fi

if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt 2>/dev/null; then
    echo -e "${RED}EULA no aceptada. Ejecutá ./setup.sh primero.${NC}"
    exit 1
fi

# ── Verificar si ya está corriendo ───────────────────────────────────────────
if screen -list 2>/dev/null | grep -q "\.minecraft"; then
    echo -e "${YELLOW}El servidor ya está corriendo.${NC}"
    echo "Para ver la consola: screen -r minecraft"
    echo "Para detenerlo: ./stop.sh"
    exit 0
fi

# ── RAM disponible (usa hasta 4G o lo que haya menos 1G para el sistema) ──────
TOTAL_RAM_MB=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024)}')
MAX_HEAP=$((TOTAL_RAM_MB - 1024))
if [ "$MAX_HEAP" -gt 4096 ]; then MAX_HEAP=4096; fi
if [ "$MAX_HEAP" -lt 1024 ]; then MAX_HEAP=1024; fi
MIN_HEAP=$((MAX_HEAP / 2))

echo -e "${GREEN}=== Arrancando servidor de Minecraft ===${NC}"
echo "RAM asignada: ${MIN_HEAP}M mínimo / ${MAX_HEAP}M máximo"
echo ""

# ── Iniciar el servidor en una sesión de screen ──────────────────────────────
printf -- "-Xmx%sM\n-Xms%sM\n" "$MAX_HEAP" "$MIN_HEAP" > user_jvm_args.txt
screen -dmS minecraft bash -c "bash run.sh nogui 2>&1 | tee -a logs/server.log"

echo -e "${GREEN}Servidor iniciado ✓${NC}"
echo ""
echo "  Ver consola en vivo:   screen -r minecraft"
echo "  Salir de la consola:   Ctrl+A  luego  D  (el server sigue corriendo)"
echo "  Enviar comando:        screen -S minecraft -p 0 -X stuff 'comando\\r'"
echo ""

# ── Mostrar IP pública para compartir con amigos ──────────────────────────────
PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)

echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Servidor listo. Compartí con tus amigos:${NC}"
echo ""
if [ -n "$PUBLIC_IP" ]; then
    echo -e "  IP: ${GREEN}${PUBLIC_IP}:25565${NC}"
else
    echo -e "  ${YELLOW}No se pudo obtener la IP pública. Buscala en: https://api.ipify.org${NC}"
fi
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""
echo "Para detener: ./stop.sh"
