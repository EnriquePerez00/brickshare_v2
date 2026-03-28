# Verificar Edge Functions Desplegadas

Script para validar que todas las Edge Functions del código estén desplegadas en Supabase.

## Uso

```bash
./scripts/verify-edge-functions.sh
```

## ¿Qué hace?

1. Lista todas las funciones en `supabase/functions/`
2. Lista todas las funciones desplegadas en Supabase
3. Compara ambas listas
4. Reporta funciones faltantes

## Salida

### ✅ Todo OK
```
🔍 Verificando Edge Functions...
================================

📁 Funciones en el código (supabase/functions/):
   • send-brickshare-qr-email
   • correos-logistics
   ...

☁️  Funciones desplegadas en Supabase:
   • send-brickshare-qr-email
   • correos-logistics
   ...

🔎 Análisis de diferencias:
----------------------------
   ✅ Todas las funciones del código están desplegadas

================================
✅ Verificación completada con éxito
```

### ⚠️ Funciones Faltantes
```
🔎 Análisis de diferencias:
----------------------------
   ❌ FALTA: send-brickshare-qr-email (existe en código pero NO está desplegada)

================================
⚠️  Se encontraron 1 función(es) sin desplegar

Para desplegar las funciones faltantes:
  supabase functions deploy <nombre-funcion>

Para desplegar todas las funciones:
  supabase functions deploy send-brickshare-qr-email
```

## Contexto de Uso

Este script es útil para:

- **Desarrollo local**: Verificar que todas las funciones estén disponibles después de `supabase start`
- **CI/CD**: Integrar en pipelines para validar despliegues
- **Debugging**: Diagnosticar errores 404 en llamadas a Edge Functions
- **Onboarding**: Ayudar a nuevos desarrolladores a configurar el entorno

## Prerequisitos

- Supabase CLI instalado
- Proyecto Supabase en ejecución (local o cloud)
- Permisos para listar funciones

## Limitaciones

- Solo funciona con Supabase local o con credenciales cloud configuradas
- No valida el contenido de las funciones, solo su existencia
- No detecta funciones desplegadas que ya no están en el código

## Ver También

- `docs/LABEL_GENERATION_EDGE_FUNCTION_FIX.md` - Caso de uso real
- `supabase functions list` - Comando manual para listar funciones
- `supabase functions deploy <name>` - Comando para desplegar funciones

## Integración en Workflow

### Pre-despliegue
```bash
# Antes de desplegar, verificar que todas las funciones están desplegadas
./scripts/verify-edge-functions.sh || {
    echo "⚠️  Hay funciones sin desplegar"
    exit 1
}
```

### Post-reset de BD
```bash
# Después de reset de BD, verificar funciones
./scripts/db-reset.sh
./scripts/verify-edge-functions.sh
```

## Troubleshooting

### Error: "No se pudieron obtener las funciones desplegadas"

**Causa:** Supabase no está corriendo o no hay credenciales configuradas

**Solución:**
```bash
# Para desarrollo local
supabase start

# Para cloud
supabase link --project-ref <tu-project-ref>
```

### El script reporta funciones como faltantes pero están desplegadas

**Causa:** El nombre de la función en el código no coincide con el slug desplegado

**Solución:** Verificar manualmente con `supabase functions list` y ajustar nombres si es necesario

---

**Creado:** 25/03/2026  
**Autor:** Sistema de desarrollo Brickshare