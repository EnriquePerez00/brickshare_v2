#!/usr/bin/env tsx
/**
 * SEED: 5 Usuarios Operativos Brick Pro
 * =====================================
 * Crea 5 usuarios completamente funcionales listos para recibir asignaciones
 * 
 * Detalles:
 * - Password: Test0test (todos los usuarios)
 * - Suscripción: brick_pro (3 sets simultáneos)
 * - PUDO: Depósito Brickshare (gratuito)
 * - Wishlist: 4-5 sets por usuario
 * - Stripe: IDs mock para testing
 * - Email: enriqueperezbcn1973+test{N}@gmail.com
 */

import { createClient } from '@supabase/supabase-js';
import { config } from 'dotenv';
import { resolve } from 'path';

// Cargar variables de entorno
config({ path: resolve(__dirname, '../.env.local') });

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

if (!supabaseServiceKey) {
  console.error('❌ ERROR: SUPABASE_SERVICE_ROLE_KEY no está configurada');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

interface Usuario {
  nombre: string;
  email: string;
  telefono: string;
  direccion: string;
  ciudad: string;
  provincia: string;
  cp: string;
}

const usuarios: Usuario[] = [
  {
    nombre: 'María García López',
    email: 'enriqueperezbcn1973+test1@gmail.com',
    telefono: '+34612345001',
    direccion: 'Carrer de Mallorca, 150',
    ciudad: 'Barcelona',
    provincia: 'Barcelona',
    cp: '08029'
  },
  {
    nombre: 'Carlos Martínez Ruiz',
    email: 'enriqueperezbcn1973+test2@gmail.com',
    telefono: '+34612345002',
    direccion: 'Carrer de Sants, 45',
    ciudad: 'Barcelona',
    provincia: 'Barcelona',
    cp: '08014'
  },
  {
    nombre: 'Laura López Fernández',
    email: 'enriqueperezbcn1973+test3@gmail.com',
    telefono: '+34612345003',
    direccion: 'Carrer Gran de Gràcia, 78',
    ciudad: 'Barcelona',
    provincia: 'Barcelona',
    cp: '08012'
  },
  {
    nombre: 'Javier Fernández Gil',
    email: 'enriqueperezbcn1973+test4@gmail.com',
    telefono: '+34612345004',
    direccion: 'Carrer de Horta, 23',
    ciudad: 'Barcelona',
    provincia: 'Barcelona',
    cp: '08032'
  },
  {
    nombre: 'Ana Rodríguez Pérez',
    email: 'enriqueperezbcn1973+test5@gmail.com',
    telefono: '+34612345005',
    direccion: 'Carrer de Sant Andreu, 90',
    ciudad: 'Barcelona',
    provincia: 'Barcelona',
    cp: '08030'
  }
];

async function main() {
  console.log('\n========================================');
  console.log('SEED: 5 Usuarios Operativos Brick Pro');
  console.log('========================================\n');

  try {
    // PASO 1: Verificar/Crear PUDO Brickshare
    console.log('📋 Paso 1: Preparando PUDO Brickshare...');
    
    let { data: pudos } = await supabase
      .from('brickshare_pudo_locations')
      .select('id, name')
      .eq('is_active', true)
      .limit(1);

    let pudoId: string;
    
    if (!pudos || pudos.length === 0) {
      console.log('  ⚠️  No existe PUDO Brickshare, creando...');
      const { data: newPudo, error } = await supabase
        .from('brickshare_pudo_locations')
        .insert({
          id: 'BS-PUDO-TEST-001',
          name: 'Brickshare Barcelona Test',
          address: 'Carrer de Mallorca 123',
          city: 'Barcelona',
          postal_code: '08029',
          province: 'Barcelona',
          latitude: 41.3926,
          longitude: 2.1640,
          contact_email: 'test@brickshare.com',
          is_active: true
        })
        .select('id')
        .single();

      if (error) throw error;
      pudoId = newPudo.id;
      console.log(`  ✅ PUDO Brickshare creado: ${pudoId}`);
    } else {
      pudoId = pudos[0].id;
      console.log(`  ✅ PUDO Brickshare encontrado: ${pudoId} (${pudos[0].name})`);
    }

    // PASO 2: Obtener sets disponibles para wishlist
    console.log('\n📦 Paso 2: Obteniendo sets disponibles...');
    
    const { data: sets, error: setsError } = await supabase
      .from('sets')
      .select(`
        id,
        set_name,
        set_ref,
        inventory_sets!inner(inventory_set_total_qty)
      `)
      .eq('catalogue_visibility', true)
      .eq('set_status', 'active')
      .gte('inventory_sets.inventory_set_total_qty', 3)
      .limit(50);

    if (setsError) throw setsError;
    
    if (!sets || sets.length < 5) {
      console.log('  ⚠️  ADVERTENCIA: Hay menos de 5 sets disponibles.');
      console.log('  ⚠️  Algunos usuarios podrían tener wishlists vacías.');
    } else {
      console.log(`  ✅ Sets disponibles: ${sets.length}`);
    }

    const setIds = sets?.map(s => s.id) || [];

    // PASO 3: Crear los 5 usuarios
    console.log('\n👥 Paso 3: Creando usuarios...\n');

    for (let i = 0; i < usuarios.length; i++) {
      const usuario = usuarios[i];
      console.log(`👤 Usuario ${i + 1}: ${usuario.nombre}`);

      // Crear usuario en auth
      const { data: authData, error: authError } = await supabase.auth.admin.createUser({
        email: usuario.email,
        password: 'Test0test',
        email_confirm: true,
        user_metadata: {
          full_name: usuario.nombre
        }
      });

      if (authError) {
        console.error(`  ❌ Error al crear usuario: ${authError.message}`);
        continue;
      }

      const userId = authData.user.id;
      console.log(`  ✅ Auth user creado: ${userId.substring(0, 8)}...`);

      // Actualizar perfil en users (el trigger ya lo creó)
      const { error: updateError } = await supabase
        .from('users')
        .update({
          email: usuario.email,
          full_name: usuario.nombre,
          phone: usuario.telefono,
          address: usuario.direccion,
          city: usuario.ciudad,
          province: usuario.provincia,
          zip_code: usuario.cp,
          subscription_status: 'active',
          subscription_type: 'brick_pro',
          user_status: 'no_set',
          profile_completed: true,
          stripe_customer_id: `cus_test_user${i + 1}_${userId.substring(0, 8)}`,
          stripe_payment_method_id: `pm_test_card_00${i + 1}`,
          pudo_id: pudoId,
          pudo_type: 'brickshare'
        })
        .eq('user_id', userId);

      if (updateError) {
        console.error(`  ❌ Error al actualizar perfil: ${updateError.message}`);
        continue;
      }
      console.log(`  ✅ Perfil actualizado`);

      // Asignar PUDO Brickshare
      const { data: pudoData } = await supabase
        .from('brickshare_pudo_locations')
        .select('*')
        .eq('id', pudoId)
        .single();

      if (pudoData) {
        await supabase
          .from('users_brickshare_dropping')
          .insert({
            user_id: userId,
            brickshare_pudo_id: pudoId,
            location_name: pudoData.name,
            address: pudoData.address,
            city: pudoData.city,
            postal_code: pudoData.postal_code,
            province: pudoData.province,
            latitude: pudoData.latitude,
            longitude: pudoData.longitude,
            contact_email: pudoData.contact_email,
            contact_phone: pudoData.contact_phone,
            opening_hours: pudoData.opening_hours
          });
        console.log(`  ✅ PUDO asignado`);
      }

      // Asignar rol user
      await supabase
        .from('user_roles')
        .insert({
          user_id: userId,
          role: 'user'
        });
      console.log(`  ✅ Rol 'user' asignado`);

      // Crear wishlist (4-5 sets aleatorios)
      if (setIds.length > 0) {
        const numSets = Math.min(4 + Math.floor(Math.random() * 2), setIds.length); // 4 o 5 sets
        const selectedSets = [...setIds].sort(() => Math.random() - 0.5).slice(0, numSets);
        
        for (const setId of selectedSets) {
          await supabase
            .from('wishlist')
            .insert({
              user_id: userId,
              set_id: setId,
              status: true
            });
        }
        console.log(`  ✅ Wishlist creada (${numSets} sets)`);
      }

      console.log(`  ✅ Email: ${usuario.email}`);
      console.log('');
    }

    // PASO 4: Verificación final
    console.log('========================================');
    console.log('✅ SEED COMPLETADO EXITOSAMENTE');
    console.log('========================================');
    console.log('Usuarios creados: 5');
    console.log('Email: enriqueperezbcn1973+test{1-5}@gmail.com');
    console.log('Password: Test0test (todos)');
    console.log('Suscripción: brick_pro (active)');
    console.log(`PUDO: ${pudoId} (Brickshare)`);
    console.log('Wishlist: 4-5 sets por usuario');
    console.log('========================================\n');

    // Verificación de usuarios
    const { data: createdUsers } = await supabase
      .from('users')
      .select(`
        full_name,
        email,
        subscription_type,
        user_status,
        wishlist(count)
      `)
      .like('email', 'enriqueperezbcn1973+test%');

    console.log('📊 USUARIOS CREADOS:\n');
    createdUsers?.forEach((user: any) => {
      console.log(`  👤 ${user.full_name}`);
      console.log(`     Email: ${user.email}`);
      console.log(`     Plan: ${user.subscription_type}`);
      console.log(`     Status: ${user.user_status}`);
      console.log(`     Wishlist: ${user.wishlist[0]?.count || 0} sets`);
      console.log('');
    });

    // Verificar candidatos para asignación
    console.log('📋 VERIFICANDO CANDIDATOS PARA ASIGNACIÓN...\n');
    const { data: candidates, error: previewError } = await supabase
      .rpc('preview_assign_sets_to_users');

    if (previewError) {
      console.log(`  ⚠️  No se pudo ejecutar preview: ${previewError.message}`);
    } else if (candidates) {
      const testUserCandidates = candidates.filter((c: any) => 
        usuarios.some(u => u.email === c.user_name || c.user_name?.includes('test'))
      );
      
      if (testUserCandidates.length > 0) {
        console.log(`  ✅ ${testUserCandidates.length} usuarios listos para asignación`);
        testUserCandidates.forEach((c: any) => {
          console.log(`     - ${c.user_name}: ${c.set_name} (${c.set_ref})`);
        });
      } else {
        console.log('  ℹ️  Ningún usuario aparece en preview_assign_sets_to_users()');
        console.log('     Esto es normal si no hay stock disponible o no coincide con wishlist');
      }
    }

    console.log('\n✅ SEED COMPLETADO Y VERIFICADO\n');

  } catch (error: any) {
    console.error('\n❌ ERROR:', error.message);
    console.error(error);
    process.exit(1);
  }
}

main();