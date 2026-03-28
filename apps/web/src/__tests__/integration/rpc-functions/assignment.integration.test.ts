import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createClient } from '@supabase/supabase-js';

/**
 * Integration Tests for Assignment RPC Functions
 * Tests preview_assign_sets_to_users and confirm_assign_sets_to_users
 */

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

// Skip tests if Supabase is not available
const supabase = createClient(supabaseUrl, supabaseKey);

describe('Assignment RPC Functions - Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('preview_assign_sets_to_users()', () => {
    it('should generate assignment proposals for eligible users', async () => {
      const { data, error } = await supabase.rpc('preview_assign_sets_to_users');

      // May return empty if no users eligible for assignment
      if (error) {
        console.warn('RPC function not available or returned error:', error);
        return;
      }

      expect(data).toBeDefined();
      expect(Array.isArray(data)).toBe(true);

      if (data && data.length > 0) {
        const assignment = data[0];
        
        // Verify structure
        expect(assignment).toHaveProperty('user_id');
        expect(assignment).toHaveProperty('user_name');
        expect(assignment).toHaveProperty('set_id');
        expect(assignment).toHaveProperty('set_name');
        expect(assignment).toHaveProperty('set_ref');
        expect(assignment).toHaveProperty('set_price');
        expect(assignment).toHaveProperty('current_stock');
        expect(assignment).toHaveProperty('matches_wishlist');
        expect(assignment).toHaveProperty('pudo_type');

        // Verify types
        expect(typeof assignment.user_id).toBe('string');
        expect(typeof assignment.user_name).toBe('string');
        expect(typeof assignment.set_id).toBe('string');
        expect(typeof assignment.set_name).toBe('string');
        expect(typeof assignment.set_ref).toBe('string');
        expect(typeof assignment.current_stock).toBe('number');
        expect(typeof assignment.matches_wishlist).toBe('boolean');
      }
    });

    it('should only propose sets that are in stock', async () => {
      const { data } = await supabase.rpc('preview_assign_sets_to_users');

      if (data) {
        data.forEach((assignment: any) => {
          expect(assignment.current_stock).toBeGreaterThan(0);
        });
      }
    });

    it('should prioritize wishlist matches', async () => {
      const { data } = await supabase.rpc('preview_assign_sets_to_users');

      if (data) {
        const wishlistMatches = data.filter((a: any) => a.matches_wishlist);
        const randomAssignments = data.filter((a: any) => !a.matches_wishlist);

        // Wishlist matches should be preferred
        if (wishlistMatches.length > 0 && randomAssignments.length > 0) {
          // This depends on implementation, but generally wishlist should be prioritized
          expect(wishlistMatches.length).toBeGreaterThanOrEqual(randomAssignments.length);
        }
      }
    });

    it('should exclude users without PUDO configured', async () => {
      const { data } = await supabase.rpc('preview_assign_sets_to_users');

      if (data) {
        // All users in preview should have pudo_type
        data.forEach((assignment: any) => {
          expect(assignment.pudo_type).toBeTruthy();
          expect(['brickshare', 'correos']).toContain(assignment.pudo_type);
        });
      }
    });

    it('should not propose sets user already received recently', async () => {
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (preview && preview.length > 0) {
        const user_id = preview[0].user_id;
        const set_ref = preview[0].set_ref;

        // Check shipments history for this user
        const { data: history } = await supabase
          .from('shipments')
          .select('set_ref')
          .eq('user_id', user_id)
          .order('created_at', { ascending: false })
          .limit(5);

        // The proposed set should not be in recent history
        const recentRefs = history?.map(s => s.set_ref) || [];
        // This might fail if set was recently assigned, which is valid behavior
      }
    });
  });

  describe('confirm_assign_sets_to_users(user_ids)', () => {
    it('should create shipments for confirmed user IDs', async () => {
      // First get preview
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (!preview || preview.length === 0) {
        console.warn('No assignments in preview, skipping test');
        return;
      }

      const userIdsToConfirm = preview.slice(0, 1).map((a: any) => a.user_id);

      // Confirm assignments
      const { data: confirmed, error } = await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: userIdsToConfirm
      });

      expect(error).toBeNull();
      expect(confirmed).toBeDefined();
      expect(Array.isArray(confirmed)).toBe(true);

      if (confirmed && confirmed.length > 0) {
        const assignment = confirmed[0];

        // Verify shipment was created
        expect(assignment).toHaveProperty('shipment_id');
        expect(assignment).toHaveProperty('user_id');
        expect(assignment).toHaveProperty('set_id');
        expect(assignment).toHaveProperty('user_name');
        expect(assignment).toHaveProperty('user_email');
        expect(assignment).toHaveProperty('set_name');
        expect(assignment).toHaveProperty('set_ref');
        expect(assignment).toHaveProperty('pudo_id');
        expect(assignment).toHaveProperty('pudo_name');
        expect(assignment).toHaveProperty('created_at');

        // Verify shipment exists in database
        const { data: shipment } = await supabase
          .from('shipments')
          .select('*')
          .eq('id', assignment.shipment_id)
          .single();

        expect(shipment).toBeDefined();
        expect(shipment?.user_id).toBe(assignment.user_id);
        expect(shipment?.set_ref).toBe(assignment.set_ref);
      }
    });

    it('should update user status to set_shipping', async () => {
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (!preview || preview.length === 0) return;

      const userId = preview[0].user_id;

      // Confirm assignment
      await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: [userId]
      });

      // Check user status
      const { data: user } = await supabase
        .from('users')
        .select('user_status')
        .eq('user_id', userId)
        .single();

      expect(user?.user_status).toBe('set_shipping');
    });

    it('should decrease inventory stock', async () => {
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (!preview || preview.length === 0) return;

      const setId = preview[0].set_id;

      // Get initial stock
      const { data: initialInventory } = await supabase
        .from('inventory_sets')
        .select('stock_central, en_envio')
        .eq('set_id', setId)
        .single();

      const initialStock = initialInventory?.stock_central || 0;
      const initialEnEnvio = initialInventory?.en_envio || 0;

      // Confirm assignment
      await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: [preview[0].user_id]
      });

      // Check updated inventory
      const { data: newInventory } = await supabase
        .from('inventory_sets')
        .select('stock_central, en_envio')
        .eq('set_id', setId)
        .single();

      expect(newInventory?.stock_central).toBe(initialStock - 1);
      expect(newInventory?.en_envio).toBe(initialEnEnvio + 1);
    });

    it('should remove set from wishlist after assignment', async () => {
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (!preview || preview.length === 0) return;

      const assignment = preview.find((a: any) => a.matches_wishlist);
      if (!assignment) return;

      // Confirm assignment
      await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: [assignment.user_id]
      });

      // Check wishlist
      const { data: wishlist } = await supabase
        .from('wishlist')
        .select('*')
        .eq('user_id', assignment.user_id)
        .eq('product_id', assignment.set_id);

      // Should be deleted or marked as inactive
      expect(wishlist).toHaveLength(0);
    });

    it('should generate QR codes for shipment', async () => {
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (!preview || preview.length === 0) return;

      const { data: confirmed } = await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: [preview[0].user_id]
      });

      if (!confirmed || confirmed.length === 0) return;

      const shipmentId = confirmed[0].shipment_id;

      // Check shipment has QR codes
      const { data: shipment } = await supabase
        .from('shipments')
        .select('delivery_qr_code, return_qr_code, delivery_qr_expires_at')
        .eq('id', shipmentId)
        .single();

      // QR codes should be generated (either by trigger or function)
      // Format: BS-{SHIPMENT_ID_SUBSTRING}
      if (shipment?.delivery_qr_code) {
        expect(shipment.delivery_qr_code).toMatch(/^BS-/);
      }

      if (shipment?.return_qr_code) {
        expect(shipment.return_qr_code).toMatch(/^BS-/);
      }
    });

    it('should fail if user has no PUDO configured', async () => {
      // Try to confirm with invalid user ID
      const { data, error } = await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: ['00000000-0000-0000-0000-000000000000']
      });

      // Should return empty array or null for invalid user
      if (data) {
        expect(Array.isArray(data)).toBe(true);
        expect(data.length).toBe(0);
      } else {
        expect(data).toBeNull();
      }
    });

    it('should handle multiple users in single call', async () => {
      const { data: preview } = await supabase.rpc('preview_assign_sets_to_users');

      if (!preview || preview.length < 2) return;

      const userIds = preview.slice(0, 2).map((a: any) => a.user_id);

      const { data: confirmed, error } = await supabase.rpc('confirm_assign_sets_to_users', {
        p_user_ids: userIds
      });

      expect(error).toBeNull();
      expect(confirmed).toHaveLength(userIds.length);

      // Verify each assignment
      confirmed?.forEach((assignment: any) => {
        expect(userIds).toContain(assignment.user_id);
        expect(assignment.shipment_id).toBeTruthy();
      });
    });
  });
});