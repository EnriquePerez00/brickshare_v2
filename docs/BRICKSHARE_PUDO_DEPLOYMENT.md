# Brickshare PUDO QR System - Deployment Checklist

## ✅ Pre-Deployment Checklist

### 1. Database Setup
- [ ] Aplicar migración: `supabase db reset`
- [ ] Verificar que se crearon las tablas:
  - [ ] `brickshare_pudo_locations`
  - [ ] `qr_validation_logs`
- [ ] Verificar que se añadieron campos a `shipments`
- [ ] Verificar que se crearon las funciones SQL:
  - [ ] `generate_qr_code()`
  - [ ] `generate_delivery_qr()`
  - [ ] `generate_return_qr()`
  - [ ] `validate_qr_code()`
  - [ ] `confirm_qr_validation()`
- [ ] Verificar políticas RLS activas

### 2. Edge Functions
- [ ] Desplegar `brickshare-qr-api`:
  ```bash
  supabase functions deploy brickshare-qr-api
  ```
- [ ] Desplegar `send-brickshare-qr-email`:
  ```bash
  supabase functions deploy send-brickshare-qr-email
  ```
- [ ] Verificar que las funciones están activas en Supabase Dashboard

### 3. Variables de Entorno
- [ ] Configurar `RESEND_API_KEY` en Supabase Edge Functions
- [ ] Configurar `EXPO_PUBLIC_SUPABASE_URL` en app móvil
- [ ] Configurar `EXPO_PUBLIC_PUDO_ID` para cada punto PUDO

### 4. Puntos PUDO Iniciales
- [ ] Añadir puntos PUDO a la base de datos:
  ```sql
  INSERT INTO brickshare_pudo_locations (
    id, name, address, city, postal_code, province,
    latitude, longitude, contact_email, is_active
  ) VALUES
    ('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.4200, -3.7038, 'madrid.centro@brickshare.com', true),
    ('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.3926, 2.1640, 'barcelona.eixample@brickshare.com', true);
  ```

### 5. Frontend Web
- [ ] Verificar que `useBrickshareShipments.ts` está disponible
- [ ] Integrar selector de puntos PUDO en flujo de checkout
- [ ] Probar generación de QR en dashboard de usuario

### 6. Aplicación Móvil
- [ ] Compilar app con QRScannerScreen
- [ ] Probar permisos de cámara
- [ ] Verificar escaneo de QR
- [ ] Probar validación en tiempo real

## 🧪 Testing Checklist

### Tests Automatizados
- [ ] Ejecutar script de testing:
  ```bash
  npm run test:brickshare-qr
  ```
- [ ] Verificar que todos los tests pasan

### Tests Manuales

#### Test 1: Flujo Completo de Entrega
1. [ ] Crear envío con punto Brickshare
2. [ ] Generar QR de entrega
3. [ ] Verificar recepción de email
4. [ ] Escanear QR con app móvil
5. [ ] Validar información del set
6. [ ] Confirmar entrega
7. [ ] Verificar cambio de estado a "delivered"

#### Test 2: Flujo Completo de Devolución
1. [ ] Solicitar devolución desde envío entregado
2. [ ] Generar QR de devolución
3. [ ] Verificar recepción de email
4. [ ] Escanear QR con app móvil
5. [ ] Confirmar devolución
6. [ ] Verificar cambio de estado a "returned"

#### Test 3: Casos de Error
- [ ] Intentar usar QR ya validado
- [ ] Intentar usar QR expirado
- [ ] Intentar devolver sin haber entregado
- [ ] Escanear QR inválido

### Tests de API

#### Test con cURL
```bash
# 1. Validar QR
curl https://YOUR-PROJECT.supabase.co/functions/v1/brickshare-qr-api/validate/BS-TEST123

# 2. Confirmar validación
curl -X POST https://YOUR-PROJECT.supabase.co/functions/v1/brickshare-qr-api/confirm \
  -H "Content-Type: application/json" \
  -d '{"qr_code":"BS-TEST123","validated_by":"BS-PUDO-001"}'

# 3. Obtener puntos PUDO
curl https://YOUR-PROJECT.supabase.co/functions/v1/brickshare-qr-api/pudo-locations
```

## 📊 Post-Deployment Verification

### 1. Base de Datos
- [ ] Verificar logs de validación en `qr_validation_logs`
- [ ] Verificar que los QR se generan correctamente
- [ ] Verificar que los estados de shipments se actualizan

### 2. Emails
- [ ] Verificar que se envían emails de entrega
- [ ] Verificar que se envían emails de devolución
- [ ] Verificar formato y contenido de emails
- [ ] Verificar que los QR son legibles en emails

### 3. API
- [ ] Verificar tiempos de respuesta
- [ ] Verificar logs de Edge Functions
- [ ] Verificar manejo de errores

### 4. Aplicación Móvil
- [ ] Verificar funcionamiento en iOS
- [ ] Verificar funcionamiento en Android (si aplica)
- [ ] Verificar permisos de cámara
- [ ] Verificar UX del scanner

## 🔧 Configuración Específica por Punto PUDO

Para cada punto PUDO físico:

### Hardware Necesario
- [ ] Dispositivo móvil (tablet o smartphone)
- [ ] Conexión a internet estable
- [ ] Soporte/atril para el dispositivo

### Software
- [ ] Instalar app Brickshare PUDO
- [ ] Configurar ID del punto en `.env`:
  ```
  EXPO_PUBLIC_PUDO_ID=BS-PUDO-XXX
  ```
- [ ] Probar escaneo de QR
- [ ] Capacitar al personal

### Documentación para Personal
- [ ] Manual de uso del scanner
- [ ] Proceso de entrega
- [ ] Proceso de devolución
- [ ] Manejo de errores comunes
- [ ] Contacto de soporte técnico

## 📈 Monitoring Setup

### Métricas a Monitorear
- [ ] Tasa de éxito de validaciones
- [ ] Tiempo medio de validación
- [ ] Número de QR expirados
- [ ] Errores en API
- [ ] Rendimiento de Edge Functions

### Alertas a Configurar
- [ ] Alerta si tasa de error > 5%
- [ ] Alerta si tiempo de respuesta > 3s
- [ ] Alerta si email falla
- [ ] Alerta si punto PUDO inactivo

### Dashboard Sugerido
```sql
-- Query para dashboard
SELECT 
    DATE(qvl.validated_at) as date,
    COUNT(*) as total_validations,
    COUNT(*) FILTER (WHERE qvl.validation_type = 'delivery') as deliveries,
    COUNT(*) FILTER (WHERE qvl.validation_type = 'return') as returns,
    COUNT(*) FILTER (WHERE qvl.validation_status = 'success') as successful,
    COUNT(*) FILTER (WHERE qvl.validation_status != 'success') as failed
FROM qr_validation_logs qvl
WHERE qvl.validated_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(qvl.validated_at)
ORDER BY date DESC;
```

## 🚨 Rollback Plan

En caso de problemas críticos:

### 1. Rollback de Base de Datos
```sql
-- Desactivar temporalmente puntos Brickshare
UPDATE brickshare_pudo_locations SET is_active = false;

-- Opcional: Revertir migración
-- (Solo si hay problemas graves)
```

### 2. Rollback de Edge Functions
```bash
# Ver versiones anteriores
supabase functions list

# Restaurar versión anterior
supabase functions deploy brickshare-qr-api --version X
```

### 3. Rollback de Frontend
```bash
# Revertir commit
git revert <commit-hash>
git push
```

## ✅ Sign-Off

### Development Team
- [ ] Database migration reviewed and tested
- [ ] Edge Functions deployed and tested
- [ ] Frontend integration completed
- [ ] Mobile app tested
- [ ] Documentation complete

### QA Team
- [ ] All automated tests passing
- [ ] Manual tests completed
- [ ] Performance tests acceptable
- [ ] Security review completed

### Operations Team
- [ ] Monitoring configured
- [ ] Alerts set up
- [ ] Backup procedures verified
- [ ] Rollback plan tested

### Business Team
- [ ] User documentation reviewed
- [ ] Customer support trained
- [ ] Communication plan ready

## 📞 Support Contacts

**Technical Issues**:
- Email: tech@brickshare.com
- Slack: #tech-support

**Business Issues**:
- Email: ops@brickshare.com
- Phone: +34 XXX XXX XXX

**Emergency Escalation**:
- On-call Engineer: [Contact]
- CTO: [Contact]

---

**Deployment Date**: _________________  
**Deployed By**: _________________  
**Version**: 1.0.0  
**Status**: ⏳ Pending / ✅ Complete / ❌ Failed