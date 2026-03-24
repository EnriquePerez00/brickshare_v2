-- Test script to verify Brickshare deposit selection works correctly
-- This simulates what happens when a user selects a Brickshare deposit

-- Step 1: Create a test user (if not exists)
DO $$
DECLARE
    v_test_user_id UUID;
BEGIN
    -- Check if test user exists
    SELECT user_id INTO v_test_user_id
    FROM auth.users
    WHERE email = 'test-deposit@brickshare.com'
    LIMIT 1;
    
    IF v_test_user_id IS NULL THEN
        -- Create test user in auth.users
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            created_at,
            updated_at,
            aud,
            role
        ) VALUES (
            gen_random_uuid(),
            '00000000-0000-0000-0000-000000000000',
            'test-deposit@brickshare.com',
            crypt('TestPassword123!', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated'
        )
        RETURNING id INTO v_test_user_id;
        
        -- Create user profile
        INSERT INTO public.users (
            user_id,
            email,
            full_name,
            subscription_type,
            user_status
        ) VALUES (
            v_test_user_id,
            'test-deposit@brickshare.com',
            'Test Deposit User',
            'basic',
            'active'
        );
        
        RAISE NOTICE 'Created test user with ID: %', v_test_user_id;
    ELSE
        RAISE NOTICE 'Test user already exists with ID: %', v_test_user_id;
    END IF;
    
    -- Step 2: Ensure we have a test Brickshare deposit location
    INSERT INTO public.brickshare_pudo_locations (
        id,
        name,
        location_name,
        address,
        city,
        postal_code,
        province,
        latitude,
        longitude,
        is_active
    ) VALUES (
        'test-deposit-madrid-001',
        'Test Deposit Madrid',
        'Test Deposit Madrid',
        'Calle Test 123',
        'Madrid',
        '28001',
        'Madrid',
        40.4168,
        -3.7038,
        true
    )
    ON CONFLICT (id) DO UPDATE
    SET is_active = true;
    
    RAISE NOTICE 'Ensured test deposit location exists';
    
    -- Step 3: Test inserting/updating Brickshare PUDO selection
    -- First, clean any existing selection
    DELETE FROM public.users_brickshare_dropping WHERE user_id = v_test_user_id;
    DELETE FROM public.users_correos_dropping WHERE user_id = v_test_user_id;
    
    -- Insert Brickshare PUDO selection
    INSERT INTO public.users_brickshare_dropping (
        user_id,
        brickshare_pudo_id,
        location_name,
        address,
        city,
        postal_code,
        province,
        latitude,
        longitude,
        opening_hours
    ) VALUES (
        v_test_user_id,
        'test-deposit-madrid-001',
        'Test Deposit Madrid',
        'Calle Test 123',
        'Madrid',
        '28001',
        'Madrid',
        40.4168,
        -3.7038,
        '{"description": "Horario comercial del establecimiento"}'::jsonb
    );
    
    -- Update users table with unified reference
    UPDATE public.users
    SET 
        pudo_id = 'test-deposit-madrid-001',
        pudo_type = 'brickshare'
    WHERE user_id = v_test_user_id;
    
    RAISE NOTICE '✅ Successfully saved Brickshare deposit selection';
    
    -- Step 4: Verify the selection
    PERFORM 1
    FROM public.users u
    JOIN public.users_brickshare_dropping b ON u.user_id = b.user_id
    WHERE u.user_id = v_test_user_id
      AND u.pudo_type = 'brickshare'
      AND u.pudo_id = 'test-deposit-madrid-001'
      AND b.brickshare_pudo_id = 'test-deposit-madrid-001';
    
    IF FOUND THEN
        RAISE NOTICE '✅ Verification passed: Brickshare deposit correctly saved and linked';
    ELSE
        RAISE EXCEPTION '❌ Verification failed: Data not correctly saved';
    END IF;
    
END $$;

-- Show final state
SELECT 
    'Test user PUDO selection' as description,
    u.email,
    u.pudo_type,
    u.pudo_id,
    b.location_name,
    b.address
FROM public.users u
LEFT JOIN public.users_brickshare_dropping b ON u.user_id = b.user_id
WHERE u.email = 'test-deposit@brickshare.com';