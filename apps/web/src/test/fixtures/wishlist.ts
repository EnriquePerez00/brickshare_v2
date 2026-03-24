export const mockWishlistItem = {
  id: 'wish-1',
  user_id: 'user-1',
  set_id: 'set-1',
  priority: 1,
  created_at: '2024-03-20T00:00:00Z',
};

export const mockWishlistItems = [
  mockWishlistItem,
  {
    ...mockWishlistItem,
    id: 'wish-2',
    set_id: 'set-2',
    priority: 2,
  },
  {
    ...mockWishlistItem,
    id: 'wish-3',
    set_id: 'set-3',
    priority: 3,
  },
];