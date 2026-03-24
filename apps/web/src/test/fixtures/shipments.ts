export const mockShipment = {
  id: 'shipment-1',
  assignment_id: 'assign-1',
  user_id: 'user-1',
  set_id: 'set-1',
  set_ref: '75192',
  direction: 'outgoing',
  status: 'en_transito',
  pudo_point_id: 'pudo-1',
  pudo_name: 'Correos Atocha',
  pudo_address: 'Calle Atocha 1',
  pudo_zip: '28012',
  pudo_city: 'Madrid',
  tracking_number: 'CC000123456ES',
  delivery_qr_code: 'QR-DELIVERY-123',
  return_qr_code: 'QR-RETURN-456',
  expected_delivery_date: '2024-03-30',
  actual_delivery_date: null,
  created_at: '2024-03-23T10:00:00Z',
  updated_at: '2024-03-23T12:00:00Z',
};

export const mockShipmentDelivered = {
  ...mockShipment,
  id: 'shipment-2',
  status: 'entregado',
  actual_delivery_date: '2024-03-30',
};

export const mockShipmentReturn = {
  ...mockShipment,
  id: 'shipment-3',
  direction: 'incoming',
  status: 'devuelto',
  expected_delivery_date: '2024-04-15',
  actual_delivery_date: '2024-04-15',
};

export const mockShipments = [mockShipment, mockShipmentDelivered, mockShipmentReturn];

export const mockAssignment = {
  id: 'assign-1',
  user_id: 'user-1',
  set_id: 'set-1',
  set_ref: '75192',
  status: 'active',
  assigned_at: '2024-03-20T00:00:00Z',
  due_date: '2024-04-20',
  created_at: '2024-03-20T00:00:00Z',
};