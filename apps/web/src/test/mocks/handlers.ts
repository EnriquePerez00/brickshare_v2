import { http, HttpResponse } from 'msw';
import { mockSets } from '../fixtures/sets';
import { mockShipments } from '../fixtures/shipments';
import { mockWishlistItems } from '../fixtures/wishlist';

export const handlers = [
  // Sets endpoints
  http.get('*/rest/v1/sets', () => {
    return HttpResponse.json(mockSets);
  }),

  http.get('*/rest/v1/sets/:id', () => {
    return HttpResponse.json(mockSets[0]);
  }),

  // Shipments endpoints
  http.get('*/rest/v1/shipments', () => {
    return HttpResponse.json(mockShipments);
  }),

  http.get('*/rest/v1/shipments/:id', () => {
    return HttpResponse.json(mockShipments[0]);
  }),

  // Wishlist endpoints
  http.get('*/rest/v1/wishlist', () => {
    return HttpResponse.json(mockWishlistItems);
  }),

  http.post('*/rest/v1/wishlist', () => {
    return HttpResponse.json({ success: true });
  }),

  http.delete('*/rest/v1/wishlist/:id', () => {
    return HttpResponse.json({ success: true });
  }),

  // Stripe checkout
  http.post('*/functions/v1/create-checkout-session', () => {
    return HttpResponse.json({
      session_id: 'cs_test_123456',
      url: 'https://checkout.stripe.com/pay/cs_test_123456',
    });
  }),

  // PUDO locations
  http.get('*/rest/v1/brickshare_pudo_locations', () => {
    return HttpResponse.json([
      {
        id: 'pudo-1',
        name: 'Correos Atocha',
        address: 'Calle Atocha 1',
        zip_code: '28012',
        city: 'Madrid',
      },
    ]);
  }),

  // Users
  http.get('*/rest/v1/users', () => {
    return HttpResponse.json([]);
  }),

  http.post('*/rest/v1/users', () => {
    return HttpResponse.json({ success: true });
  }),

  // Generic fallback
  http.all('*', () => {
    return HttpResponse.json({ error: 'Not mocked' }, { status: 404 });
  }),
];