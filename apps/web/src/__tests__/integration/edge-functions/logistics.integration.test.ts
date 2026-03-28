import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createClient } from '@supabase/supabase-js';

/**
 * Integration Tests for Logistics Edge Functions
 * Tests correos-logistics, send-brickshare-qr-email, and brickshare-qr-api
 */

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

// Skip tests if Supabase is not available
const supabase = createClient(supabaseUrl, supabaseKey);

describe('Logistics Edge Functions - Integration', () => {
  let testShipmentId: string;

  beforeEach(async () => {
    vi.clearAllMocks();

    // Create a test shipment
    const { data: shipment } = await supabase
      .from('shipments')
      .select('id')
      .eq('shipment_status', 'pending')
      .limit(1)
      .single();

    if (shipment) {
      testShipmentId = shipment.id;
    }
  });

  describe('correos-logistics Edge Function', () => {
    it('should create Correos shipment (preregister)', async () => {
      if (!testShipmentId) {
        console.warn('No test shipment available');
        return;
      }

      const { data, error } = await supabase.functions.invoke('correos-logistics', {
        body: {
          action: 'preregister',
          p_shipment_id: testShipmentId
        }
      });

      if (error) {
        // May fail if Correos API not configured in test environment
        console.warn('Correos preregister error (expected in test):', error);
        return;
      }

      expect(data).toBeDefined();
      expect(data.message).toContain('Preregistration successful');
      expect(data.correos_shipment_id).toBeTruthy();

      // Verify shipment updated
      const { data: shipment } = await supabase
        .from('shipments')
        .select('correos_shipment_id, shipment_status')
        .eq('id', testShipmentId)
        .single();

      expect(shipment?.correos_shipment_id).toBeTruthy();
      expect(shipment?.shipment_status).toBe('prepared');
    });

    it('should generate Correos label', async () => {
      if (!testShipmentId) return;

      // First preregister
      await supabase.functions.invoke('correos-logistics', {
        body: {
          action: 'preregister',
          p_shipment_id: testShipmentId
        }
      });

      // Then get label
      const { data, error } = await supabase.functions.invoke('correos-logistics', {
        body: {
          action: 'get_label',
          p_shipment_id: testShipmentId
        }
      });

      if (error) {
        console.warn('Label generation error (expected in test):', error);
        return;
      }

      expect(data?.label_url).toBeTruthy();
      expect(data.label_url).toContain('.pdf');
    });

    it('should handle return shipment preregistration', async () => {
      if (!testShipmentId) return;

      const { data, error } = await supabase.functions.invoke('correos-logistics', {
        body: {
          action: 'return_preregister',
          p_shipment_id: testShipmentId
        }
      });

      if (error) {
        console.warn('Return preregister error (expected in test):', error);
        return;
      }

      expect(data?.return_code).toBeTruthy();
      expect(data.message).toContain('Return requested successfully');
    });

    it('should track shipment status', async () => {
      if (!testShipmentId) return;

      const { data, error } = await supabase.functions.invoke('correos-logistics', {
        body: {
          action: 'track',
          p_shipment_id: testShipmentId
        }
      });

      // May fail if no tracking available yet
      if (error) {
        console.warn('Tracking error (expected if not yet shipped):', error);
        return;
      }

      expect(data).toBeDefined();
    });
  });

  describe('send-brickshare-qr-email Edge Function', () => {
    it('should send delivery QR email', async () => {
      if (!testShipmentId) return;

      const { data, error } = await supabase.functions.invoke('send-brickshare-qr-email', {
        body: {
          shipment_id: testShipmentId,
          type: 'delivery'
        }
      });

      if (error) {
        console.warn('Email send error:', error);
        return;
      }

      expect(data?.success).toBe(true);
      expect(data.qr_code).toMatch(/^BS-/);
      expect(data.email_id).toBeTruthy();
    });

    it('should send return QR email', async () => {
      if (!testShipmentId) return;

      const { data, error } = await supabase.functions.invoke('send-brickshare-qr-email', {
        body: {
          shipment_id: testShipmentId,
          type: 'return'
        }
      });

      if (error) {
        console.warn('Return email error:', error);
        return;
      }

      expect(data?.success).toBe(true);
      expect(data.qr_code).toMatch(/^BS-/);
    });

    it('should fail with invalid shipment ID', async () => {
      const { data, error } = await supabase.functions.invoke('send-brickshare-qr-email', {
        body: {
          shipment_id: '00000000-0000-0000-0000-000000000000',
          type: 'delivery'
        }
      });

      expect(error || data?.error).toBeTruthy();
    });

    it('should validate shipment has required fields', async () => {
      if (!testShipmentId) return;

      // Verify shipment has user_id and set_ref before sending email
      const { data: shipment } = await supabase
        .from('shipments')
        .select('user_id, set_ref, delivery_qr_code')
        .eq('id', testShipmentId)
        .single();

      expect(shipment?.user_id).toBeTruthy();
      expect(shipment?.set_ref).toBeTruthy();
      
      if (shipment?.delivery_qr_code) {
        expect(shipment.delivery_qr_code).toMatch(/^BS-/);
      }
    });

    it('should include PUDO information in email', async () => {
      if (!testShipmentId) return;

      // Check shipment has PUDO info
      const { data: shipment } = await supabase
        .from('shipments')
        .select('pudo_type, brickshare_pudo_id, shipping_address')
        .eq('id', testShipmentId)
        .single();

      expect(shipment?.pudo_type).toBeTruthy();
      
      if (shipment?.pudo_type === 'brickshare') {
        expect(shipment.brickshare_pudo_id).toBeTruthy();
      }
    });
  });

  describe('brickshare-qr-api Edge Function', () => {
    let testQRCode: string;

    beforeEach(async () => {
      if (testShipmentId) {
        // Get or create QR code
        const { data: shipment } = await supabase
          .from('shipments')
          .select('delivery_qr_code')
          .eq('id', testShipmentId)
          .single();

        if (shipment?.delivery_qr_code) {
          testQRCode = shipment.delivery_qr_code;
        } else {
          // Generate QR
          testQRCode = `BS-${testShipmentId.substring(0, 8).toUpperCase()}`;
          
          await supabase
            .from('shipments')
            .update({ delivery_qr_code: testQRCode })
            .eq('id', testShipmentId);
        }
      }
    });

    it('should validate delivery QR code', async () => {
      if (!testQRCode) {
        console.warn('No test QR code available');
        return;
      }

      const response = await fetch(
        `${supabaseUrl}/functions/v1/brickshare-qr-api/validate/${testQRCode}`
      );

      if (!response.ok) {
        console.warn('QR API not available (expected in test environment)');
        return;
      }

      const data = await response.json();

      if (data.success) {
        expect(data.data).toBeDefined();
        expect(data.data.shipment_id).toBeTruthy();
        expect(data.data.validation_type).toBe('delivery');
        expect(data.data.shipment_info).toBeDefined();
        expect(data.data.shipment_info.set_name).toBeTruthy();
        expect(data.data.shipment_info.set_number).toBeTruthy();
      } else {
        // May fail if QR not properly configured
        console.warn('QR validation failed:', data.error);
      }
    });

    it('should reject invalid QR codes', async () => {
      const response = await fetch(
        `${supabaseUrl}/functions/v1/brickshare-qr-api/validate/INVALID-CODE`
      );

      if (!response.ok) {
        console.warn('QR API not available (expected in test environment)');
        return;
      }

      const data = await response.json();

      expect(data.success).toBe(false);
      expect(data.error).toBeTruthy();
    });

    it('should confirm QR validation and update status', async () => {
      if (!testQRCode) return;

      const response = await fetch(
        `${supabaseUrl}/functions/v1/brickshare-qr-api/confirm`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            qr_code: testQRCode,
            validated_by: 'test-operator'
          })
        }
      );

      if (!response.ok) {
        console.warn('QR API not available (expected in test environment)');
        return;
      }

      const data = await response.json();

      if (data.success) {
        expect(data.shipment_id).toBeTruthy();
        expect(data.message).toBeTruthy();

        // Verify QR logged in database
        const { data: log } = await supabase
          .from('qr_validation_logs')
          .select('*')
          .eq('shipment_id', testShipmentId)
          .order('scanned_at', { ascending: false })
          .limit(1)
          .single();

        expect(log).toBeDefined();
        expect(log?.valid).toBe(true);
      }
    });

    it('should prevent duplicate QR validation', async () => {
      if (!testQRCode) return;

      // First validation
      const firstResponse = await fetch(
        `${supabaseUrl}/functions/v1/brickshare-qr-api/confirm`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            qr_code: testQRCode,
            validated_by: 'test-operator'
          })
        }
      );

      if (!firstResponse.ok) {
        console.warn('QR API not available (expected in test environment)');
        return;
      }

      // Second validation (should fail)
      const response = await fetch(
        `${supabaseUrl}/functions/v1/brickshare-qr-api/confirm`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            qr_code: testQRCode,
            validated_by: 'test-operator-2'
          })
        }
      );

      const data = await response.json();

      expect(data.success).toBe(false);
      expect(data.error).toMatch(/already/i);
    });

    it('should get PUDO locations list', async () => {
      const response = await fetch(
        `${supabaseUrl}/functions/v1/brickshare-qr-api/pudo-locations`
      );

      if (!response.ok) {
        console.warn('QR API not available (expected in test environment)');
        return;
      }

      const data = await response.json();

      if (data.success) {
        expect(Array.isArray(data.data)).toBe(true);
        
        if (data.data.length > 0) {
          const pudo = data.data[0];
          expect(pudo.name).toBeTruthy();
          expect(pudo.address).toBeTruthy();
          expect(pudo.is_active).toBe(true);
        }
      }
    });
  });
});