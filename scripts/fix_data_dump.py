#!/usr/bin/env python3
"""
Script para limpiar el dump de datos y hacerlo compatible con el esquema local.
Elimina columnas que fueron movidas de profiles a users.
"""

import re

def fix_profiles_insert(content):
    """Corrige los INSERT statements de la tabla profiles"""
    # Patrón para encontrar el INSERT de profiles con todos sus valores
    pattern = r"INSERT INTO \"public\"\.\"profiles\" \(\"id\", \"user_id\", \"full_name\", \"avatar_url\", \"sub_status\", \"impact_points\", \"created_at\", \"updated_at\", \"address\", \"address_extra\", \"zip_code\", \"city\", \"province\", \"phone\", \"email\", \"subscription_id\", \"subscription_type\", \"subscription_status\"\) VALUES\s*\('([^']+)', '([^']+)', '([^']*)', (NULL|'[^']*'), '([^']*)', (\d+), '([^']+)', '([^']+)', [^;]+\);"
    
    def replace_match(match):
        # Extraer solo los valores que necesitamos
        id_val = match.group(1)
        full_name = match.group(3)
        avatar_url = match.group(4)
        sub_status = match.group(5)
        impact_points = match.group(6)
        created_at = match.group(7)
        updated_at = match.group(8)
        
        return f'INSERT INTO "public"."profiles" ("id", "full_name", "avatar_url", "sub_status", "impact_points", "created_at", "updated_at") VALUES\n(\'{id_val}\', \'{full_name}\', {avatar_url}, \'{sub_status}\', {impact_points}, \'{created_at}\', \'{updated_at}\');'
    
    return re.sub(pattern, replace_match, content, flags=re.MULTILINE)

def main():
    input_file = 'backups/remote_data.sql'
    output_file = 'backups/remote_data_fixed.sql'
    
    print(f"Leyendo {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("Corrigiendo INSERT statements de profiles...")
    content = fix_profiles_insert(content)
    
    print(f"Escribiendo {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Dump corregido exitosamente")

if __name__ == '__main__':
    main()