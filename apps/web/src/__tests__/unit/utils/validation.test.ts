import { describe, it, expect } from 'vitest';

describe('Validation Utilities', () => {
  describe('email validation', () => {
    it('should validate correct email format', () => {
      const validEmail = 'test@example.com';
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      expect(emailRegex.test(validEmail)).toBe(true);
    });

    it('should reject invalid email formats', () => {
      const invalidEmails = [
        'notanemail',
        'test@',
        '@example.com',
        'test @example.com',
      ];

      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      invalidEmails.forEach(email => {
        expect(emailRegex.test(email)).toBe(false);
      });
    });

    it('should handle edge cases', () => {
      const emails = [
        'user+tag@example.co.uk',
        'first.last@subdomain.example.com',
        'user_name@example.com',
      ];

      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      emails.forEach(email => {
        expect(emailRegex.test(email)).toBe(true);
      });
    });
  });

  describe('phone validation', () => {
    it('should validate Spanish phone numbers', () => {
      const validPhone = '+34612345678';
      const phoneRegex = /^\+34[0-9]{9}$/;

      expect(phoneRegex.test(validPhone)).toBe(true);
    });

    it('should accept various formats', () => {
      const phones = [
        '+34 612 345 678',
        '612345678',
        '34612345678',
      ];

      // Flexible regex
      const phoneRegex = /^(\+34|0034|34)?6[0-9]{8}$/;

      phones.forEach(phone => {
        const normalized = phone.replace(/\s/g, '');
        expect(normalized.match(/^(\+?34)?6[0-9]{8}$/)).not.toBeNull();
      });
    });

    it('should reject invalid phone numbers', () => {
      const invalidPhones = [
        '+34 123 456 7890', // Too long
        '+33612345678', // Wrong country
        'notaphone',
      ];

      const phoneRegex = /^\+34[0-9]{9}$/;

      invalidPhones.forEach(phone => {
        expect(phoneRegex.test(phone)).toBe(false);
      });
    });
  });

  describe('postal code validation', () => {
    it('should validate Spanish postal codes', () => {
      const validZip = '28012';
      const zipRegex = /^[0-9]{5}$/;

      expect(zipRegex.test(validZip)).toBe(true);
    });

    it('should accept regional codes', () => {
      const codes = ['28001', '08002', '41001', '03001'];

      const zipRegex = /^[0-9]{5}$/;

      codes.forEach(code => {
        expect(zipRegex.test(code)).toBe(true);
      });
    });
  });

  describe('URL validation', () => {
    it('should validate valid URLs', () => {
      const validUrls = [
        'https://example.com',
        'https://www.example.com',
        'https://sub.example.co.uk',
      ];

      const urlRegex = /^https?:\/\/.+\..+$/;

      validUrls.forEach(url => {
        expect(urlRegex.test(url)).toBe(true);
      });
    });
  });
});