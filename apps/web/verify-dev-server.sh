#!/bin/bash

# Script para verificar que el servidor dev está corriendo en el puerto correcto

echo "🔍 Verificando servidor dev..."
echo ""

# Detectar el puerto
PORT=$(lsof -i -P -n | grep "node.*LISTEN" | grep -oE ":\d+" | head -1 | sed 's/://')

if [ -z "$PORT" ]; then
  echo "❌ No hay servidor dev corriendo"
  echo ""
  echo "Inicia el servidor con: npm run dev"
  exit 1
fi

echo "✅ Servidor dev detectado en puerto: $PORT"
echo ""

# Verificar que responde
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT 2>/dev/null)

if [ "$RESPONSE" = "200" ]; then
  echo "✅ Servidor responde correctamente en http://localhost:$PORT"
  echo ""
  echo "Ahora puedes ejecutar: npm run test:e2e"
  echo ""
  echo "Si quieres usar un puerto específico, establece:"
  echo "PLAYWRIGHT_BASE_URL=http://localhost:$PORT npm run test:e2e"
  exit 0
else
  echo "⚠️  Servidor en puerto $PORT pero responde con código: $RESPONSE"
  echo ""
  echo "Verifica que la app está correctamente inicializada"
  exit 1
fi