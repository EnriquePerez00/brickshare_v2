#!/usr/bin/env python3
"""
Script para limpiar seed_full.sql y hacerlo compatible con el esquema actual
"""

import re
import sys
from pathlib import Path

def main():
    # Rutas
    project_root = Path(__file__).parent.parent
    input_file = project_root / "supabase" / "seed_full.sql"
    output_file = project_root / "supabase" / "seed_clean.sql"
    
    print("🔄 Limpiando seed_full.sql...")
    print(f"📂 Entrada: {input_file}")
    print(f"📂 Salida: {output_file}")
    
    if not input_file.exists():
        print(f"❌ Error: No se encuentra {input_file}")
        sys.exit(1)
    
    # Leer archivo
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("\n🔍 Problemas detectados:")
    
    # 1. Tabla orders (eliminada)
    orders_count = content.count('public.orders')
    if orders_count > 0:
        print(f"   ❌ Referencias a tabla 'orders' eliminada: {orders_count}")
    
    # 2. Funciones obsoletas
    obsolete_funcs = [
        'assign_sets_to_users',
        'handle_envio_entregado',
        'handle_return_status_update'
    ]
    for func in obsolete_funcs:
        if func in content:
            print(f"   ❌ Función obsoleta: {func}")
    
    # 3. Tablas chat (eliminadas en migración 20260325000000)
    if 'chat_' in content:
        print("   ❌ Referencias a tablas chat (eliminadas)")
    
    print("\n🔧 Aplicando limpieza...")
    
    # Extraer solo datos de tablas core
    cleaned_lines = []
    in_data_section = False
    skip_section = False
    
    # Tablas que queremos mantener
    keep_tables = {
        'auth.users', 'auth.identities', 'auth.sessions', 'auth.refresh_tokens',
        'public.users', 'public.user_roles', 'public.sets', 'public.inventory_sets',
        'public.wishlist', 'public.set_piece_list', 'public.shipments',
        'public.reception_operations', 'public.reviews', 'public.referrals',
        'public.donations', 'public.backoffice_operations',
        'public.users_correos_dropping', 'public.users_brickshare_dropping',
        'public.brickshare_pudo_locations', 'public.qr_validation_logs'
    }
    
    # Header
    cleaned_lines.append("-- Datos limpios de seed_full.sql")
    cleaned_lines.append("-- Compatible con esquema actual")
    cleaned_lines.append("-- Generado automáticamente\n")
    cleaned_lines.append("BEGIN;\n")
    cleaned_lines.append("SET session_replication_role = 'replica';\n")
    
    # Procesar línea por línea
    for line in content.split('\n'):
        # Detectar inicio de sección de datos
        if line.startswith('INSERT INTO'):
            table_match = re.match(r'INSERT INTO (\S+)', line)
            if table_match:
                table = table_match.group(1)
                # Solo mantener tablas conocidas y no obsoletas
                if any(keep_table in table for keep_table in keep_tables) and \
                   'orders' not in table and 'chat_' not in table:
                    in_data_section = True
                    skip_section = False
                else:
                    skip_section = True
                    continue
        
        # Copiar líneas de datos válidos
        if in_data_section and not skip_section:
            cleaned_lines.append(line)
            # Fin de INSERT
            if line.strip().endswith(';'):
                in_data_section = False
    
    # Footer
    cleaned_lines.append("\nSET session_replication_role = 'origin';")
    cleaned_lines.append("\n-- Actualizar secuencias")
    cleaned_lines.append("SELECT setval('auth.refresh_tokens_id_seq', (SELECT COALESCE(MAX(id), 1) FROM auth.refresh_tokens), true);")
    cleaned_lines.append("\nCOMMIT;")
    
    # Escribir archivo limpio
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(cleaned_lines))
    
    print(f"\n✅ Archivo limpio generado: {output_file}")
    print(f"📊 Líneas totales: {len(cleaned_lines)}")
    print("\n📋 Siguiente paso:")
    print("   Revisar y aplicar con: psql $DATABASE_URL < supabase/seed_clean.sql")

if __name__ == '__main__':
    main()