#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Deteniendo servidor de Minecraft..."

# ── Detener el servidor correctamente (manda el comando 'stop') ───────────────
if screen -list 2>/dev/null | grep -q "\.minecraft"; then
    # Avisa a los jugadores conectados
    screen -S minecraft -p 0 -X stuff "say El servidor se va a cerrar en 5 segundos...$(printf '\r')"
    sleep 5
    screen -S minecraft -p 0 -X stuff "stop$(printf '\r')"
    echo -n "Esperando que el servidor guarde el mundo..."
    for i in $(seq 1 20); do
        sleep 1
        echo -n "."
        if ! screen -list 2>/dev/null | grep -q "\.minecraft"; then
            break
        fi
    done
    echo ""
    # Por si acaso quedó colgado
    screen -S minecraft -X quit 2>/dev/null || true
    echo -e "${GREEN}Servidor detenido ✓${NC}"
else
    echo -e "${YELLOW}El servidor no estaba corriendo.${NC}"
fi

# ── Detener túnel playit ──────────────────────────────────────────────────────
echo "Deteniendo túnel playit.gg..."
if [ -f ".playit.pid" ]; then
    PID=$(cat .playit.pid)
    kill "$PID" 2>/dev/null && echo -e "${GREEN}Túnel detenido ✓${NC}" || echo "El proceso ya había terminado."
    rm -f .playit.pid
else
    pkill -f "./playit" 2>/dev/null && echo -e "${GREEN}Túnel detenido ✓${NC}" || echo -e "${YELLOW}Túnel no estaba corriendo.${NC}"
fi

echo ""
echo "Todo detenido. El mundo quedó guardado."
