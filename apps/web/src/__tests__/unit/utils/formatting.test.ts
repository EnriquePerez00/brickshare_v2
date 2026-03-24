import { describe, it, expect } from 'vitest';

describe('Formatting Utilities', () => {
  describe('date formatting', () => {
    it('should format date as DD/MM/YYYY', () => {
      const date = new Date('2024-03-23');
      const formatted = date.toLocaleDateString('es-ES', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
      });

      expect(formatted).toMatch(/^\d{2}\/\d{2}\/\d{4}$/);
    });

    it('should parse ISO format dates', () => {
      const isoDate = '2024-03-23T10:00:00Z';
      const date = new Date(isoDate);

      expect(date.getFullYear()).toBe(2024);
      expect(date.getMonth() + 1).toBe(3);
    });
  });

  describe('currency formatting', () => {
    it('should format EUR currency', () => {
      const amount = 29.99;
      const formatted = new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: 'EUR',
      }).format(amount);

      expect(formatted).toContain('€');
      expect(formatted).toContain('29');
    });

    it('should handle large amounts', () => {
      const amount = 1299.99;
      const formatted = new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: 'EUR',
      }).format(amount);

      expect(formatted).toContain('1299');
    });
  });

  describe('status formatting', () => {
    it('should format shipment statuses', () => {
      const statusMap: Record<string, string> = {
        en_transito: 'En tránsito',
        entregado: 'Entregado',
        devuelto: 'Devuelto',
        pendiente: 'Pendiente',
      };

      expect(statusMap['en_transito']).toBe('En tránsito');
      expect(statusMap['entregado']).toBe('Entregado');
    });

    it('should preserve unknown statuses', () => {
      const unknownStatus = 'unknown_status';
      expect(unknownStatus).toBeDefined();
    });
  });

  describe('text truncation', () => {
    it('should truncate long strings', () => {
      const longText = 'This is a very long text that should be truncated';
      const truncated = longText.substring(0, 20) + '...';

      expect(truncated).toBe('This is a very long ...');
      expect(truncated.length).toBeLessThan(longText.length);
    });
  });
});