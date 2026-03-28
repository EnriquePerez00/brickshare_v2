#!/bin/bash
# Supabase CLI Wrapper - Intercepta 'db reset' para hacer backup automático
# Uso: Crear alias en ~/.zshrc o ~/.bashrc:
#   alias supabase='./scripts/supabase-wrapper.sh'

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verificar si el comando es 'db reset'
if [[ "$1" == "db" && "$2" == "reset" ]]; then
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  🔄 Interceptado: supabase db reset                     ║${NC}"
    echo -e "${CYAN}║  Ejecutando backup automático antes del reset...        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar que estamos en el directorio correcto del proyecto
    if [[ ! -f "./scripts/db-reset.sh" ]]; then
        echo -e "${RED}❌ Error: No se encontró ./scripts/db-reset.sh${NC}"
        echo -e "${YELLOW}   Asegúrate de estar en el directorio raíz del proyecto Brickshare${NC}"
        exit 1
    fi
    
    # Ejecutar el script de reset con backup
    ./scripts/db-reset.sh "${@:3}"
    
else
    # Para cualquier otro comando, pasar directamente a supabase CLI
    command supabase "$@"
fi