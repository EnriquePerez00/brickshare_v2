-- Migration: Refactor PUDO system to support both Correos and Brickshare points
-- This creates a new table for Brickshare PUDOs and adds unified reference in users table

-- ============================================================================
-- 1. Create users_brickshare_dropping table
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users_brickshare_dropping (
    -- Primary key and user reference
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Brickshare PUDO Location reference
    brickshare_pudo_id TEXT NOT NULL REFERENCES public.brickshare_pudo_locations(id) ON DELETE RESTRICT,
    
    -- Location information (denormalized for performance)
    location_name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    province TEXT NOT NULL,
    
    -- Geolocation
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    
    -- Contact information
    contact_email TEXT,
    contact_phone TEXT,
    
    -- Operating hours (structured data)
    opening_hours JSONB,
    
    -- Timestamps
    selection_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 2. Add unified PUDO reference to users table
-- ============================================================================
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS pudo_id TEXT,
ADD COLUMN IF NOT EXISTS pudo_type TEXT CHECK (pudo_type IN ('correos', 'brickshare'));

-- ============================================================================
-- 3. Create indexes
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_brickshare_dropping_user_id 
ON public.users_brickshare_dropping(user_id);

CREATE INDEX IF NOT EXISTS idx_users_brickshare_dropping_location 
ON public.users_brickshare_dropping(brickshare_pudo_id);

CREATE INDEX IF NOT EXISTS idx_users_pudo_type 
ON public.users(pudo_type) WHERE pudo_type IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_users_pudo_id 
ON public.users(pudo_id) WHERE pudo_id IS NOT NULL;

-- ============================================================================
-- 4. Enable Row Level Security
-- ============================================================================
ALTER TABLE public.users_brickshare_dropping ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view only their own Brickshare PUDO selection
CREATE POLICY "Users can view their own Brickshare PUDO selection"
ON public.users_brickshare_dropping
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can insert their own Brickshare PUDO selection
CREATE POLICY "Users can insert their own Brickshare PUDO selection"
ON public.users_brickshare_dropping
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own Brickshare PUDO selection
CREATE POLICY "Users can update their own Brickshare PUDO selection"
ON public.users_brickshare_dropping
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own Brickshare PUDO selection
CREATE POLICY "Users can delete their own Brickshare PUDO selection"
ON public.users_brickshare_dropping
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================================================
-- 5. Create trigger to update updated_at timestamp
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_users_brickshare_dropping_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_users_brickshare_dropping_updated_at
    BEFORE UPDATE ON public.users_brickshare_dropping
    FOR EACH ROW
    EXECUTE FUNCTION public.update_users_brickshare_dropping_updated_at();

-- ============================================================================
-- 6. Create helper function to get user's active PUDO (regardless of type)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_user_active_pudo(p_user_id UUID)
RETURNS TABLE(
    pudo_type TEXT,
    pudo_id TEXT,
    pudo_name TEXT,
    pudo_address TEXT,
    pudo_city TEXT,
    pudo_postal_code TEXT
) AS $$
BEGIN
    -- Check users table for PUDO type
    RETURN QUERY
    SELECT 
        u.pudo_type,
        u.pudo_id,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_name
            WHEN u.pudo_type = 'brickshare' THEN b.location_name
            ELSE NULL
        END as pudo_name,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_full_address
            WHEN u.pudo_type = 'brickshare' THEN b.address
            ELSE NULL
        END as pudo_address,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_city
            WHEN u.pudo_type = 'brickshare' THEN b.city
            ELSE NULL
        END as pudo_city,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_zip_code
            WHEN u.pudo_type = 'brickshare' THEN b.postal_code
            ELSE NULL
        END as pudo_postal_code
    FROM public.users u
    LEFT JOIN public.users_correos_dropping c ON u.user_id = c.user_id AND u.pudo_type = 'correos'
    LEFT JOIN public.users_brickshare_dropping b ON u.user_id = b.user_id AND u.pudo_type = 'brickshare'
    WHERE u.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 7. Add comments
-- ============================================================================
COMMENT ON TABLE public.users_brickshare_dropping IS 'Stores user-selected Brickshare deposit locations for pickup/dropoff';
COMMENT ON COLUMN public.users.pudo_id IS 'Reference to the active PUDO point ID (either correos_id_pudo or brickshare_pudo_id)';
COMMENT ON COLUMN public.users.pudo_type IS 'Type of PUDO point currently selected by the user (correos or brickshare)';
COMMENT ON FUNCTION public.get_user_active_pudo IS 'Returns the active PUDO point information for a user regardless of type';