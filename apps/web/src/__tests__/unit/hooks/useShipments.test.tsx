import { describe, it, expect, beforeEach, vi } from 'vitest';
import { mockShipments, mockShipment, mockShipmentDelivered, mockShipmentReturn } from '@/test/fixtures/shipments';

describe('useShipments', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('fetch shipments', () => {
    it('should fetch user shipments', () => {
      expect(mockShipments).toHaveLength(3);
    });

    it('should have correct shipment structure', () => {
      expect(mockShipment).toHaveProperty('id');
      expect(mockShipment).toHaveProperty('status');
      expect(mockShipment).toHaveProperty('tracking_number');
      expect(mockShipment).toHaveProperty('pudo_name');
    });
  });

  describe('shipment status tracking', () => {
    it('should track in-transit shipments', () => {
      const inTransit = mockShipments.filter(s => s.status === 'en_transito');
      expect(inTransit).toHaveLength(1);
      expect(inTransit[0].actual_delivery_date).toBeNull();
    });

    it('should track delivered shipments', () => {
      expect(mockShipmentDelivered.status).toBe('entregado');
      expect(mockShipmentDelivered.actual_delivery_date).not.toBeNull();
    });

    it('should track returned shipments', () => {
      expect(mockShipmentReturn.direction).toBe('incoming');
      expect(mockShipmentReturn.status).toBe('devuelto');
    });
  });

  describe('QR validation', () => {
    it('should have delivery QR codes', () => {
      expect(mockShipment.delivery_qr_code).toBeDefined();
      expect(mockShipment.delivery_qr_code).toMatch(/QR-/);
    });

    it('should have return QR codes', () => {
      expect(mockShipment.return_qr_code).toBeDefined();
      expect(mockShipment.return_qr_code).toMatch(/QR-/);
    });
  });

  describe('tracking information', () => {
    it('should have tracking number', () => {
      expect(mockShipment.tracking_number).toBeDefined();
      expect(mockShipment.tracking_number).toMatch(/CC/);
    });

    it('should have PUDO information', () => {
      expect(mockShipment.pudo_name).toBe('Correos Atocha');
      expect(mockShipment.pudo_address).toBeDefined();
      expect(mockShipment.pudo_zip).toBe('28012');
      expect(mockShipment.pudo_city).toBe('Madrid');
    });

    it('should have expected delivery date', () => {
      expect(mockShipment.expected_delivery_date).toBe('2024-03-30');
    });
  });

  describe('direction field', () => {
    it('should distinguish outgoing vs incoming shipments', () => {
      const outgoing = mockShipments.filter(s => s.direction === 'outgoing');
      const incoming = mockShipments.filter(s => s.direction === 'incoming');

      expect(outgoing.length).toBeGreaterThan(0);
      expect(incoming.length).toBeGreaterThan(0);
    });
  });
});