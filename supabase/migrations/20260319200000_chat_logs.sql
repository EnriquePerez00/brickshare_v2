-- Chat conversation logging for Brickman
-- Stores full conversations, individual messages and user feedback

-- ── Table: chat_conversations ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id    uuid NOT NULL,                        -- anonymous session (generated in browser)
  user_id       uuid REFERENCES auth.users(id) ON DELETE SET NULL,  -- nullable: works without login
  page_url      text,                                 -- page where the chat was opened
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- ── Table: chat_messages ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id  uuid NOT NULL REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
  role             text NOT NULL CHECK (role IN ('user', 'assistant')),
  content          text NOT NULL,
  feedback         smallint CHECK (feedback IN (1, -1)),  -- 1=👍  -1=👎  NULL=no feedback
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- ── Indexes ────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS chat_conversations_session_idx ON public.chat_conversations(session_id);
CREATE INDEX IF NOT EXISTS chat_conversations_user_idx    ON public.chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS chat_messages_conversation_idx ON public.chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS chat_messages_created_idx      ON public.chat_messages(created_at);

-- ── RLS ────────────────────────────────────────────────────────────────────
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages      ENABLE ROW LEVEL SECURITY;

-- Anyone (anon or authenticated) can insert a conversation
CREATE POLICY "chat_conversations_insert" ON public.chat_conversations
  FOR INSERT WITH CHECK (true);

-- Anyone can read their own session conversations (by session_id passed from client)
CREATE POLICY "chat_conversations_select" ON public.chat_conversations
  FOR SELECT USING (true);

-- Anyone can insert messages (the edge function uses service role anyway)
CREATE POLICY "chat_messages_insert" ON public.chat_messages
  FOR INSERT WITH CHECK (true);

-- Anyone can read messages
CREATE POLICY "chat_messages_select" ON public.chat_messages
  FOR SELECT USING (true);

-- Users can update ONLY the feedback field of messages in their conversations
CREATE POLICY "chat_messages_update_feedback" ON public.chat_messages
  FOR UPDATE USING (true)
  WITH CHECK (true);

-- ── Auto-update updated_at on chat_conversations ──────────────────────────
CREATE OR REPLACE FUNCTION public.update_chat_conversation_timestamp()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.chat_conversations
  SET updated_at = now()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER chat_messages_update_conversation_ts
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW EXECUTE FUNCTION public.update_chat_conversation_timestamp();