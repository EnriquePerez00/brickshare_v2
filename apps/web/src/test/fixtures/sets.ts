export const mockSet = {
  id: 'set-1',
  set_ref: '75192',
  name: 'UCS Millennium Falcon',
  theme: 'Star Wars',
  piece_count: 7541,
  age_range: '16+',
  description: 'Iconic LEGO Star Wars set',
  img_url: 'https://example.com/set-1.jpg',
  price: 799.99,
  status: 'active',
  brickset_url: 'https://brickset.com/sets/75192-1',
  rebrickable_id: '75192-1',
  year_released: 2017,
  weight: 15.5,
  dimensions: { length: 84, width: 56, height: 17 },
};

export const mockSetBasic = {
  ...mockSet,
  id: 'set-2',
  set_ref: '10298',
  name: 'Titanic',
  theme: 'Architecture',
  piece_count: 9090,
  price: 399.99,
};

export const mockSetSmall = {
  ...mockSet,
  id: 'set-3',
  set_ref: '21303',
  name: 'WALL-E',
  theme: 'Ideas',
  piece_count: 677,
  price: 199.99,
};

export const mockSets = [mockSet, mockSetBasic, mockSetSmall];

export const mockPieceListItem = {
  id: 'piece-1',
  set_id: 'set-1',
  piece_id: '3001',
  quantity: 50,
  color: 'Black',
  piece_name: 'Brick 2x4',
  studdim: { x: 2, y: 4 },
};