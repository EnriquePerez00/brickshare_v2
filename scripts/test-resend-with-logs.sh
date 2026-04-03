#!/bin/bash

# Script para testear Resend mostrando logs en tiempo real

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     TEST RESEND + LIVE LOGS FROM EDGE FUNCTIONS             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📺 Starting Docker logs stream (press Ctrl+C to stop)..."
echo ""

# Start tailing logs in background
docker logs -f brickshare-edge-runtime-1 2>&1 | grep --line-buffered "send-brickshare-qr-email\|RESEND\|📧\|Error\|✅\|❌" &
DOCKER_LOG_PID=$!

# Give it a second to start
sleep 2

# Run the test
echo ""
echo "🧪 Running test..."
npx ts-node scripts/test-resend-direct.ts

# Kill the log stream
kill $DOCKER_LOG_PID 2>/dev/null || true

echo ""
echo "✅ Test complete"