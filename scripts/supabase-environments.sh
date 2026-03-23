#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# Brickshare - Supabase Multi-Environment Manager
# ═══════════════════════════════════════════════════════════════
# Este script facilita la gestión de 2 entornos Supabase:
# - main (Producción, Puerto 5432, API 54321, Studio 54323)
# - develop (Desarrollo, Puerto 5433, API 54331, Studio 54333)
# ═══════════════════════════════════════════════════════════════

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
print_header() {
  echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Comando: start
cmd_start() {
  local env=$1
  
  if [ -z "$env" ]; then
    print_error "Debes especificar un entorno: main o develop"
    echo "Uso: npm run supabase:start main|develop"
    exit 1
  fi
  
  if [ "$env" = "main" ]; then
    print_header "Iniciando entorno MAIN (Producción)"
    print_info "Puertos: DB=5432, API=54321, Studio=54323"
    cd "$PROJECT_ROOT/supabase-main"
    supabase start
  elif [ "$env" = "develop" ]; then
    print_header "Iniciando entorno DEVELOP (Desarrollo)"
    print_info "Puertos: DB=5433, API=54331, Studio=54333"
    cd "$PROJECT_ROOT/supabase"
    supabase start
  else
    print_error "Entorno desconocido: $env"
    exit 1
  fi
}

# Comando: stop
cmd_stop() {
  local env=$1
  
  if [ -z "$env" ]; then
    print_header "Deteniendo TODOS los entornos"
    print_info "Parando main..."
    cd "$PROJECT_ROOT/supabase-main"
    supabase stop || true
    print_info "Parando develop..."
    cd "$PROJECT_ROOT/supabase"
    supabase stop || true
    print_success "Todos los entornos detenidos"
  elif [ "$env" = "main" ]; then
    print_header "Deteniendo entorno MAIN"
    cd "$PROJECT_ROOT/supabase-main"
    supabase stop
  elif [ "$env" = "develop" ]; then
    print_header "Deteniendo entorno DEVELOP"
    cd "$PROJECT_ROOT/supabase"
    supabase stop
  else
    print_error "Entorno desconocido: $env"
    exit 1
  fi
}

# Comando: status
cmd_status() {
  print_header "Estado de entornos Supabase"
  
  echo -e "${YELLOW}MAIN Environment:${NC}"
  echo "  Directorio: supabase-main/"
  echo "  PostgreSQL: localhost:5432"
  echo "  API:        http://127.0.0.1:54321"
  echo "  Studio:     http://127.0.0.1:54323"
  echo "  Vector:     localhost:54322"
  
  echo -e "\n${YELLOW}DEVELOP Environment:${NC}"
  echo "  Directorio: supabase/"
  echo "  PostgreSQL: localhost:5433"
  echo "  API:        http://127.0.0.1:54331"
  echo "  Studio:     http://127.0.0.1:54333"
  echo "  Vector:     localhost:54332"
  
  echo -e "\n${YELLOW}Variables de Entorno:${NC}"
  echo "  .env.main       → Main environment"
  echo "  .env.develop    → Develop environment (default)"
  echo "  .env.local      → Frontend (usa develop por defecto)"
}

# Comando: dump
cmd_dump() {
  local env=$1
  
  if [ -z "$env" ]; then
    print_error "Debes especificar un entorno: main o develop"
    exit 1
  fi
  
  if [ "$env" = "main" ]; then
    print_header "Exportando dump de la BD MAIN"
    print_info "Conectando a: localhost:5432"
    psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -c "COPY (SELECT * FROM information_schema.tables WHERE table_schema = 'public') TO STDOUT;" > /dev/null 2>&1 || {
      print_error "No se puede conectar a la BD main"
      exit 1
    }
    supabase db pull --dir supabase-main -f dump_main_$(date +%Y%m%d_%H%M%S).sql
  elif [ "$env" = "develop" ]; then
    print_header "Exportando dump de la BD DEVELOP"
    print_info "Conectando a: localhost:5433"
    psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "COPY (SELECT * FROM information_schema.tables WHERE table_schema = 'public') TO STDOUT;" > /dev/null 2>&1 || {
      print_error "No se puede conectar a la BD develop"
      exit 1
    }
    supabase db pull --dir supabase -f dump_develop_$(date +%Y%m%d_%H%M%S).sql
  else
    print_error "Entorno desconocido: $env"
    exit 1
  fi
}

# Comando: reset
cmd_reset() {
  local env=$1
  
  if [ -z "$env" ]; then
    print_error "Debes especificar un entorno: main o develop"
    exit 1
  fi
  
  if [ "$env" = "main" ]; then
    print_header "Reseteando BD MAIN"
    cd "$PROJECT_ROOT/supabase-main"
    supabase db reset
  elif [ "$env" = "develop" ]; then
    print_header "Reseteando BD DEVELOP"
    cd "$PROJECT_ROOT/supabase"
    supabase db reset
  else
    print_error "Entorno desconocido: $env"
    exit 1
  fi
}

# Comando: help
cmd_help() {
  cat << EOF
${BLUE}Brickshare - Supabase Multi-Environment Manager${NC}

${YELLOW}COMANDOS:${NC}
  start <env>     Inicia un entorno (main|develop)
  stop [env]      Detiene un entorno o todos si no se especifica
  status          Muestra el estado de ambos entornos
  reset <env>     Resetea la BD de un entorno (main|develop)
  dump <env>      Exporta dump de la BD (main|develop)
  help            Muestra esta ayuda

${YELLOW}EJEMPLOS:${NC}
  npm run supabase:start develop
  npm run supabase:stop
  npm run supabase:status
  npm run supabase:reset main
  npm run supabase:dump develop

${YELLOW}PUERTOS:${NC}
  MAIN:
    DB: 5432, API: 54321, Studio: 54323, Vector: 54322
  
  DEVELOP:
    DB: 5433, API: 54331, Studio: 54333, Vector: 54332

${YELLOW}VARIABLES DE ENTORNO:${NC}
  .env.main       → Configuración para main
  .env.develop    → Configuración para develop
  .env.local      → Frontend usa develop por defecto

EOF
}

# Main
case "${1:-help}" in
  start)
    cmd_start "$2"
    ;;
  stop)
    cmd_stop "$2"
    ;;
  status)
    cmd_status
    ;;
  reset)
    cmd_reset "$2"
    ;;
  dump)
    cmd_dump "$2"
    ;;
  help|--help|-h)
    cmd_help
    ;;
  *)
    print_error "Comando desconocido: $1"
    cmd_help
    exit 1
    ;;
esac