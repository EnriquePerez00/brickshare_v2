-- ============================================================================
-- Migration: Remove Brickman Chatbot Tables
-- Created: 2026-03-25
-- Description: Removes all database tables, triggers, and functions related to
--              the Brickman chatbot feature as it's being completely removed.
-- ============================================================================

-- Drop triggers first
DROP TRIGGER IF EXISTS chat_messages_update_conversation_ts ON public.chat_messages;
DROP TRIGGER IF EXISTS update_brickman_knowledge_updated_at ON public.brickman_knowledge;

-- Drop functions
DROP FUNCTION IF EXISTS public.update_chat_conversation_timestamp();
DROP FUNCTION IF EXISTS public.update_brickman_knowledge_updated_at();

-- Drop tables (cascade will handle foreign key constraints)
DROP TABLE IF EXISTS public.chat_messages CASCADE;
DROP TABLE IF EXISTS public.chat_conversations CASCADE;
DROP TABLE IF EXISTS public.brickman_knowledge CASCADE;

-- Note: The Edge Function 'brickman-chat' should be manually deleted from Supabase dashboard
-- or via CLI: supabase functions delete brickman-chat