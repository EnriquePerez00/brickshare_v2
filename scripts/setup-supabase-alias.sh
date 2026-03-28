#!/bin/bash
# Script de configuración automática del alias supabase
# Este script añade el alias al archivo de configuración de tu shell

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔧 Configuración de Alias Supabase                     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detectar el shell del usuario
SHELL_NAME=$(basename "$SHELL")
SHELL_RC=""

case "$SHELL_NAME" in
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    bash)
        SHELL_RC="$HOME/.bashrc"
        ;;
    *)
        echo -e "${RED}❌ Shell no soportado: $SHELL_NAME${NC}"
        echo -e "${YELLOW}   Por favor, añade manualmente el alias a tu archivo de configuración${NC}"
        exit 1
        ;;
esac

echo -e "${CYAN}📝 Shell detectado: ${SHELL_NAME}${NC}"
echo -e "${CYAN}📁 Archivo de configuración: ${SHELL_RC}${NC}"
echo ""

# Verificar si el archivo existe
if [[ ! -f "$SHELL_RC" ]]; then
    echo -e "${YELLOW}⚠️  El archivo $SHELL_RC no existe. Creándolo...${NC}"
    touch "$SHELL_RC"
fi

# Verificar si el alias ya existe
if grep -q "alias supabase=" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  El alias 'supabase' ya existe en $SHELL_RC${NC}"
    echo ""
    echo -e "${CYAN}Contenido actual:${NC}"
    grep "alias supabase=" "$SHELL_RC"
    echo ""
    read -p "¿Deseas reemplazarlo? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}❌ Operación cancelada${NC}"
        exit 0
    fi
    
    # Eliminar el alias existente
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' '/alias supabase=/d' "$SHELL_RC"
    else
        # Linux
        sed -i '/alias supabase=/d' "$SHELL_RC"
    fi
    echo -e "${GREEN}✓ Alias anterior eliminado${NC}"
fi

# Obtener la ruta absoluta del directorio del proyecto
PROJECT_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Añadir el alias al archivo de configuración
echo "" >> "$SHELL_RC"
echo "# ════════════════════════════════════════════════════════" >> "$SHELL_RC"
echo "# Brickshare - Supabase wrapper para backup automático" >> "$SHELL_RC"
echo "# Intercepta 'supabase db reset' para hacer backup antes del reset" >> "$SHELL_RC"
echo "# ════════════════════════════════════════════════════════" >> "$SHELL_RC"
echo "alias supabase='${PROJECT_DIR}/scripts/supabase-wrapper.sh'" >> "$SHELL_RC"
echo "" >> "$SHELL_RC"

echo -e "${GREEN}✅ Alias añadido correctamente a $SHELL_RC${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ✨ Configuración Completada                            ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE: Recarga tu configuración de shell:${NC}"
echo -e "   ${GREEN}source $SHELL_RC${NC}"
echo ""
echo -e "${CYAN}💡 Uso:${NC}"
echo -e "   Ahora cuando ejecutes: ${YELLOW}supabase db reset${NC}"
echo -e "   Se interceptará automáticamente y se hará un backup antes del reset"
echo ""
echo -e "${CYAN}🧪 Prueba:${NC}"
echo -e "   ${GREEN}source $SHELL_RC${NC}  # Recarga la configuración"
echo -e "   ${GREEN}which supabase${NC}     # Debería mostrar la ruta al wrapper"
echo ""