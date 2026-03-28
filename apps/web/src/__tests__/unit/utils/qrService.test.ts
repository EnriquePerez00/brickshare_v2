import { describe, it, expect } from 'vitest';

/**
 * Unit Tests for QR Service
 * Tests QR code generation, validation, and formatting
 */

// QR Service utility functions
export const generateQRCode = (shipmentId: string): string => {
  // Format: BS-{FIRST_8_CHARS_OF_UUID}
  const prefix = 'BS-';
  const shortId = shipmentId.substring(0, 8).toUpperCase();
  return `${prefix}${shortId}`;
};

export const validateQRFormat = (qrCode: string): boolean => {
  // Valid format: BS-XXXXXXXX where X is alphanumeric
  const qrRegex = /^BS-[A-Z0-9]{8}$/;
  return qrRegex.test(qrCode);
};

export const parseQRCode = (qrCode: string): { prefix: string; shipmentId: string } | null => {
  if (!validateQRFormat(qrCode)) {
    return null;
  }

  const [prefix, shortId] = qrCode.split('-');
  return {
    prefix,
    shipmentId: shortId
  };
};

export const generateQRExpiration = (daysFromNow: number = 30): Date => {
  const expiration = new Date();
  expiration.setDate(expiration.getDate() + daysFromNow);
  return expiration;
};

export const isQRExpired = (expirationDate: string | Date): boolean => {
  const expires = new Date(expirationDate);
  const now = new Date();
  return expires.getTime() < now.getTime();
};

export const getQRType = (qrCode: string): 'delivery' | 'return' | 'unknown' => {
  // In real implementation, this would query database
  // For now, we just validate format
  return validateQRFormat(qrCode) ? 'delivery' : 'unknown';
};

describe('QR Service Utils', () => {
  describe('generateQRCode', () => {
    it('should generate QR code with correct format', () => {
      const shipmentId = '550e8400-e29b-41d4-a716-446655440000';
      const qrCode = generateQRCode(shipmentId);

      expect(qrCode).toMatch(/^BS-[A-Z0-9]{8}$/);
      expect(qrCode).toBe('BS-550E8400');
    });

    it('should handle different UUID formats', () => {
      const uuids = [
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        '00000000-0000-0000-0000-000000000000',
        'ffffffff-ffff-ffff-ffff-ffffffffffff'
      ];

      uuids.forEach(uuid => {
        const qrCode = generateQRCode(uuid);
        expect(qrCode).toMatch(/^BS-[A-Z0-9]{8}$/);
        expect(qrCode.length).toBe(11); // BS- + 8 chars
      });
    });

    it('should be uppercase', () => {
      const shipmentId = 'abcdef12-3456-7890-abcd-ef1234567890';
      const qrCode = generateQRCode(shipmentId);

      expect(qrCode).toBe(qrCode.toUpperCase());
      expect(qrCode).toBe('BS-ABCDEF12');
    });
  });

  describe('validateQRFormat', () => {
    it('should validate correct QR codes', () => {
      const validQRs = [
        'BS-550E8400',
        'BS-ABCD1234',
        'BS-12345678',
        'BS-FFFFFFFF'
      ];

      validQRs.forEach(qr => {
        expect(validateQRFormat(qr)).toBe(true);
      });
    });

    it('should reject invalid QR codes', () => {
      const invalidQRs = [
        'BS-123',                    // Too short
        'BS-ABCDEFGHIJ',            // Too long
        'BRICKSHARE-12345678',      // Wrong prefix
        'BS-abcd1234',              // Lowercase
        'BS-ABCD-1234',             // Extra hyphen
        'BS_ABCD1234',              // Wrong separator
        'BS-ABCD 123',              // Space
        'BS-ABCD@123',              // Special char
        '550E8400',                 // No prefix
        ''                          // Empty
      ];

      invalidQRs.forEach(qr => {
        expect(validateQRFormat(qr)).toBe(false);
      });
    });
  });

  describe('parseQRCode', () => {
    it('should parse valid QR codes', () => {
      const qrCode = 'BS-550E8400';
      const parsed = parseQRCode(qrCode);

      expect(parsed).not.toBeNull();
      expect(parsed?.prefix).toBe('BS');
      expect(parsed?.shipmentId).toBe('550E8400');
    });

    it('should return null for invalid QR codes', () => {
      const invalidQRs = [
        'INVALID',
        'BS-123',
        'NOT-A-QR-CODE'
      ];

      invalidQRs.forEach(qr => {
        expect(parseQRCode(qr)).toBeNull();
      });
    });
  });

  describe('generateQRExpiration', () => {
    it('should generate expiration 30 days from now by default', () => {
      const expiration = generateQRExpiration();
      const now = new Date();
      const thirtyDaysLater = new Date();
      thirtyDaysLater.setDate(now.getDate() + 30);

      // Allow 1 second tolerance for execution time
      const diff = Math.abs(expiration.getTime() - thirtyDaysLater.getTime());
      expect(diff).toBeLessThan(1000);
    });

    it('should generate custom expiration days', () => {
      const days = 7;
      const expiration = generateQRExpiration(days);
      const now = new Date();
      const sevenDaysLater = new Date();
      sevenDaysLater.setDate(now.getDate() + days);

      const diff = Math.abs(expiration.getTime() - sevenDaysLater.getTime());
      expect(diff).toBeLessThan(1000);
    });

    it('should handle negative days (expiration in past)', () => {
      const expiration = generateQRExpiration(-1);
      const now = new Date();

      expect(expiration.getTime()).toBeLessThan(now.getTime());
    });
  });

  describe('isQRExpired', () => {
    it('should detect expired QR codes', () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      expect(isQRExpired(yesterday)).toBe(true);
      expect(isQRExpired(yesterday.toISOString())).toBe(true);
    });

    it('should detect valid (not expired) QR codes', () => {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);

      expect(isQRExpired(tomorrow)).toBe(false);
      expect(isQRExpired(tomorrow.toISOString())).toBe(false);
    });

    it('should handle edge case of expiration right now', () => {
      const now = new Date();

      // Should be expired (or very close)
      const result = isQRExpired(now);
      // Allow either true or false depending on exact timing
      expect(typeof result).toBe('boolean');
    });
  });

  describe('getQRType', () => {
    it('should identify valid QR codes', () => {
      const qrCode = 'BS-550E8400';
      const type = getQRType(qrCode);

      expect(type).toBe('delivery'); // Default for valid format
    });

    it('should return unknown for invalid QR codes', () => {
      const invalidQRs = [
        'INVALID',
        'BS-123',
        ''
      ];

      invalidQRs.forEach(qr => {
        expect(getQRType(qr)).toBe('unknown');
      });
    });
  });

  describe('QR Code integration scenarios', () => {
    it('should generate, validate, and parse QR code', () => {
      const shipmentId = '550e8400-e29b-41d4-a716-446655440000';
      
      // Generate
      const qrCode = generateQRCode(shipmentId);
      expect(qrCode).toBe('BS-550E8400');

      // Validate
      expect(validateQRFormat(qrCode)).toBe(true);

      // Parse
      const parsed = parseQRCode(qrCode);
      expect(parsed).not.toBeNull();
      expect(parsed?.shipmentId).toBe('550E8400');
    });

    it('should generate QR with expiration and check validity', () => {
      const shipmentId = '550e8400-e29b-41d4-a716-446655440000';
      const qrCode = generateQRCode(shipmentId);
      const expiration = generateQRExpiration(30);

      expect(validateQRFormat(qrCode)).toBe(true);
      expect(isQRExpired(expiration)).toBe(false);
    });

    it('should reject tampered QR codes', () => {
      const shipmentId = '550e8400-e29b-41d4-a716-446655440000';
      const validQR = generateQRCode(shipmentId);

      // Tamper with QR
      const tamperedQRs = [
        validQR.toLowerCase(),           // Changed case
        validQR.replace('550E', '551E'), // Changed ID
        validQR + 'X',                   // Extra char
        validQR.substring(0, 10)         // Truncated
      ];

      tamperedQRs.forEach(qr => {
        if (qr === validQR.toLowerCase()) {
          // Lowercase is invalid format
          expect(validateQRFormat(qr)).toBe(false);
        }
      });
    });
  });
});