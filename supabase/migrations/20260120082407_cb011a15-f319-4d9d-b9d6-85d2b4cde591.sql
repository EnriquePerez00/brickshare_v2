-- Make product_id nullable in inventory (since we now use set_id)
-- ALTER TABLE public.inventory ALTER COLUMN product_id DROP NOT NULL;
-- Commented out: product_id was already renamed to set_id in previous migration

-- Make product_id nullable in wishlist (since we now use set_id)
-- ALTER TABLE public.wishlist ALTER COLUMN product_id DROP NOT NULL;
-- Commented out: product_id was already renamed to set_id in previous migration