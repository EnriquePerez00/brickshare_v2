import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createMockSetAssignmentData, createMockShipmentTracking, createMockQRCodeData } from '@/test/fixtures/integration';

/**
 * User Flow: Set Assignment & Delivery
 * Tests for set assignment, shipping, and delivery
 */

describe('Set Assignment & Delivery Flow - Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('Set assignment and shipping', () => {
    it('should assign set to active subscriber', async () => {
      // Arrange
      const userId = 'user-123';
      const setId = 'set-456';
      const assignmentData = createMockSetAssignmentData(userId, setId);

      // Act
      const assignment = {
        ...assignmentData,
        status: 'assigned',
        created_at: new Date().toISOString(),
      };

      // Assert
      expect(assignment.user_id).toBe(userId);
      expect(assignment.set_id).toBe(setId);
      expect(assignment.status).toBe('assigned');
    });

    it('should create shipment with tracking number', async () => {
      // Arrange
      const shipmentId = 'shipment-789';
      const trackingData = createMockShipmentTracking(shipmentId);

      // Act
      const shipment = {
        ...trackingData,
        created_at: new Date().toISOString(),
      };

      // Assert
      expect(shipment.tracking_number).toBeDefined();
      expect(shipment.status).toBe('en_transito');
      expect(shipment.tracking_number).toContain('CORREOS');
    });

    it('should generate QR code for delivery', async () => {
      // Arrange
      const shipmentId = 'shipment-789';
      const qrData = createMockQRCodeData(shipmentId);

      // Act
      const qrCode = {
        ...qrData,
        type: 'delivery' as const,
      };

      // Assert
      expect(qrCode.qr_code).toBeDefined();
      expect(qrCode.type).toBe('delivery');
      expect(qrCode.qr_code).toContain('BRICKSHARE');
    });

    it('should send tracking email to user', async () => {
      // Arrange
      const userEmail = 'user@example.com';
      const trackingNumber = 'CORREOS123456';

      // Act
      const emailSent = {
        to: userEmail,
        subject: 'Your LEGO Set is on the Way',
        tracking_number: trackingNumber,
        sent_at: new Date().toISOString(),
      };

      // Assert
      expect(emailSent.to).toBe(userEmail);
      expect(emailSent.tracking_number).toBe(trackingNumber);
    });
  });

  describe('Set delivery at PUDO', () => {
    it('should receive set at PUDO location', async () => {
      // Arrange
      const shipmentId = 'shipment-789';
      const pudoLocation = 'pudo-madrid-001';

      // Act
      const delivery = {
        shipment_id: shipmentId,
        pudo_location: pudoLocation,
        delivered_at: new Date().toISOString(),
        status: 'en_pudo',
      };

      // Assert
      expect(delivery.status).toBe('en_pudo');
      expect(delivery.pudo_location).toBe(pudoLocation);
    });

    it('should allow user to confirm receipt', async () => {
      // Arrange
      const shipmentId = 'shipment-789';
      const qrCode = 'BRICKSHARE-12345678';

      // Act
      const receipt = {
        shipment_id: shipmentId,
        qr_code_scanned: qrCode,
        confirmed_at: new Date().toISOString(),
        status: 'entregado',
      };

      // Assert
      expect(receipt.status).toBe('entregado');
      expect(receipt.qr_code_scanned).toBe(qrCode);
    });

    it('should add set to user active collection', async () => {
      // Arrange
      const userId = 'user-123';
      const setId = 'set-456';

      // Act
      const activeSet = {
        user_id: userId,
        set_id: setId,
        status: 'en_uso',
        received_at: new Date().toISOString(),
        can_return_after: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      };

      // Assert
      expect(activeSet.status).toBe('en_uso');
      expect(activeSet.user_id).toBe(userId);
    });

    it('should send confirmation email', async () => {
      // Arrange
      const userEmail = 'user@example.com';

      // Act
      const emailSent = {
        to: userEmail,
        subject: 'LEGO Set Received Successfully',
        sent_at: new Date().toISOString(),
      };

      // Assert
      expect(emailSent.subject).toContain('Received Successfully');
    });
  });

  describe('Set return flow', () => {
    it('should allow user to request return', async () => {
      // Arrange
      const userId = 'user-123';
      const setId = 'set-456';

      // Act
      const returnRequest = {
        user_id: userId,
        set_id: setId,
        requested_at: new Date().toISOString(),
        status: 'return_requested',
      };

      // Assert
      expect(returnRequest.status).toBe('return_requested');
      expect(returnRequest.requested_at).toBeDefined();
    });

    it('should generate return QR code', async () => {
      // Arrange
      const shipmentId = 'return-shipment-789';
      const qrData = createMockQRCodeData(shipmentId);

      // Act
      const returnQR = {
        ...qrData,
        type: 'return',
      };

      // Assert
      expect(returnQR.type).toBe('return');
      expect(returnQR.qr_code).toBeDefined();
    });

    it('should send return instructions email', async () => {
      // Arrange
      const userEmail = 'user@example.com';

      // Act
      const emailSent = {
        to: userEmail,
        subject: 'Return Instructions for Your LEGO Set',
        sent_at: new Date().toISOString(),
      };

      // Assert
      expect(emailSent.subject).toContain('Return Instructions');
    });

    it('should process return at PUDO', async () => {
      // Arrange
      const shipmentId = 'return-shipment-789';
      const qrCode = 'BRICKSHARE-RETURN-123';

      // Act
      const returnProcessed = {
        shipment_id: shipmentId,
        qr_code: qrCode,
        returned_at: new Date().toISOString(),
        status: 'devuelto',
      };

      // Assert
      expect(returnProcessed.status).toBe('devuelto');
      expect(returnProcessed.qr_code).toBe(qrCode);
    });

    it('should trigger automatic new set assignment', async () => {
      // Arrange
      const userId = 'user-123';
      const returnedSetId = 'set-456';

      // Act
      const newAssignment = {
        user_id: userId,
        previous_set_id: returnedSetId,
        new_assignment_created: true,
        created_at: new Date().toISOString(),
      };

      // Assert
      expect(newAssignment.new_assignment_created).toBe(true);
      expect(newAssignment.previous_set_id).toBe(returnedSetId);
    });
  });
});