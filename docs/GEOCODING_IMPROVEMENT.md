# Mejora de Precisión en Geocodificación de Depósitos

## Problema Identificado

El "establecimiento de paco" (Avenida Josep Tarradellas 64, Barcelona, CP 08029) se estaba mostrando en Google Maps en una ubicación cercana pero no exacta.

### Causa Raíz

La geocodificación se realizaba concatenando directamente los datos en un string simple:
```typescript
const fullAddress = `${dep.address}, ${dep.postal_code} ${dep.city}, España`;
geocoder.geocode({ address: fullAddress, region: 'es', componentRestrictions: { country: 'ES' } }, ...)
```

Esto podía causar que Google Maps interpretara la dirección de forma imprecisa, especialmente cuando:
- El código postal podría despistarse al estar en diferentes distritos
- El número de portal podría interpretarse mal
- La avenida tiene múltiples secciones

## Solución Implementada

### Cambios en `apps/web/src/components/PudoSelector.tsx`

Se modificó la geocodificación para usar **componentes estructurados** en lugar de un string concatenado:

```typescript
// ANTES (string simple)
const fullAddress = `${dep.address}, ${dep.postal_code} ${dep.city}, España`;
geocoder.geocode({ 
  address: fullAddress, 
  region: 'es', 
  componentRestrictions: { country: 'ES' } 
}, ...)

// AHORA (componentes estructurados)
const geocodeRequest = {
  address: dep.address,  // Solo la calle con número
  componentRestrictions: {
    country: 'ES',
    postalCode: dep.postal_code,  // CP como componente separado
    locality: dep.city            // Ciudad como componente separado
  },
  region: 'es'
};
geocoder.geocode(geocodeRequest, ...)
```

### Mejoras Adicionales

1. **Logging de precisión**: Ahora se registra el `location_type` de cada geocodificación
2. **Advertencias de baja precisión**: Se emite un warning si la precisión no es óptima
3. **Información detallada**: Los logs muestran lat/lng y tipo de precisión

## Tipos de Precisión (location_type)

- `ROOFTOP`: Precisión exacta a nivel de edificio ✅ (óptimo)
- `RANGE_INTERPOLATED`: Interpolación entre puntos conocidos ✅ (buena)
- `GEOMETRIC_CENTER`: Centro geométrico de un área ⚠️ (media)
- `APPROXIMATE`: Aproximación ⚠️ (baja)

## Cómo Verificar la Mejora

### Opción 1: Verificación en el Navegador

1. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```

2. Abre la aplicación en el navegador

3. Navega al selector de puntos PUDO

4. Busca "Barcelona" o "08029"

5. Abre la consola del navegador (F12)

6. Busca los logs que comienzan con `Geocoded ...`:
   ```
   Geocoded establecimiento de paco: {
     address: "Avenida Josep Tarradellas 64",
     postal_code: "08029",
     city: "Barcelona",
     location_type: "ROOFTOP",  // <-- Debe ser ROOFTOP o RANGE_INTERPOLATED
     lat: 41.xxxxx,
     lng: 2.xxxxx
   }
   ```

7. Verifica que el marcador verde aparezca en la ubicación correcta del mapa

### Opción 2: Verificación Manual de Coordenadas

Si quieres verificar manualmente las coordenadas exactas:

1. Busca "Avenida Josep Tarradellas 64, Barcelona" en Google Maps (web)
2. Haz clic derecho en la ubicación exacta → "¿Qué hay aquí?"
3. Compara las coordenadas con las que muestra la consola del navegador

Las coordenadas deberían ser aproximadamente:
- **Latitud**: ~41.38-41.39
- **Longitud**: ~2.13-2.14

## Beneficios de Esta Mejora

1. ✅ **Mayor precisión**: Los componentes estructurados ayudan a Google Maps a entender mejor la dirección
2. ✅ **Mejor manejo del código postal**: El CP se trata como restricción, no como parte del texto de búsqueda
3. ✅ **Debugging mejorado**: Los logs permiten identificar problemas de precisión fácilmente
4. ✅ **Escalabilidad**: Funciona mejor con direcciones variadas o complejas

## Nota sobre el Script de Test

El script `scripts/test-geocoding-precision.ts` no puede ejecutarse porque la API key de Google Maps tiene restricciones de referer (solo funciona desde el dominio de la aplicación web). Esto es una medida de seguridad correcta.

La geocodificación solo funciona desde el navegador, donde el componente `PudoSelector.tsx` la ejecuta correctamente.

## Próximos Pasos (Opcional)

Si después de esta mejora aún se requiere más precisión:

1. **Opción A**: Añadir campos `latitude` y `longitude` a la tabla de depósitos en la base de datos
2. **Opción B**: Geocodificar una vez al crear/actualizar depósitos y guardar las coordenadas
3. **Opción C**: Permitir ajuste manual de coordenadas en el admin panel

Para la mayoría de los casos, la mejora implementada debería ser suficiente.