-- Migration: Create shipment update logs table for audit trail
-- Description: Track all updates to shipments table via external logistics API
-- Date: 2025-03-25

-- Create shipment_update_logs table
CREATE TABLE IF NOT EXISTS public.shipment_update_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES public.shipments(id) ON DELETE CASCADE,
  updated_by TEXT NOT NULL, -- 'admin', 'logistics_api', 'user', 'system'
  updated_fields TEXT[] NOT NULL, -- Array of field names that were updated
  old_values JSONB, -- Previous values before update
  new_values JSONB NOT NULL, -- New values after update
  source_ip TEXT, -- IP address of the requester (if available)
  user_agent TEXT, -- User agent string (if available)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for efficient queries by shipment_id
CREATE INDEX idx_shipment_update_logs_shipment_id 
  ON public.shipment_update_logs(shipment_id, created_at DESC);

-- Create index for queries by updated_by
CREATE INDEX idx_shipment_update_logs_updated_by 
  ON public.shipment_update_logs(updated_by, created_at DESC);

-- Create index for queries by created_at
CREATE INDEX idx_shipment_update_logs_created_at 
  ON public.shipment_update_logs(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.shipment_update_logs ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read their own shipment logs
CREATE POLICY "Users can view logs for their own shipments"
  ON public.shipment_update_logs
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.shipments
      WHERE shipments.id = shipment_update_logs.shipment_id
      AND shipments.user_id = auth.uid()
    )
  );

-- Policy: Allow admins and operators to view all logs
CREATE POLICY "Admins and operators can view all logs"
  ON public.shipment_update_logs
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role IN ('admin', 'operador')
    )
  );

-- Policy: Service role can insert logs (used by Edge Functions)
CREATE POLICY "Service role can insert logs"
  ON public.shipment_update_logs
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Add comment to table
COMMENT ON TABLE public.shipment_update_logs IS 'Audit log for all shipment updates via logistics API and admin panel';

-- Add comments to columns
COMMENT ON COLUMN public.shipment_update_logs.updated_by IS 'Source of the update: admin, logistics_api, user, or system';
COMMENT ON COLUMN public.shipment_update_logs.updated_fields IS 'Array of field names that were modified in this update';
COMMENT ON COLUMN public.shipment_update_logs.old_values IS 'JSONB snapshot of field values before the update';
COMMENT ON COLUMN public.shipment_update_logs.new_values IS 'JSONB snapshot of field values after the update';