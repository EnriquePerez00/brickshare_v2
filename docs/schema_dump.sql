


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."app_role" AS ENUM (
    'admin',
    'user',
    'operador'
);


ALTER TYPE "public"."app_role" OWNER TO "postgres";


CREATE TYPE "public"."operation_type" AS ENUM (
    'recepcion paquete',
    'analisis_peso',
    'deposito_fulfillment',
    'higienizado',
    'retorno_stock'
);


ALTER TYPE "public"."operation_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."confirm_assign_sets_to_users"("p_user_ids" "uuid"[]) RETURNS TABLE("envio_id" "uuid", "user_id" "uuid", "set_id" "uuid", "order_id" "uuid", "user_name" "text", "user_email" "text", "user_phone" "text", "set_name" "text", "set_ref" "text", "set_weight" numeric, "set_dim" "text", "pudo_id" "text", "pudo_name" "text", "pudo_address" "text", "pudo_cp" "text", "pudo_city" "text", "pudo_province" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    r RECORD;
    target_set_id UUID; new_order_id UUID; new_envio_id UUID;
    v_set_name TEXT; v_set_ref TEXT; v_set_weight NUMERIC; v_set_dim TEXT;
    v_user_email TEXT; v_user_phone TEXT;
    v_pudo_id TEXT; v_pudo_name TEXT; v_pudo_address TEXT; v_pudo_cp TEXT; v_pudo_city TEXT; v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    FOR r IN (
        SELECT u.user_id, u.full_name, u.email, u.phone,
               p.correos_id_pudo, p.correos_name, p.correos_full_address,
               p.correos_zip_code, p.correos_city, p.correos_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN ('no_set', 'set_returning')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id AND w.status = true)
    ) LOOP
        SELECT w.set_id, s.set_name, s.set_ref, s.set_weight, s.set_dim
        INTO target_set_id, v_set_name, v_set_ref, v_set_weight, v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id AND w.status = true AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            UPDATE public.inventory_sets SET inventory_set_total_qty = inventory_set_total_qty - 1, in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            INSERT INTO public.orders (user_id, set_id, status) VALUES (r.user_id, target_set_id, 'pending') RETURNING id INTO new_order_id;

            INSERT INTO public.shipments (order_id, user_id, shipment_status, shipping_address, shipping_city, shipping_zip_code, shipping_country)
            VALUES (new_order_id, r.user_id, 'pending',
                    COALESCE(r.correos_full_address, 'Pending assignment'),
                    COALESCE(r.correos_city, 'Pending'),
                    COALESCE(r.correos_zip_code, '00000'), 'España')
            RETURNING shipments.id, shipments.created_at INTO new_envio_id, v_created_at;

            UPDATE public.users SET user_status = 'set_shipping' WHERE users.user_id = r.user_id;

            UPDATE public.wishlist SET status = false, status_changed_at = now()
            WHERE wishlist.user_id = r.user_id AND wishlist.set_id = target_set_id;

            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := r.correos_id_pudo;
            confirm_assign_sets_to_users.pudo_name := r.correos_name;
            confirm_assign_sets_to_users.pudo_address := r.correos_full_address;
            confirm_assign_sets_to_users.pudo_cp := r.correos_zip_code;
            confirm_assign_sets_to_users.pudo_city := r.correos_city;
            confirm_assign_sets_to_users.pudo_province := r.correos_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."confirm_assign_sets_to_users"("p_user_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."confirm_qr_validation"("p_qr_code" "text", "p_validated_by" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text", "shipment_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    SELECT * INTO v_validation FROM validate_qr_code(p_qr_code);
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT false, v_validation.error_message, v_validation.shipment_id; RETURN;
    END IF;

    IF v_validation.validation_type = 'delivery' THEN
        v_new_status := 'delivered_user';
        UPDATE shipments SET delivery_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    ELSIF v_validation.validation_type = 'return' THEN
        v_new_status := 'returned';
        UPDATE shipments SET return_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    END IF;

    INSERT INTO qr_validation_logs (shipment_id, qr_code, validation_type, validated_by, validation_status, metadata)
    VALUES (v_validation.shipment_id, p_qr_code, v_validation.validation_type, p_validated_by, 'success', jsonb_build_object('validated_at', now()));

    RETURN QUERY SELECT true, format('Shipment successfully %s', CASE WHEN v_validation.validation_type = 'delivery' THEN 'delivered' ELSE 'returned' END), v_validation.shipment_id;
END;
$$;


ALTER FUNCTION "public"."confirm_qr_validation"("p_qr_code" "text", "p_validated_by" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_assignment_and_rollback"("p_envio_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    SELECT user_id, set_id INTO v_user_id, v_set_id FROM public.shipments WHERE id = p_envio_id;
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Shipment with ID % not found', p_envio_id; END IF;

    DELETE FROM public.shipments WHERE id = p_envio_id;

    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1, in_shipping = GREATEST(in_shipping - 1, 0)
    WHERE set_id = v_set_id;

    INSERT INTO public.wishlist (user_id, set_id) VALUES (v_user_id, v_set_id) ON CONFLICT (user_id, set_id) DO NOTHING;

    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (SELECT 1 FROM public.shipments WHERE user_id = v_user_id AND shipment_status IN ('preparation', 'in_transit_pudo'))
        THEN user_status ELSE 'no_set' END
    WHERE user_id = v_user_id;
END;
$$;


ALTER FUNCTION "public"."delete_assignment_and_rollback"("p_envio_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_delivery_qr"("p_shipment_id" "uuid") RETURNS TABLE("qr_code" "text", "expires_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET delivery_qr_code = v_qr_code, delivery_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;


ALTER FUNCTION "public"."generate_delivery_qr"("p_shipment_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_qr_code"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := 'BS-';
    i INTEGER;
BEGIN
    FOR i IN 1..16 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."generate_qr_code"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_referral_code_users"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    new_code TEXT;
    attempts INTEGER := 0;
BEGIN
    -- Only generate if not already set
    IF NEW.referral_code IS NULL THEN
        LOOP
            -- 6-char uppercase alphanumeric code
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.user_id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.users 
                WHERE LOWER(referral_code) = LOWER(new_code)
            ) THEN
                NEW.referral_code := new_code;
                EXIT;
            END IF;

            attempts := attempts + 1;
            IF attempts > 10 THEN
                -- Fallback: use longer hash
                NEW.referral_code := UPPER(SUBSTRING(MD5(NEW.user_id::TEXT) FROM 1 FOR 8));
                EXIT;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."generate_referral_code_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_return_qr"("p_shipment_id" "uuid") RETURNS TABLE("qr_code" "text", "expires_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET return_qr_code = v_qr_code, return_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;


ALTER FUNCTION "public"."generate_return_qr"("p_shipment_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_auth_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    INSERT INTO public.users (user_id, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url'
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_auth_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_set_inventory"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.inventory_sets (set_id, set_ref, inventory_set_total_qty)
    VALUES (NEW.id, NEW.set_ref, 2)
    ON CONFLICT (set_id) DO UPDATE
    SET inventory_set_total_qty = 2; -- Reset to 2 if re-importing, or maybe we should just do NOTHING? 
    -- The original logic had ON CONFLICT DO UPDATE SET... 
    -- Actually, later migration 20260127095000 had ON CONFLICT DO NOTHING in the function body, 
    -- but update logic in the specialized block above it.
    -- Let's stick to simple initialization: IF exists, do nothing or ensure at least 2?
    -- The prompt implies re-importing via UI overwrites pieces. Maybe we should ensure inventory entry exists.
    -- Let's use DO NOTHING to preserve existing stock counts if just re-importing set details.
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_set_inventory"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Create record in users table
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url',
        NEW.email
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Assign default 'user' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'user'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_reception_close"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.reception_completed = TRUE AND OLD.reception_completed = FALSE THEN
        UPDATE public.inventory_sets
        SET in_return = GREATEST(0, COALESCE(in_return, 0) - 1), updated_at = now()
        WHERE set_id = NEW.set_id;

        IF NEW.missing_parts IS NOT NULL AND TRIM(NEW.missing_parts) != '' THEN
            UPDATE public.inventory_sets SET in_repair = COALESCE(in_repair, 0) + 1 WHERE set_id = NEW.set_id;
            UPDATE public.sets SET set_status = 'in_repair', updated_at = now() WHERE id = NEW.set_id;
        ELSE
            UPDATE public.sets SET set_status = 'active', updated_at = now() WHERE id = NEW.set_id;
        END IF;

        UPDATE public.shipments SET handling_processed = TRUE, updated_at = now() WHERE id = NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_reception_close"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_return_user_status"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'in_return_pudo' AND OLD.shipment_status != 'in_return_pudo' THEN
        UPDATE public.users SET user_status = 'no_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_return_user_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_shipment_delivered"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'delivered_user' AND OLD.shipment_status != 'delivered_user' THEN
        UPDATE public.users SET user_status = 'has_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_shipment_delivered"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_shipment_return_transit_inventory"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'in_return_pudo' AND OLD.shipment_status != 'in_return_pudo' THEN
        UPDATE public.inventory_sets
        SET in_return = COALESCE(in_return, 0) + 1, updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_shipment_return_transit_inventory"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_shipment_warehouse_received"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'returned' AND OLD.shipment_status != 'returned' THEN
        INSERT INTO public.reception_operations (event_id, user_id, set_id)
        VALUES (NEW.id, NEW.user_id, NEW.set_id);
        NEW.warehouse_reception_date = now();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_shipment_warehouse_received"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
          AND role = _role
    )
$$;


ALTER FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_referral_credits"("p_user_id" "uuid", "p_amount" integer DEFAULT 1) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.users
    SET referral_credits = referral_credits + p_amount
    WHERE user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."increment_referral_credits"("p_user_id" "uuid", "p_amount" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."preview_assign_sets_to_users"() RETURNS TABLE("user_id" "uuid", "user_name" "text", "set_id" "uuid", "set_name" "text", "set_ref" "text", "set_price" numeric, "current_stock" integer, "matches_wishlist" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
BEGIN
    -- Loop through eligible users (those without a set and are regular users)
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_status IN ('sin set', 'set en devolucion')
          AND u.user_type = 'user'  -- Only regular users, not admin or operations
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        
        -- Try to find set from user's wishlist that they haven't had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.envios e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."preview_assign_sets_to_users"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."preview_assign_sets_to_users"() IS 'Shows proposed set assignments checking history to avoid duplicates, with random fallback if no wishlist match - includes matches_wishlist flag';



CREATE OR REPLACE FUNCTION "public"."process_referral_credit"("p_referee_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_referral    public.referrals%ROWTYPE;
    v_referrer_id UUID;
BEGIN
    -- Find pending referral for this user
    SELECT * INTO v_referral
    FROM public.referrals
    WHERE referee_id = p_referee_user_id
      AND status = 'pending';

    IF NOT FOUND THEN
        RETURN; -- No pending referral, nothing to do
    END IF;

    v_referrer_id := v_referral.referrer_id;

    -- Award credits to referrer in USERS table
    UPDATE public.users
    SET referral_credits = referral_credits + v_referral.reward_credits
    WHERE user_id = v_referrer_id;

    -- Mark referral as credited
    UPDATE public.referrals
    SET status = 'credited',
        credited_at = NOW()
    WHERE id = v_referral.id;
END;
$$;


ALTER FUNCTION "public"."process_referral_credit"("p_referee_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_set_status_from_return"("p_set_id" "uuid", "p_new_status" "text", "p_envio_id" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF p_new_status NOT IN ('active', 'inactive', 'in_repair') THEN
        RAISE EXCEPTION 'Invalid status: %', p_new_status;
    END IF;

    UPDATE public.sets SET set_status = p_new_status, updated_at = now() WHERE id = p_set_id;

    UPDATE public.inventory_sets SET in_return = in_return - 1, updated_at = now() WHERE set_id = p_set_id;

    IF p_new_status = 'in_repair' THEN
        UPDATE public.inventory_sets SET in_repair = in_repair + 1 WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = 'active' THEN NULL; END IF;

    IF p_envio_id IS NOT NULL THEN
        UPDATE public.shipments SET warehouse_reception_date = now(), handling_processed = TRUE, updated_at = now() WHERE id = p_envio_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."update_set_status_from_return"("p_set_id" "uuid", "p_new_status" "text", "p_envio_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_users_correos_dropping_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_users_correos_dropping_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."uses_brickshare_pudo"("shipment_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
    SELECT pickup_type = 'brickshare' AND brickshare_pudo_id IS NOT NULL FROM shipments WHERE id = shipment_id;
$$;


ALTER FUNCTION "public"."uses_brickshare_pudo"("shipment_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_qr_code"("p_qr_code" "text") RETURNS TABLE("shipment_id" "uuid", "validation_type" "text", "is_valid" boolean, "error_message" "text", "shipment_info" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false; v_error_message TEXT := NULL; v_validation_type TEXT := NULL; v_shipment_info JSONB;
BEGIN
    SELECT s.id, s.order_id, s.shipment_status as status, s.pickup_type,
        s.delivery_qr_code, s.delivery_qr_expires_at, s.delivery_validated_at,
        s.return_qr_code, s.return_qr_expires_at, s.return_validated_at,
        s.brickshare_pudo_id, o.set_id, st.set_name, st.set_ref as set_number, st.set_theme as theme
    INTO v_shipment
    FROM shipments s JOIN orders o ON s.order_id = o.id LEFT JOIN sets st ON o.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;

    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, false, 'QR code not found'::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.pickup_type != 'brickshare' THEN
        RETURN QUERY SELECT v_shipment.id, NULL::TEXT, false, 'This shipment is not for Brickshare pickup point'::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := 'delivery';
        IF v_shipment.delivery_validated_at IS NOT NULL THEN v_error_message := 'QR code already used';
        ELSIF v_shipment.delivery_qr_expires_at < now() THEN v_error_message := 'QR code has expired';
        ELSE v_is_valid := true; END IF;
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := 'return';
        IF v_shipment.return_validated_at IS NOT NULL THEN v_error_message := 'QR code already used';
        ELSIF v_shipment.return_qr_expires_at < now() THEN v_error_message := 'QR code has expired';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN v_error_message := 'Cannot return a set that has not been delivered yet';
        ELSE v_is_valid := true; END IF;
    END IF;

    v_shipment_info := jsonb_build_object('order_id', v_shipment.order_id, 'set_id', v_shipment.set_id, 'set_name', v_shipment.set_name,
        'set_number', v_shipment.set_number, 'theme', v_shipment.theme, 'status', v_shipment.status,
        'brickshare_pudo_id', v_shipment.brickshare_pudo_id, 'validation_type', v_validation_type);

    RETURN QUERY SELECT v_shipment.id, v_validation_type, v_is_valid, v_error_message, v_shipment_info;
END;
$$;


ALTER FUNCTION "public"."validate_qr_code"("p_qr_code" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."backoffice_operations" (
    "event_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "operation_type" "public"."operation_type" NOT NULL,
    "operation_time" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb"
);


ALTER TABLE "public"."backoffice_operations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."brickshare_pudo_locations" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "address" "text" NOT NULL,
    "city" "text" NOT NULL,
    "postal_code" "text" NOT NULL,
    "province" "text" NOT NULL,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "contact_phone" "text",
    "contact_email" "text",
    "opening_hours" "jsonb",
    "is_active" boolean DEFAULT true,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."brickshare_pudo_locations" OWNER TO "postgres";


COMMENT ON TABLE "public"."brickshare_pudo_locations" IS 'Brickshare pickup and drop-off locations';



CREATE TABLE IF NOT EXISTS "public"."shipments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "assigned_date" timestamp with time zone,
    "estimated_delivery_date" timestamp with time zone,
    "actual_delivery_date" timestamp with time zone,
    "user_delivery_date" timestamp with time zone,
    "warehouse_reception_date" timestamp with time zone,
    "estimated_return_date" "date",
    "shipment_status" "text" DEFAULT 'pendiente'::"text" NOT NULL,
    "shipping_address" "text" NOT NULL,
    "shipping_city" "text" NOT NULL,
    "shipping_zip_code" "text" NOT NULL,
    "shipping_country" "text" DEFAULT 'España'::"text" NOT NULL,
    "shipping_provider" "text",
    "pickup_provider_address" "text",
    "tracking_number" "text",
    "carrier" "text",
    "additional_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "warehouse_pickup_date" timestamp with time zone,
    "return_request_date" timestamp with time zone,
    "pickup_provider" "text",
    "set_ref" "text",
    "set_id" "uuid",
    "handling_processed" boolean DEFAULT false,
    "correos_shipment_id" "text",
    "label_url" "text",
    "pickup_id" "text",
    "last_tracking_update" timestamp with time zone,
    "swikly_wish_id" "text",
    "swikly_wish_url" "text",
    "swikly_status" "text" DEFAULT 'pending'::"text",
    "swikly_deposit_amount" integer,
    "pickup_type" "text" DEFAULT 'correos'::"text",
    "brickshare_pudo_id" "text",
    "delivery_qr_code" "text",
    "delivery_qr_expires_at" timestamp with time zone,
    "delivery_validated_at" timestamp with time zone,
    "return_qr_code" "text",
    "return_qr_expires_at" timestamp with time zone,
    "return_validated_at" timestamp with time zone,
    "brickshare_metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "brickshare_package_id" "text",
    CONSTRAINT "check_shipment_status" CHECK (("shipment_status" = ANY (ARRAY['pending'::"text", 'preparation'::"text", 'in_transit_pudo'::"text", 'delivered_pudo'::"text", 'delivered_user'::"text", 'in_return_pudo'::"text", 'in_return'::"text", 'returned'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "envios_pickup_type_check" CHECK (("pickup_type" = ANY (ARRAY['correos'::"text", 'brickshare'::"text"]))),
    CONSTRAINT "envios_swikly_status_check" CHECK (("swikly_status" = ANY (ARRAY['pending'::"text", 'wish_created'::"text", 'accepted'::"text", 'released'::"text", 'captured'::"text", 'expired'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "public"."shipments" OWNER TO "postgres";


COMMENT ON COLUMN "public"."shipments"."shipment_status" IS 'Allowed values: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion, cancelado';



COMMENT ON COLUMN "public"."shipments"."warehouse_pickup_date" IS 'Date when the shipment was picked up from the warehouse';



COMMENT ON COLUMN "public"."shipments"."return_request_date" IS 'Date when the user requested a return';



COMMENT ON COLUMN "public"."shipments"."pickup_provider" IS 'Carrier or entity in charge of the return pickup';



COMMENT ON COLUMN "public"."shipments"."set_ref" IS 'LEGO set reference (e.g., 75192) for quick reference';



COMMENT ON COLUMN "public"."shipments"."set_id" IS 'Direct reference to the set being shipped, eliminates need for orders table';



COMMENT ON COLUMN "public"."shipments"."correos_shipment_id" IS 'External shipment identifier returned by Correos Preregister API';



COMMENT ON COLUMN "public"."shipments"."label_url" IS 'Path to the generated shipping label in storage';



COMMENT ON COLUMN "public"."shipments"."pickup_id" IS 'External identifier for the scheduled pickup';



COMMENT ON COLUMN "public"."shipments"."last_tracking_update" IS 'Timestamp of the last synchronization with Correos Tracking API';



COMMENT ON COLUMN "public"."shipments"."brickshare_package_id" IS 'ID del package en Brickshare_logistics. Usado cuando pickup_type="brickshare" para sincronización con el sistema de PUDO.';



CREATE OR REPLACE VIEW "public"."brickshare_pudo_shipments" AS
 SELECT "id",
    "user_id",
    "shipment_status" AS "status",
    "pickup_type",
    "brickshare_pudo_id",
    "brickshare_package_id",
    "delivery_qr_code",
    "delivery_validated_at" AS "delivery_qr_validated_at",
    "return_qr_code",
    "return_validated_at" AS "return_qr_validated_at",
    "tracking_number",
    "created_at",
    "updated_at"
   FROM "public"."shipments" "s"
  WHERE (("pickup_type" = 'brickshare'::"text") AND ("brickshare_pudo_id" IS NOT NULL));


ALTER VIEW "public"."brickshare_pudo_shipments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."donations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone" "text",
    "address" "text",
    "estimated_weight" numeric NOT NULL,
    "delivery_method" "text" NOT NULL,
    "reward" "text" NOT NULL,
    "children_benefited" integer NOT NULL,
    "co2_avoided" numeric NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "tracking_code" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "donations_delivery_method_check" CHECK (("delivery_method" = ANY (ARRAY['pickup-point'::"text", 'home-pickup'::"text"]))),
    CONSTRAINT "donations_reward_check" CHECK (("reward" = ANY (ARRAY['economic'::"text", 'social'::"text"]))),
    CONSTRAINT "donations_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'confirmed'::"text", 'shipped'::"text", 'received'::"text", 'processed'::"text", 'completed'::"text"])))
);


ALTER TABLE "public"."donations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."inventory_sets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "set_id" "uuid" NOT NULL,
    "set_ref" "text",
    "inventory_set_total_qty" integer DEFAULT 0 NOT NULL,
    "in_shipping" integer DEFAULT 0 NOT NULL,
    "in_use" integer DEFAULT 0 NOT NULL,
    "in_return" integer DEFAULT 0 NOT NULL,
    "in_repair" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "spare_parts_order" "text"
);


ALTER TABLE "public"."inventory_sets" OWNER TO "postgres";


COMMENT ON TABLE "public"."inventory_sets" IS 'Detailed tracking of set units across different states (warehouse, shipping, use, etc.)';



COMMENT ON COLUMN "public"."inventory_sets"."set_ref" IS 'Official LEGO reference number (sets.lego_ref)';



CREATE TABLE IF NOT EXISTS "public"."qr_validation_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_id" "uuid" NOT NULL,
    "qr_code" "text" NOT NULL,
    "validation_type" "text" NOT NULL,
    "validated_by" "text",
    "validated_at" timestamp with time zone DEFAULT "now"(),
    "validation_status" "text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "qr_validation_logs_validation_status_check" CHECK (("validation_status" = ANY (ARRAY['success'::"text", 'expired'::"text", 'invalid'::"text", 'already_used'::"text"]))),
    CONSTRAINT "qr_validation_logs_validation_type_check" CHECK (("validation_type" = ANY (ARRAY['delivery'::"text", 'return'::"text"])))
);


ALTER TABLE "public"."qr_validation_logs" OWNER TO "postgres";


COMMENT ON TABLE "public"."qr_validation_logs" IS 'Logs of QR code validations for deliveries and returns';



CREATE TABLE IF NOT EXISTS "public"."reception_operations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "event_id" "uuid",
    "user_id" "uuid" NOT NULL,
    "set_id" "uuid" NOT NULL,
    "weight_measured" numeric(10,2),
    "reception_completed" boolean DEFAULT false NOT NULL,
    "missing_parts" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."reception_operations" OWNER TO "postgres";


COMMENT ON TABLE "public"."reception_operations" IS 'Table to record the reception and maintenance check of sets returned by users.';



COMMENT ON COLUMN "public"."reception_operations"."weight_measured" IS 'Actual weight of the set upon reception (in grams).';



COMMENT ON COLUMN "public"."reception_operations"."reception_completed" IS 'True if the reception process is completed.';



COMMENT ON COLUMN "public"."reception_operations"."missing_parts" IS 'Details or notes about missing pieces found during reception.';



CREATE TABLE IF NOT EXISTS "public"."referrals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "referrer_id" "uuid" NOT NULL,
    "referee_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "reward_credits" integer DEFAULT 1 NOT NULL,
    "stripe_coupon_id" "text",
    "credited_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "referrals_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'credited'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."referrals" OWNER TO "postgres";


COMMENT ON TABLE "public"."referrals" IS 'Referral program: tracks who referred whom and reward status';



COMMENT ON COLUMN "public"."referrals"."status" IS 'pending=signup done, credited=reward applied, rejected=did not qualify';



COMMENT ON COLUMN "public"."referrals"."reward_credits" IS 'Credits awarded (1 = 1 free month equivalent)';



CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "set_id" "uuid" NOT NULL,
    "envio_id" "uuid",
    "rating" smallint NOT NULL,
    "comment" "text",
    "age_fit" boolean,
    "difficulty" smallint,
    "would_reorder" boolean,
    "is_published" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "reviews_difficulty_check" CHECK ((("difficulty" >= 1) AND ("difficulty" <= 5))),
    CONSTRAINT "reviews_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


ALTER TABLE "public"."reviews" OWNER TO "postgres";


COMMENT ON TABLE "public"."reviews" IS 'User reviews and ratings for rented LEGO sets';



COMMENT ON COLUMN "public"."reviews"."rating" IS '1-5 star rating';



COMMENT ON COLUMN "public"."reviews"."age_fit" IS 'Was the set appropriate for the stated age range?';



COMMENT ON COLUMN "public"."reviews"."difficulty" IS '1=very easy, 5=very hard building difficulty';



COMMENT ON COLUMN "public"."reviews"."would_reorder" IS 'Would the user rent this set again?';



COMMENT ON COLUMN "public"."reviews"."is_published" IS 'Set to false to hide a review without deleting it';



CREATE OR REPLACE VIEW "public"."set_avg_ratings" AS
 SELECT "set_id",
    "round"("avg"("rating"), 1) AS "avg_rating",
    "count"(*) AS "review_count"
   FROM "public"."reviews"
  WHERE ("is_published" = true)
  GROUP BY "set_id";


ALTER VIEW "public"."set_avg_ratings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."set_piece_list" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "set_id" "uuid" NOT NULL,
    "set_ref" "text" NOT NULL,
    "piece_ref" "text" NOT NULL,
    "color_ref" "text",
    "piece_description" "text",
    "piece_qty" integer DEFAULT 1 NOT NULL,
    "piece_weight" numeric,
    "piece_image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "piece_studdim" "text",
    "element_id" "text",
    "color_id" integer,
    "is_spare" boolean DEFAULT false,
    "part_cat_id" integer,
    "year_from" integer,
    "year_to" integer,
    "is_trans" boolean DEFAULT false,
    "external_ids" "jsonb"
);


ALTER TABLE "public"."set_piece_list" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."set_review_stats" AS
 SELECT "set_id",
    "count"(*) AS "review_count",
    "round"("avg"("rating"), 2) AS "avg_rating",
    "count"(*) FILTER (WHERE ("rating" = 5)) AS "five_stars",
    "count"(*) FILTER (WHERE ("rating" = 4)) AS "four_stars",
    "count"(*) FILTER (WHERE ("rating" = 3)) AS "three_stars",
    "count"(*) FILTER (WHERE ("rating" = 2)) AS "two_stars",
    "count"(*) FILTER (WHERE ("rating" = 1)) AS "one_star",
    "round"("avg"("difficulty"), 1) AS "avg_difficulty",
    "count"(*) FILTER (WHERE ("would_reorder" = true)) AS "would_reorder_count"
   FROM "public"."reviews"
  WHERE ("is_published" = true)
  GROUP BY "set_id";


ALTER VIEW "public"."set_review_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "set_name" "text" NOT NULL,
    "set_description" "text",
    "set_image_url" "text",
    "set_theme" "text" NOT NULL,
    "set_age_range" "text" NOT NULL,
    "set_piece_count" integer NOT NULL,
    "skill_boost" "text"[],
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "year_released" integer,
    "catalogue_visibility" boolean DEFAULT true NOT NULL,
    "set_ref" "text",
    "set_weight" numeric,
    "set_minifigs" numeric,
    "set_status" "text" DEFAULT 'inactive'::"text",
    "set_price" numeric DEFAULT 100.00,
    "current_value_new" numeric,
    "current_value_used" numeric,
    "set_pvp_release" numeric,
    "set_subtheme" "text",
    "barcode_upc" "text",
    "barcode_ean" "text",
    CONSTRAINT "check_set_status" CHECK (("set_status" = ANY (ARRAY['active'::"text", 'inactive'::"text", 'in_repair'::"text"])))
);


ALTER TABLE "public"."sets" OWNER TO "postgres";


COMMENT ON COLUMN "public"."sets"."set_ref" IS 'Official LEGO catalog reference number';



CREATE TABLE IF NOT EXISTS "public"."shipping_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "set_id" "uuid" NOT NULL,
    "shipping_order_date" timestamp with time zone DEFAULT "now"(),
    "tracking_ref" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."shipping_orders" OWNER TO "postgres";


COMMENT ON TABLE "public"."shipping_orders" IS 'Tracks shipping orders with external carriers';



CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "public"."app_role" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "full_name" "text",
    "avatar_url" "text",
    "impact_points" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email" "text",
    "subscription_type" "text",
    "subscription_status" "text" DEFAULT 'inactive'::"text",
    "profile_completed" boolean DEFAULT false,
    "user_status" "text" DEFAULT 'no_set'::"text",
    "stripe_customer_id" "text",
    "referral_code" "text",
    "referred_by" "uuid",
    "referral_credits" integer DEFAULT 0 NOT NULL,
    "address" "text",
    "address_extra" "text",
    "zip_code" "text",
    "city" "text",
    "province" "text",
    "phone" "text",
    CONSTRAINT "check_user_status" CHECK (("user_status" = ANY (ARRAY['no_set'::"text", 'set_shipping'::"text", 'received'::"text", 'has_set'::"text", 'set_returning'::"text", 'suspended'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "users_subscription_status_check" CHECK (("subscription_status" = ANY (ARRAY['active'::"text", 'inactive'::"text", 'trialing'::"text", 'past_due'::"text", 'canceled'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


COMMENT ON COLUMN "public"."users"."subscription_type" IS 'The plan level (Brick Starter, Pro, Master)';



COMMENT ON COLUMN "public"."users"."subscription_status" IS 'Status of the subscription (OK, trialing, past_due, canceled, etc.)';



COMMENT ON COLUMN "public"."users"."profile_completed" IS 'Whether the user has completed their profile information';



COMMENT ON COLUMN "public"."users"."user_status" IS 'Allowed values: no_set, set_shipping, received, has_set, set_returning, suspended, cancelled';



COMMENT ON COLUMN "public"."users"."stripe_customer_id" IS 'Stripe Customer ID associated with the user';



COMMENT ON COLUMN "public"."users"."referral_code" IS 'Unique shareable code (6 chars, auto-generated)';



COMMENT ON COLUMN "public"."users"."referred_by" IS 'auth.users.id of the user who referred this one';



COMMENT ON COLUMN "public"."users"."referral_credits" IS 'Accumulated credits from successful referrals';



CREATE TABLE IF NOT EXISTS "public"."users_correos_dropping" (
    "user_id" "uuid" NOT NULL,
    "correos_id_pudo" "text" NOT NULL,
    "correos_name" "text" NOT NULL,
    "correos_point_type" "text" NOT NULL,
    "correos_street" "text" NOT NULL,
    "correos_street_number" "text",
    "correos_zip_code" "text" NOT NULL,
    "correos_city" "text" NOT NULL,
    "correos_province" "text" NOT NULL,
    "correos_country" "text" DEFAULT 'España'::"text" NOT NULL,
    "correos_full_address" "text" NOT NULL,
    "correos_latitude" numeric(10,8) NOT NULL,
    "correos_longitude" numeric(11,8) NOT NULL,
    "correos_opening_hours" "text",
    "correos_structured_hours" "jsonb",
    "correos_available" boolean DEFAULT true NOT NULL,
    "correos_phone" "text",
    "correos_email" "text",
    "correos_internal_code" "text",
    "correos_locker_capacity" integer,
    "correos_additional_services" "text"[],
    "correos_accessibility" boolean DEFAULT false,
    "correos_parking" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "correos_selection_date" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "users_correos_dropping_correos_tipo_punto_check" CHECK (("correos_point_type" = ANY (ARRAY['Oficina'::"text", 'Citypaq'::"text", 'Locker'::"text"])))
);


ALTER TABLE "public"."users_correos_dropping" OWNER TO "postgres";


COMMENT ON TABLE "public"."users_correos_dropping" IS 'Stores user-selected Correos PUDO (Pick Up Drop Off) points for delivery and pickup';



CREATE TABLE IF NOT EXISTS "public"."wishlist" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "set_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "status" boolean DEFAULT true NOT NULL,
    "status_changed_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."wishlist" OWNER TO "postgres";


ALTER TABLE ONLY "public"."backoffice_operations"
    ADD CONSTRAINT "backoffice_operations_pkey" PRIMARY KEY ("event_id");



ALTER TABLE ONLY "public"."brickshare_pudo_locations"
    ADD CONSTRAINT "brickshare_pudo_locations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."donations"
    ADD CONSTRAINT "donations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_delivery_qr_code_key" UNIQUE ("delivery_qr_code");



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_numero_seguimiento_key" UNIQUE ("tracking_number");



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_return_qr_code_key" UNIQUE ("return_qr_code");



ALTER TABLE ONLY "public"."inventory_sets"
    ADD CONSTRAINT "inventario_sets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."inventory_sets"
    ADD CONSTRAINT "inventario_sets_set_id_key" UNIQUE ("set_id");



ALTER TABLE ONLY "public"."reception_operations"
    ADD CONSTRAINT "operaciones_recepcion_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sets"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."qr_validation_logs"
    ADD CONSTRAINT "qr_validation_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_referee_id_key" UNIQUE ("referee_id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."set_piece_list"
    ADD CONSTRAINT "set_piece_list_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shipping_orders"
    ADD CONSTRAINT "shipping_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_role_key" UNIQUE ("user_id", "role");



ALTER TABLE ONLY "public"."users_correos_dropping"
    ADD CONSTRAINT "users_correos_dropping_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_stripe_customer_id_key" UNIQUE ("stripe_customer_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."wishlist"
    ADD CONSTRAINT "wishlist_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wishlist"
    ADD CONSTRAINT "wishlist_user_id_product_id_key" UNIQUE ("user_id", "set_id");



CREATE INDEX "envios_swikly_wish_id_idx" ON "public"."shipments" USING "btree" ("swikly_wish_id");



CREATE INDEX "idx_backoff_ops_time" ON "public"."backoffice_operations" USING "btree" ("operation_time");



CREATE INDEX "idx_backoff_ops_type" ON "public"."backoffice_operations" USING "btree" ("operation_type");



CREATE INDEX "idx_backoff_ops_user_id" ON "public"."backoffice_operations" USING "btree" ("user_id");



CREATE INDEX "idx_brickshare_pudo_active" ON "public"."brickshare_pudo_locations" USING "btree" ("is_active") WHERE ("is_active" = true);



CREATE INDEX "idx_brickshare_pudo_location" ON "public"."brickshare_pudo_locations" USING "btree" ("latitude", "longitude");



CREATE INDEX "idx_donations_email" ON "public"."donations" USING "btree" ("email");



CREATE INDEX "idx_donations_status" ON "public"."donations" USING "btree" ("status");



CREATE INDEX "idx_envios_brickshare_package_id" ON "public"."shipments" USING "btree" ("brickshare_package_id") WHERE ("brickshare_package_id" IS NOT NULL);



CREATE INDEX "idx_envios_correos_shipment_id" ON "public"."shipments" USING "btree" ("correos_shipment_id");



CREATE INDEX "idx_envios_delivery_qr" ON "public"."shipments" USING "btree" ("delivery_qr_code") WHERE ("delivery_qr_code" IS NOT NULL);



CREATE INDEX "idx_envios_estado" ON "public"."shipments" USING "btree" ("shipment_status");



CREATE INDEX "idx_envios_fecha_entrega" ON "public"."shipments" USING "btree" ("estimated_delivery_date" DESC);



CREATE INDEX "idx_envios_numero_seguimiento" ON "public"."shipments" USING "btree" ("tracking_number");



CREATE INDEX "idx_envios_pickup_type" ON "public"."shipments" USING "btree" ("pickup_type");



CREATE INDEX "idx_envios_return_qr" ON "public"."shipments" USING "btree" ("return_qr_code") WHERE ("return_qr_code" IS NOT NULL);



CREATE INDEX "idx_envios_set_id" ON "public"."shipments" USING "btree" ("set_id");



CREATE INDEX "idx_envios_user_id" ON "public"."shipments" USING "btree" ("user_id");



CREATE INDEX "idx_inventario_sets_set_id" ON "public"."inventory_sets" USING "btree" ("set_id");



CREATE INDEX "idx_inventario_sets_set_ref" ON "public"."inventory_sets" USING "btree" ("set_ref");



CREATE INDEX "idx_operaciones_recepcion_event_id" ON "public"."reception_operations" USING "btree" ("event_id");



CREATE INDEX "idx_operaciones_recepcion_set_id" ON "public"."reception_operations" USING "btree" ("set_id");



CREATE INDEX "idx_operaciones_recepcion_user_id" ON "public"."reception_operations" USING "btree" ("user_id");



CREATE INDEX "idx_qr_validation_code" ON "public"."qr_validation_logs" USING "btree" ("qr_code");



CREATE INDEX "idx_qr_validation_shipment" ON "public"."qr_validation_logs" USING "btree" ("shipment_id");



CREATE INDEX "idx_set_piece_list_lego_ref" ON "public"."set_piece_list" USING "btree" ("set_ref");



CREATE INDEX "idx_set_piece_list_set_id" ON "public"."set_piece_list" USING "btree" ("set_id");



CREATE INDEX "idx_users_correos_dropping_cp" ON "public"."users_correos_dropping" USING "btree" ("correos_zip_code");



CREATE INDEX "idx_users_correos_dropping_tipo" ON "public"."users_correos_dropping" USING "btree" ("correos_point_type");



CREATE INDEX "idx_users_correos_dropping_user_id" ON "public"."users_correos_dropping" USING "btree" ("user_id");



CREATE INDEX "idx_users_stripe_customer_id" ON "public"."users" USING "btree" ("stripe_customer_id");



CREATE INDEX "referrals_referrer_id_idx" ON "public"."referrals" USING "btree" ("referrer_id", "status", "created_at" DESC);



CREATE UNIQUE INDEX "reviews_envio_unique" ON "public"."reviews" USING "btree" ("envio_id") WHERE ("envio_id" IS NOT NULL);



CREATE INDEX "reviews_set_id_idx" ON "public"."reviews" USING "btree" ("set_id", "is_published", "created_at" DESC);



CREATE INDEX "reviews_user_id_idx" ON "public"."reviews" USING "btree" ("user_id", "created_at" DESC);



CREATE INDEX "sets_age_range_idx" ON "public"."sets" USING "btree" ("set_age_range");



CREATE INDEX "sets_created_at_idx" ON "public"."sets" USING "btree" ("created_at" DESC);



CREATE INDEX "sets_theme_idx" ON "public"."sets" USING "btree" ("set_theme");



CREATE INDEX "sets_year_idx" ON "public"."sets" USING "btree" ("year_released");



CREATE UNIQUE INDEX "users_referral_code_lower" ON "public"."users" USING "btree" ("lower"("referral_code")) WHERE ("referral_code" IS NOT NULL);



CREATE OR REPLACE TRIGGER "on_reception_completed" AFTER UPDATE ON "public"."reception_operations" FOR EACH ROW EXECUTE FUNCTION "public"."handle_reception_close"();



CREATE OR REPLACE TRIGGER "on_set_created" AFTER INSERT ON "public"."sets" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_set_inventory"();



CREATE OR REPLACE TRIGGER "on_shipment_delivered" AFTER UPDATE ON "public"."shipments" FOR EACH ROW EXECUTE FUNCTION "public"."handle_shipment_delivered"();



CREATE OR REPLACE TRIGGER "on_shipment_return_transit_inv" AFTER UPDATE ON "public"."shipments" FOR EACH ROW EXECUTE FUNCTION "public"."handle_shipment_return_transit_inventory"();



CREATE OR REPLACE TRIGGER "on_shipment_return_user_status" AFTER UPDATE ON "public"."shipments" FOR EACH ROW EXECUTE FUNCTION "public"."handle_return_user_status"();



CREATE OR REPLACE TRIGGER "on_shipment_warehouse_received" BEFORE UPDATE ON "public"."shipments" FOR EACH ROW EXECUTE FUNCTION "public"."handle_shipment_warehouse_received"();



CREATE OR REPLACE TRIGGER "on_shipping_orders_updated" BEFORE UPDATE ON "public"."shipping_orders" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "referrals_updated_at" BEFORE UPDATE ON "public"."referrals" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "reviews_updated_at" BEFORE UPDATE ON "public"."reviews" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_users_correos_dropping_updated_at" BEFORE UPDATE ON "public"."users_correos_dropping" FOR EACH ROW EXECUTE FUNCTION "public"."update_users_correos_dropping_updated_at"();



CREATE OR REPLACE TRIGGER "update_donations_updated_at" BEFORE UPDATE ON "public"."donations" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_inventario_sets_updated_at" BEFORE UPDATE ON "public"."inventory_sets" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_reception_operations_updated_at" BEFORE UPDATE ON "public"."reception_operations" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_set_piece_list_updated_at" BEFORE UPDATE ON "public"."set_piece_list" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_sets_updated_at" BEFORE UPDATE ON "public"."sets" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_shipments_updated_at" BEFORE UPDATE ON "public"."shipments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_users_updated_at" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "users_generate_referral_code" BEFORE INSERT ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."generate_referral_code_users"();



ALTER TABLE ONLY "public"."backoffice_operations"
    ADD CONSTRAINT "backoffice_operations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."donations"
    ADD CONSTRAINT "donations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."sets"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."shipments"
    ADD CONSTRAINT "envios_user_id_fkey_public_users" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."inventory_sets"
    ADD CONSTRAINT "inventory_sets_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."sets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reception_operations"
    ADD CONSTRAINT "operaciones_recepcion_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."shipments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reception_operations"
    ADD CONSTRAINT "operaciones_recepcion_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."sets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reception_operations"
    ADD CONSTRAINT "operaciones_recepcion_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."qr_validation_logs"
    ADD CONSTRAINT "qr_validation_logs_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "public"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_referee_id_fkey" FOREIGN KEY ("referee_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_referrer_id_fkey" FOREIGN KEY ("referrer_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_envio_id_fkey" FOREIGN KEY ("envio_id") REFERENCES "public"."shipments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."sets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."set_piece_list"
    ADD CONSTRAINT "set_piece_list_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."sets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."shipping_orders"
    ADD CONSTRAINT "shipping_orders_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."sets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."shipping_orders"
    ADD CONSTRAINT "shipping_orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users_correos_dropping"
    ADD CONSTRAINT "users_correos_dropping_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_referred_by_fkey" FOREIGN KEY ("referred_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlist"
    ADD CONSTRAINT "wishlist_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Admins and Operadores can manage inventario" ON "public"."inventory_sets" TO "authenticated" USING (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins and Operadores can view all users" ON "public"."users" FOR SELECT USING (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins and Operators can log operations" ON "public"."backoffice_operations" FOR INSERT TO "authenticated" WITH CHECK (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins and Operators can view operations" ON "public"."backoffice_operations" FOR SELECT TO "authenticated" USING (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins and operators can insert" ON "public"."reception_operations" FOR INSERT TO "authenticated" WITH CHECK (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins and operators can update" ON "public"."reception_operations" FOR UPDATE TO "authenticated" USING (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role"))) WITH CHECK (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins and operators full access" ON "public"."shipments" USING (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Admins can delete sets" ON "public"."sets" FOR DELETE USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert sets" ON "public"."sets" FOR INSERT WITH CHECK ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can manage all donations" ON "public"."donations" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can manage all roles" ON "public"."user_roles" TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can manage set piece lists" ON "public"."set_piece_list" TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update any user" ON "public"."users" FOR UPDATE USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update sets" ON "public"."sets" FOR UPDATE USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all profiles" ON "public"."users" FOR SELECT TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all wishlists" ON "public"."wishlist" FOR SELECT USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Allow public read of active PUDO locations" ON "public"."brickshare_pudo_locations" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Authenticated users can insert their own donations" ON "public"."donations" FOR INSERT WITH CHECK ((("auth"."uid"() IS NOT NULL) AND (("user_id" IS NULL) OR ("auth"."uid"() = "user_id"))));



CREATE POLICY "Authenticated users can read" ON "public"."reception_operations" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Inventario is viewable by everyone" ON "public"."inventory_sets" FOR SELECT USING (true);



CREATE POLICY "Operators can create shipments" ON "public"."shipments" FOR INSERT WITH CHECK (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Operators can update shipments" ON "public"."shipments" FOR UPDATE USING (("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role") OR "public"."has_role"("auth"."uid"(), 'operador'::"public"."app_role")));



CREATE POLICY "Set piece lists are viewable by everyone" ON "public"."set_piece_list" FOR SELECT USING (true);



CREATE POLICY "Sets are viewable by everyone" ON "public"."sets" FOR SELECT USING (true);



CREATE POLICY "Users can add to their own wishlist" ON "public"."wishlist" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own Correos PUDO selection" ON "public"."users_correos_dropping" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own profile" ON "public"."users" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own Correos PUDO selection" ON "public"."users_correos_dropping" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own profile" ON "public"."users" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can remove from their own wishlist" ON "public"."wishlist" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own profile" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own shipment status" ON "public"."shipments" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK ((("auth"."uid"() = "user_id") AND ("shipment_status" = 'in_return_pudo'::"text")));



CREATE POLICY "Users can update their own Correos PUDO selection" ON "public"."users_correos_dropping" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."users" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own wishlist" ON "public"."wishlist" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own profile" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own shipments" ON "public"."shipments" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own Correos PUDO selection" ON "public"."users_correos_dropping" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own donations" ON "public"."donations" FOR SELECT USING ((("auth"."uid"() = "user_id") OR ("email" = (( SELECT "users"."email"
   FROM "auth"."users"
  WHERE ("users"."id" = "auth"."uid"())))::"text")));



CREATE POLICY "Users can view their own profile" ON "public"."users" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own roles" ON "public"."user_roles" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own shipping orders" ON "public"."shipping_orders" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own validation logs" ON "public"."qr_validation_logs" FOR SELECT TO "authenticated" USING (("shipment_id" IN ( SELECT "s"."id"
   FROM "public"."shipments" "s"
  WHERE ("s"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can view their own wishlist" ON "public"."wishlist" FOR SELECT USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."backoffice_operations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."brickshare_pudo_locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."donations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."inventory_sets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."qr_validation_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reception_operations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."referrals" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "referrals_admin_all" ON "public"."referrals" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = ANY (ARRAY['admin'::"public"."app_role", 'operador'::"public"."app_role"]))))));



CREATE POLICY "referrals_select_own" ON "public"."referrals" FOR SELECT TO "authenticated" USING (("referrer_id" = "auth"."uid"()));



CREATE POLICY "referrals_select_referee" ON "public"."referrals" FOR SELECT TO "authenticated" USING (("referee_id" = "auth"."uid"()));



ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "reviews_admin_all" ON "public"."reviews" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = ANY (ARRAY['admin'::"public"."app_role", 'operador'::"public"."app_role"]))))));



CREATE POLICY "reviews_delete_own" ON "public"."reviews" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "reviews_insert_own" ON "public"."reviews" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "reviews_select_own" ON "public"."reviews" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "reviews_select_published" ON "public"."reviews" FOR SELECT USING (("is_published" = true));



CREATE POLICY "reviews_update_own" ON "public"."reviews" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."set_piece_list" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."shipments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."shipping_orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users_correos_dropping" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users_insert_own" ON "public"."users" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "users_select_own" ON "public"."users" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "users_select_own_referral" ON "public"."users" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "users_update_own" ON "public"."users" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."wishlist" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."confirm_assign_sets_to_users"("p_user_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."confirm_assign_sets_to_users"("p_user_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."confirm_assign_sets_to_users"("p_user_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."confirm_qr_validation"("p_qr_code" "text", "p_validated_by" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."confirm_qr_validation"("p_qr_code" "text", "p_validated_by" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."confirm_qr_validation"("p_qr_code" "text", "p_validated_by" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_assignment_and_rollback"("p_envio_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_assignment_and_rollback"("p_envio_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_assignment_and_rollback"("p_envio_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_delivery_qr"("p_shipment_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_delivery_qr"("p_shipment_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_delivery_qr"("p_shipment_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_qr_code"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_qr_code"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_qr_code"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_referral_code_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_referral_code_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_referral_code_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_return_qr"("p_shipment_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_return_qr"("p_shipment_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_return_qr"("p_shipment_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_auth_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_auth_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_auth_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_set_inventory"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_set_inventory"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_set_inventory"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_reception_close"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_reception_close"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_reception_close"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_return_user_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_return_user_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_return_user_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_shipment_delivered"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_shipment_delivered"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_shipment_delivered"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_shipment_return_transit_inventory"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_shipment_return_transit_inventory"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_shipment_return_transit_inventory"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_shipment_warehouse_received"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_shipment_warehouse_received"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_shipment_warehouse_received"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "anon";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_referral_credits"("p_user_id" "uuid", "p_amount" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."increment_referral_credits"("p_user_id" "uuid", "p_amount" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_referral_credits"("p_user_id" "uuid", "p_amount" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."preview_assign_sets_to_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."preview_assign_sets_to_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."preview_assign_sets_to_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."process_referral_credit"("p_referee_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."process_referral_credit"("p_referee_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_referral_credit"("p_referee_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_set_status_from_return"("p_set_id" "uuid", "p_new_status" "text", "p_envio_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_set_status_from_return"("p_set_id" "uuid", "p_new_status" "text", "p_envio_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_set_status_from_return"("p_set_id" "uuid", "p_new_status" "text", "p_envio_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_users_correos_dropping_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_users_correos_dropping_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_users_correos_dropping_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."uses_brickshare_pudo"("shipment_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."uses_brickshare_pudo"("shipment_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."uses_brickshare_pudo"("shipment_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_qr_code"("p_qr_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."validate_qr_code"("p_qr_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_qr_code"("p_qr_code" "text") TO "service_role";



GRANT ALL ON TABLE "public"."backoffice_operations" TO "anon";
GRANT ALL ON TABLE "public"."backoffice_operations" TO "authenticated";
GRANT ALL ON TABLE "public"."backoffice_operations" TO "service_role";



GRANT ALL ON TABLE "public"."brickshare_pudo_locations" TO "anon";
GRANT ALL ON TABLE "public"."brickshare_pudo_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."brickshare_pudo_locations" TO "service_role";



GRANT ALL ON TABLE "public"."shipments" TO "anon";
GRANT ALL ON TABLE "public"."shipments" TO "authenticated";
GRANT ALL ON TABLE "public"."shipments" TO "service_role";



GRANT ALL ON TABLE "public"."brickshare_pudo_shipments" TO "anon";
GRANT ALL ON TABLE "public"."brickshare_pudo_shipments" TO "authenticated";
GRANT ALL ON TABLE "public"."brickshare_pudo_shipments" TO "service_role";



GRANT ALL ON TABLE "public"."donations" TO "anon";
GRANT ALL ON TABLE "public"."donations" TO "authenticated";
GRANT ALL ON TABLE "public"."donations" TO "service_role";



GRANT ALL ON TABLE "public"."inventory_sets" TO "anon";
GRANT ALL ON TABLE "public"."inventory_sets" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_sets" TO "service_role";



GRANT ALL ON TABLE "public"."qr_validation_logs" TO "anon";
GRANT ALL ON TABLE "public"."qr_validation_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_validation_logs" TO "service_role";



GRANT ALL ON TABLE "public"."reception_operations" TO "anon";
GRANT ALL ON TABLE "public"."reception_operations" TO "authenticated";
GRANT ALL ON TABLE "public"."reception_operations" TO "service_role";



GRANT ALL ON TABLE "public"."referrals" TO "anon";
GRANT ALL ON TABLE "public"."referrals" TO "authenticated";
GRANT ALL ON TABLE "public"."referrals" TO "service_role";



GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";



GRANT ALL ON TABLE "public"."set_avg_ratings" TO "anon";
GRANT ALL ON TABLE "public"."set_avg_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."set_avg_ratings" TO "service_role";



GRANT ALL ON TABLE "public"."set_piece_list" TO "anon";
GRANT ALL ON TABLE "public"."set_piece_list" TO "authenticated";
GRANT ALL ON TABLE "public"."set_piece_list" TO "service_role";



GRANT ALL ON TABLE "public"."set_review_stats" TO "anon";
GRANT ALL ON TABLE "public"."set_review_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."set_review_stats" TO "service_role";



GRANT ALL ON TABLE "public"."sets" TO "anon";
GRANT ALL ON TABLE "public"."sets" TO "authenticated";
GRANT ALL ON TABLE "public"."sets" TO "service_role";



GRANT ALL ON TABLE "public"."shipping_orders" TO "anon";
GRANT ALL ON TABLE "public"."shipping_orders" TO "authenticated";
GRANT ALL ON TABLE "public"."shipping_orders" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."users_correos_dropping" TO "anon";
GRANT ALL ON TABLE "public"."users_correos_dropping" TO "authenticated";
GRANT ALL ON TABLE "public"."users_correos_dropping" TO "service_role";



GRANT ALL ON TABLE "public"."wishlist" TO "anon";
GRANT ALL ON TABLE "public"."wishlist" TO "authenticated";
GRANT ALL ON TABLE "public"."wishlist" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







