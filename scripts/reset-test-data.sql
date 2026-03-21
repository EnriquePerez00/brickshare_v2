-- ============================================================================
-- Script de Limpieza de Datos para Testing
-- ============================================================================
-- Propósito: Resetear la base de datos para poder probar el flujo de envíos
-- - Elimina todos los envíos actuales
-- - Limpia y repuebla las wishlists con 3 sets por usuario
-- - Resetea estados de usuarios a 'sin set'
-- - NO afecta a usuarios admin/operador
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. LIMPIAR ENVÍOS
-- ============================================================================
-- Eliminar todos los registros de la tabla envios
DELETE FROM envios;

DO $$ 
BEGIN 
    RAISE NOTICE '✓ Todos los envíos han sido eliminados';
END $$;

-- ============================================================================
-- 2. LIMPIAR WISHLISTS
-- ============================================================================
-- Eliminar todas las wishlists actuales
DELETE FROM wishlist;

DO $$ 
BEGIN 
    RAISE NOTICE '✓ Todas las wishlists han sido limpiadas';
END $$;

-- ============================================================================
-- 3. ASEGURAR INVENTARIO (inventory_sets)
-- ============================================================================
-- Asegurar que todos los sets tienen entradas de inventario con stock

DO $$
DECLARE
    v_sets_with_inventory INT;
    v_sets_without_inventory INT;
BEGIN
    -- Crear entradas de inventario para sets que no las tengan
    INSERT INTO inventory_sets (set_id, set_ref, inventory_set_total_qty, en_envio, en_devolucion, en_reparacion)
    SELECT 
        s.id,
        s.set_ref,
        5, -- Stock inicial de 5 unidades
        0, -- En envío
        0, -- En devolución
        0  -- En reparación
    FROM sets s
    WHERE s.set_status = 'available'
    AND NOT EXISTS (
        SELECT 1 FROM inventory_sets i WHERE i.set_id = s.id
    )
    ON CONFLICT (set_id) DO NOTHING;
    
    -- Actualizar stock de sets existentes a un mínimo de 5
    UPDATE inventory_sets
    SET inventory_set_total_qty = GREATEST(inventory_set_total_qty, 5)
    WHERE set_id IN (
        SELECT id FROM sets WHERE set_status = 'available'
    );
    
    -- Contar resultados
    SELECT COUNT(*) INTO v_sets_with_inventory
    FROM inventory_sets i
    JOIN sets s ON i.set_id = s.id
    WHERE s.set_status = 'available'
    AND i.inventory_set_total_qty > 0;
    
    RAISE NOTICE '✓ Inventario actualizado: % sets con stock disponible', v_sets_with_inventory;
END $$;

-- ============================================================================
-- 4. REPOBLAR WISHLISTS
-- ============================================================================
-- Insertar 10 sets aleatorios para cada usuario regular (no admin/operador)
-- Solo usuarios con user_role = 'user' o sin rol específico de admin/operador

DO $$
DECLARE
    v_user_record RECORD;
    v_available_sets_count INT;
    v_inserted_count INT := 0;
    v_user_count INT := 0;
    v_set_record RECORD;
BEGIN
    -- Verificar que hay sets con stock en inventory_sets
    SELECT COUNT(*) INTO v_available_sets_count 
    FROM sets s
    JOIN inventory_sets i ON s.id = i.set_id
    WHERE s.set_status = 'available'
    AND i.inventory_set_total_qty > 0;
    
    IF v_available_sets_count = 0 THEN
        RAISE WARNING '⚠ No hay sets con stock disponible en inventory_sets. Verifica que existan sets con inventario.';
        RETURN;
    END IF;
    
    RAISE NOTICE 'Sets con stock encontrados: %', v_available_sets_count;
    
    -- Obtener lista de usuarios regulares (excluir admin/operador)
    FOR v_user_record IN 
        SELECT DISTINCT u.user_id
        FROM users u
        WHERE NOT EXISTS (
            SELECT 1 
            FROM user_roles ur 
            WHERE ur.user_id = u.user_id 
            AND ur.role IN ('admin', 'operador')
        )
    LOOP
        v_user_count := v_user_count + 1;
        
        -- Insertar 10 sets aleatorios para este usuario que tengan stock
        -- Usando selección directa sin arrays para evitar NULL
        FOR v_set_record IN 
            SELECT s.id 
            FROM sets s
            JOIN inventory_sets i ON s.id = i.set_id
            WHERE s.set_status = 'available'
            AND i.inventory_set_total_qty > 0
            ORDER BY RANDOM() 
            LIMIT 10
        LOOP
            -- Insertar en wishlist (con manejo de duplicados)
            INSERT INTO wishlist (user_id, set_id, status, status_changed_at)
            VALUES (v_user_record.user_id, v_set_record.id, true, now())
            ON CONFLICT (user_id, set_id) DO NOTHING;
            
            v_inserted_count := v_inserted_count + 1;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE '✓ Wishlists repobladas: % usuarios procesados, % sets insertados', 
        v_user_count, v_inserted_count;
END $$;

-- ============================================================================
-- 5. RESETEAR ESTADOS DE USUARIOS
-- ============================================================================
-- Actualizar estado de usuarios a 'sin set' (solo usuarios regulares)
UPDATE users 
SET user_status = 'sin set',
    updated_at = now()
WHERE NOT EXISTS (
    SELECT 1 
    FROM user_roles ur 
    WHERE ur.user_id = users.user_id 
    AND ur.role IN ('admin', 'operador')
);

DO $$ 
BEGIN 
    RAISE NOTICE '✓ Estados de usuarios reseteados a "sin set"';
END $$;

-- ============================================================================
-- 6. VERIFICACIÓN FINAL
-- ============================================================================
DO $$
DECLARE
    v_envios_count INT;
    v_wishlist_count INT;
    v_users_sin_set INT;
    v_users_count INT;
    v_inventory_stock INT;
BEGIN
    -- Contar envíos (debe ser 0)
    SELECT COUNT(*) INTO v_envios_count FROM envios;
    
    -- Contar items en wishlist
    SELECT COUNT(*) INTO v_wishlist_count FROM wishlist;
    
    -- Contar usuarios con estado 'sin set'
    SELECT COUNT(*) INTO v_users_sin_set 
    FROM users 
    WHERE user_status = 'sin set';
    
    -- Contar usuarios regulares totales
    SELECT COUNT(*) INTO v_users_count
    FROM users u
    WHERE NOT EXISTS (
        SELECT 1 
        FROM user_roles ur 
        WHERE ur.user_id = u.user_id 
        AND ur.role IN ('admin', 'operador')
    );
    
    -- Contar sets con stock en inventario
    SELECT COUNT(*) INTO v_inventory_stock
    FROM inventory_sets i
    JOIN sets s ON i.set_id = s.id
    WHERE s.set_status = 'available'
    AND i.inventory_set_total_qty > 0;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VERIFICACIÓN FINAL';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Envíos en base de datos: %', v_envios_count;
    RAISE NOTICE 'Items en wishlist: %', v_wishlist_count;
    RAISE NOTICE 'Sets con stock en inventario: %', v_inventory_stock;
    RAISE NOTICE 'Usuarios regulares: %', v_users_count;
    RAISE NOTICE 'Usuarios con estado "sin set": %', v_users_sin_set;
    RAISE NOTICE '========================================';
    
    IF v_envios_count = 0 AND v_wishlist_count > 0 AND v_users_sin_set > 0 AND v_inventory_stock > 0 THEN
        RAISE NOTICE '✓ Base de datos lista para pruebas de envíos';
    ELSE
        RAISE WARNING '⚠ Verificar los conteos arriba - puede haber un problema';
    END IF;
END $$;

COMMIT;

DO $$ 
BEGIN 
    RAISE NOTICE '';
    RAISE NOTICE '✓✓✓ Script completado exitosamente ✓✓✓';
END $$;