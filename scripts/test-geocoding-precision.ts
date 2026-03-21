/**
 * test-geocoding-precision.ts
 *
 * Script para probar la precisión de la geocodificación de Google Maps
 * con diferentes métodos para la dirección "Avenida Josep Tarradellas 64, 08029 Barcelona"
 *
 * Uso:
 *   npx tsx scripts/test-geocoding-precision.ts
 *
 * Requiere VITE_GOOGLE_MAPS_API_KEY en .env
 */

import * as dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables
dotenv.config({ path: join(__dirname, '..', '.env') });
dotenv.config({ path: join(__dirname, '..', '.env.local') });

const GOOGLE_MAPS_API_KEY = process.env.VITE_GOOGLE_MAPS_API_KEY;

if (!GOOGLE_MAPS_API_KEY) {
  console.error('❌ VITE_GOOGLE_MAPS_API_KEY no está configurada en .env o .env.local');
  process.exit(1);
}

interface GeocodeResult {
  method: string;
  lat: number;
  lng: number;
  location_type: string;
  formatted_address: string;
}

async function geocodeWithString(address: string): Promise<GeocodeResult | null> {
  const params = new URLSearchParams({
    address: address,
    region: 'es',
    components: 'country:ES',
    key: GOOGLE_MAPS_API_KEY!
  });

  const url = `https://maps.googleapis.com/maps/api/geocode/json?${params}`;
  console.log(`   URL: ${url.substring(0, 120)}...`);
  
  const response = await fetch(url);
  const data = await response.json();

  console.log(`   Status API: ${data.status}`);
  if (data.error_message) {
    console.log(`   Error: ${data.error_message}`);
  }

  if (data.status === 'OK' && data.results?.[0]) {
    const result = data.results[0];
    return {
      method: 'String simple',
      lat: result.geometry.location.lat,
      lng: result.geometry.location.lng,
      location_type: result.geometry.location_type,
      formatted_address: result.formatted_address
    };
  }

  return null;
}

async function geocodeWithComponents(address: string, postalCode: string, city: string): Promise<GeocodeResult | null> {
  const params = new URLSearchParams({
    address: address,
    region: 'es',
    components: `country:ES|postal_code:${postalCode}|locality:${city}`,
    key: GOOGLE_MAPS_API_KEY!
  });

  const url = `https://maps.googleapis.com/maps/api/geocode/json?${params}`;
  console.log(`   URL: ${url.substring(0, 120)}...`);
  
  const response = await fetch(url);
  const data = await response.json();

  console.log(`   Status API: ${data.status}`);
  if (data.error_message) {
    console.log(`   Error: ${data.error_message}`);
  }

  if (data.status === 'OK' && data.results?.[0]) {
    const result = data.results[0];
    return {
      method: 'Componentes estructurados',
      lat: result.geometry.location.lat,
      lng: result.geometry.location.lng,
      location_type: result.geometry.location_type,
      formatted_address: result.formatted_address
    };
  }

  return null;
}

function calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371e3; // Radio de la Tierra en metros
  const φ1 = lat1 * Math.PI / 180;
  const φ2 = lat2 * Math.PI / 180;
  const Δφ = (lat2 - lat1) * Math.PI / 180;
  const Δλ = (lng2 - lng1) * Math.PI / 180;

  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) *
    Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c; // Distancia en metros
}

async function main() {
  console.log('='.repeat(80));
  console.log('  TEST DE PRECISIÓN DE GEOCODIFICACIÓN');
  console.log('  Establecimiento de Paco - Avenida Josep Tarradellas 64, Barcelona');
  console.log('='.repeat(80));
  console.log();

  const testAddress = {
    street: 'Avenida Josep Tarradellas 64',
    postalCode: '08029',
    city: 'Barcelona'
  };

  console.log('📍 Datos de entrada:');
  console.log(`   Dirección: ${testAddress.street}`);
  console.log(`   CP: ${testAddress.postalCode}`);
  console.log(`   Ciudad: ${testAddress.city}`);
  console.log();

  // Método 1: String simple (antiguo)
  console.log('🔍 Método 1: String simple concatenado');
  console.log('─'.repeat(80));
  const fullAddress = `${testAddress.street}, ${testAddress.postalCode} ${testAddress.city}, España`;
  console.log(`   Request: "${fullAddress}"`);
  const result1 = await geocodeWithString(fullAddress);
  
  if (result1) {
    console.log(`   ✅ Resultado:`);
    console.log(`      Latitud: ${result1.lat}`);
    console.log(`      Longitud: ${result1.lng}`);
    console.log(`      Tipo de ubicación: ${result1.location_type}`);
    console.log(`      Dirección formateada: ${result1.formatted_address}`);
  } else {
    console.log(`   ❌ Geocodificación fallida`);
  }
  console.log();

  // Método 2: Componentes estructurados (nuevo)
  console.log('🔍 Método 2: Componentes estructurados');
  console.log('─'.repeat(80));
  console.log(`   Request: address="${testAddress.street}"`);
  console.log(`            components="country:ES|postal_code:${testAddress.postalCode}|locality:${testAddress.city}"`);
  const result2 = await geocodeWithComponents(testAddress.street, testAddress.postalCode, testAddress.city);
  
  if (result2) {
    console.log(`   ✅ Resultado:`);
    console.log(`      Latitud: ${result2.lat}`);
    console.log(`      Longitud: ${result2.lng}`);
    console.log(`      Tipo de ubicación: ${result2.location_type}`);
    console.log(`      Dirección formateada: ${result2.formatted_address}`);
  } else {
    console.log(`   ❌ Geocodificación fallida`);
  }
  console.log();

  // Comparación
  if (result1 && result2) {
    console.log('📊 COMPARACIÓN DE RESULTADOS');
    console.log('='.repeat(80));
    
    const distance = calculateDistance(result1.lat, result1.lng, result2.lat, result2.lng);
    
    console.log(`   Diferencia en coordenadas:`);
    console.log(`      Δ Latitud: ${Math.abs(result2.lat - result1.lat).toFixed(6)}°`);
    console.log(`      Δ Longitud: ${Math.abs(result2.lng - result1.lng).toFixed(6)}°`);
    console.log(`      Distancia: ${distance.toFixed(2)} metros`);
    console.log();

    console.log(`   Precisión de ubicación:`);
    console.log(`      Método 1 (antiguo): ${result1.location_type}`);
    console.log(`      Método 2 (nuevo):   ${result2.location_type}`);
    console.log();

    // Interpretación de location_type
    console.log('   📖 Significado de location_type:');
    console.log('      ROOFTOP: Precisión exacta (nivel de edificio)');
    console.log('      RANGE_INTERPOLATED: Interpolación entre puntos conocidos (buena precisión)');
    console.log('      GEOMETRIC_CENTER: Centro geométrico de un área (precisión media)');
    console.log('      APPROXIMATE: Aproximación (baja precisión)');
    console.log();

    if (distance < 10) {
      console.log(`   ✅ MEJORA MÍNIMA: La diferencia es menor a 10 metros`);
    } else if (distance < 50) {
      console.log(`   ⚠️  MEJORA MODERADA: La diferencia es de ${distance.toFixed(0)} metros`);
    } else {
      console.log(`   ✅ MEJORA SIGNIFICATIVA: La diferencia es de ${distance.toFixed(0)} metros`);
    }

    if (result2.location_type === 'ROOFTOP' || result2.location_type === 'RANGE_INTERPOLATED') {
      console.log(`   ✅ PRECISIÓN ALTA: El método nuevo ofrece precisión a nivel de calle`);
    } else {
      console.log(`   ⚠️  PRECISIÓN MEDIA: Considera añadir coordenadas manuales para mayor exactitud`);
    }
  }

  console.log();
  console.log('='.repeat(80));
  console.log('  Fin del test');
  console.log('='.repeat(80));
}

main().catch(console.error);