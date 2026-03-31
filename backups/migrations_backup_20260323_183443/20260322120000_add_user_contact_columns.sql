-- Add missing contact/address columns to users table
-- These columns are needed by the ProfileCompletionModal and match the TypeScript types

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS address text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS address_extra text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS zip_code text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS city text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS province text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS phone text;
