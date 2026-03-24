#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Safe DB Reset - Backup antes de reset
# ═══════════════════════════════════════════════════════════════
# Este script crea un backup automático de la BD antes de hacer reset
# Uso: ./scripts/safe-db-reset.sh

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🛡️  Safe Database Reset con Backup Automático${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Verificar que Supabase esté corriendo
if ! supabase status > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Supabase no está corriendo${NC}"
    echo -e "${YELLOW}💡 Ejecuta: supabase start${NC}"
    exit 1
fi

# Crear directorio de backups si no existe
mkdir -p supabase/backups

# Timestamp para backup con fecha
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="supabase/backups/dump_reset_${TIMESTAMP}.sql"
LATEST_FILE="supabase/dump_reset.sql"

echo -e "${YELLOW}📦 Creando backup de la base de datos...${NC}"
echo -e "${BLUE}   Archivo: ${BACKUP_FILE}${NC}"

# Hacer dump de la base de datos
if supabase db dump --local --data-only > "${BACKUP_FILE}" 2>&1; then
    # Copiar también como último dump
    cp "${BACKUP_FILE}" "${LATEST_FILE}"
    
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo -e "${GREEN}✅ Backup completado (${BACKUP_SIZE})${NC}"
    echo ""
    echo -e "${GREEN}   📁 Guardado en:${NC}"
    echo -e "${GREEN}      • ${LATEST_FILE} ${NC}${BLUE}(último backup)${NC}"
    echo -e "${GREEN}      • ${BACKUP_FILE} ${NC}${BLUE}(con timestamp)${NC}"
else
    echo -e "${RED}❌ Error al crear backup${NC}"
    echo -e "${YELLOW}⚠️  ¿Continuar con el reset sin backup? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Operación cancelada${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}🔄 Ejecutando database reset...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Ejecutar reset
if supabase db reset; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Reset completado exitosamente${NC}"
    echo ""
    echo -e "${YELLOW}📝 Información del backup:${NC}"
    echo -e "   • Último backup: ${LATEST_FILE}"
    echo -e "   • Backup con fecha: ${BACKUP_FILE}"
    echo ""
    echo -e "${BLUE}💡 Para restaurar el backup:${NC}"
    echo -e "   ${YELLOW}psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < ${LATEST_FILE}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
else
    echo ""
    echo -e "${RED}❌ Error durante el reset${NC}"
    echo -e "${YELLOW}💡 El backup está disponible en: ${BACKUP_FILE}${NC}"
    exit 1
fi