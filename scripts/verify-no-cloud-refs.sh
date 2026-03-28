#!/bin/bash

# ============================================================
# verify-no-cloud-refs.sh
#
# Script para verificar que NO existen referencias a Supabase Cloud
# en el proyecto. Solo debe usarse Supabase LOCAL (Docker).
#
# Uso: ./scripts/verify-no-cloud-refs.sh
# ============================================================

set -e

echo "🔍 Verificando referencias a Supabase Cloud..."
echo ""

ERRORS=0

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directorios a excluir de la búsqueda
EXCLUDE_DIRS=(
  "node_modules"
  ".git"
  "dist"
  "build"
  ".next"
  "coverage"
  "playwright-report"
  "test-results"
)

# Archivos permitidos que pueden tener referencias cloud (documentación histórica)
ALLOWED_FILES=(
  "docs/SUPABASE_CLOUD_CLEANUP.md"
  "scripts/verify-no-cloud-refs.sh"
  "scripts/README_SYNC_USERS.md"
  "claude.md"
)

# Función para verificar si un archivo está en la lista de permitidos
is_allowed_file() {
  local file="$1"
  for allowed in "${ALLOWED_FILES[@]}"; do
    if [[ "$file" == *"$allowed"* ]]; then
      return 0
    fi
  done
  return 1
}

# Construir patrón de exclusión para grep
EXCLUDE_PATTERN=""
for dir in "${EXCLUDE_DIRS[@]}"; do
  EXCLUDE_PATTERN="$EXCLUDE_PATTERN --exclude-dir=$dir"
done

echo "📋 Buscando patrones de Supabase Cloud..."
echo ""

# 1. Buscar URLs .supabase.co o .supabase.com en archivos de código
echo "1️⃣  Verificando archivos de código (.ts, .tsx, .js, .jsx)..."
CODE_FILES=$(grep -r "\.supabase\.co\|\.supabase\.com" \
  --include="*.ts" \
  --include="*.tsx" \
  --include="*.js" \
  --include="*.jsx" \
  $EXCLUDE_PATTERN \
  . 2>/dev/null | grep -v "test" || true)

if [ -n "$CODE_FILES" ]; then
  echo -e "${RED}❌ ENCONTRADAS referencias en código:${NC}"
  echo "$CODE_FILES"
  echo ""
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ Sin referencias en archivos de código${NC}"
fi
echo ""

# 2. Buscar en archivos .env (excluyendo .example)
echo "2️⃣  Verificando archivos de configuración (.env*)..."
ENV_FILES=$(grep -r "\.supabase\.co\|\.supabase\.com" \
  --include=".env" \
  --include=".env.local" \
  --include=".env.main" \
  --include=".env.develop" \
  $EXCLUDE_PATTERN \
  . 2>/dev/null || true)

if [ -n "$ENV_FILES" ]; then
  # Verificar si son líneas comentadas o marcadas como OBSOLETAS
  UNCOMMENTED=$(echo "$ENV_FILES" | grep -v "^#" | grep -v "OBSOLET" || true)
  if [ -n "$UNCOMMENTED" ]; then
    echo -e "${RED}❌ ENCONTRADAS referencias ACTIVAS en .env:${NC}"
    echo "$UNCOMMENTED"
    echo ""
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${YELLOW}⚠️  Referencias encontradas pero están comentadas/marcadas OBSOLETAS${NC}"
  fi
else
  echo -e "${GREEN}✅ Sin referencias en archivos .env${NC}"
fi
echo ""

# 3. Buscar en Edge Functions
echo "3️⃣  Verificando Edge Functions..."
EDGE_FUNCTIONS=$(grep -r "\.supabase\.co\|\.supabase\.com" \
  supabase/functions/ \
  supabase-main/functions/ \
  2>/dev/null | grep -v "// " | grep -v "test" || true)

if [ -n "$EDGE_FUNCTIONS" ]; then
  echo -e "${RED}❌ ENCONTRADAS referencias en Edge Functions:${NC}"
  echo "$EDGE_FUNCTIONS"
  echo ""
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ Sin referencias en Edge Functions${NC}"
fi
echo ""

# 4. Buscar variables SUPABASE_URL con https en configs
echo "4️⃣  Verificando variables SUPABASE_URL con https..."
HTTPS_URLS=$(grep -r "SUPABASE_URL.*https" \
  --include="*.toml" \
  --include="*.json" \
  --include="*.env*" \
  $EXCLUDE_PATTERN \
  . 2>/dev/null | grep -v "example" | grep -v "test" || true)

if [ -n "$HTTPS_URLS" ]; then
  echo -e "${RED}❌ ENCONTRADAS URLs HTTPS (deben ser http://127.0.0.1):${NC}"
  echo "$HTTPS_URLS"
  echo ""
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ Sin URLs HTTPS en configuración${NC}"
fi
echo ""

# 5. Verificar que .env.local existe y usa localhost
echo "5️⃣  Verificando .env.local..."
if [ -f ".env.local" ]; then
  if grep -q "127.0.0.1" .env.local && ! grep -q "\.supabase\.co" .env.local; then
    echo -e "${GREEN}✅ .env.local configurado correctamente (localhost)${NC}"
  else
    echo -e "${RED}❌ .env.local no usa localhost correctamente${NC}"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo -e "${YELLOW}⚠️  .env.local no existe (copiar de .env.example)${NC}"
fi
echo ""

# 6. Buscar en documentación (excluyendo archivos permitidos)
echo "6️⃣  Verificando documentación (excluyendo archivos históricos)..."
DOC_FILES=$(grep -r "\.supabase\.co\|\.supabase\.com" \
  --include="*.md" \
  $EXCLUDE_PATTERN \
  docs/ 2>/dev/null || true)

if [ -n "$DOC_FILES" ]; then
  # Filtrar archivos permitidos
  FILTERED_DOCS=""
  while IFS= read -r line; do
    FILE=$(echo "$line" | cut -d: -f1)
    if ! is_allowed_file "$FILE"; then
      FILTERED_DOCS="$FILTERED_DOCS$line\n"
    fi
  done <<< "$DOC_FILES"
  
  if [ -n "$FILTERED_DOCS" ]; then
    echo -e "${YELLOW}⚠️  Referencias encontradas en documentación:${NC}"
    echo -e "$FILTERED_DOCS"
    echo ""
    echo "Considera actualizar estos archivos a localhost o marcarlos como históricos."
  else
    echo -e "${GREEN}✅ Referencias solo en archivos históricos permitidos${NC}"
  fi
else
  echo -e "${GREEN}✅ Sin referencias en documentación${NC}"
fi
echo ""

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ VERIFICACIÓN EXITOSA${NC}"
  echo "No se encontraron referencias problemáticas a Supabase Cloud."
  echo ""
  echo "El proyecto está correctamente configurado para usar:"
  echo "  • Supabase LOCAL (Docker)"
  echo "  • URLs: http://127.0.0.1:54321 o http://127.0.0.1:54331"
  exit 0
else
  echo -e "${RED}❌ VERIFICACIÓN FALLIDA${NC}"
  echo "Se encontraron $ERRORS problema(s) con referencias a Supabase Cloud."
  echo ""
  echo "Acciones recomendadas:"
  echo "  1. Revisar los archivos listados arriba"
  echo "  2. Reemplazar URLs cloud por localhost"
  echo "  3. Ejecutar este script nuevamente"
  echo ""
  echo "Ver docs/SUPABASE_CLOUD_CLEANUP.md para más detalles."
  exit 1
fi