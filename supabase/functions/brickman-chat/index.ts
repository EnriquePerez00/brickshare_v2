// @ts-nocheck — Deno runtime types are not available in the TS checker for this project
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface Message {
  role: "user" | "assistant";
  content: string;
}

interface RequestBody {
  message: string;
  conversationHistory?: Message[];
  conversationId?: string;   // uuid of the chat_conversations row
  sessionId?: string;        // uuid generated in the browser (anonymous)
  pageUrl?: string;          // page from which the chat was opened
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const {
      message,
      conversationHistory = [],
      conversationId,
      sessionId,
      pageUrl,
    }: RequestBody = await req.json();

    if (!message || message.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Message is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const groqApiKey = Deno.env.get("GROQ_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    if (!groqApiKey) {
      console.error("Missing GROQ_API_KEY secret");
      return new Response(
        JSON.stringify({ error: "Configuration error: missing GROQ_API_KEY" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // ── Step 1: Ensure conversation row exists ─────────────────────────────
    let activeConversationId = conversationId ?? null;

    if (!activeConversationId && sessionId) {
      // Create a new conversation row
      const { data: conv, error: convErr } = await supabase
        .from("chat_conversations")
        .insert({
          session_id: sessionId,
          page_url: pageUrl ?? null,
        })
        .select("id")
        .single();

      if (!convErr && conv) {
        activeConversationId = conv.id;
      } else {
        console.warn("Could not create conversation row:", convErr?.message);
      }
    }

    // ── Step 2: Load knowledge base from Supabase ──────────────────────────
    const { data: kbRows, error: kbError } = await supabase
      .from("brickman_knowledge")
      .select("content")
      .order("id", { ascending: false })
      .limit(1);

    let knowledgeBase = "";
    if (kbError || !kbRows || kbRows.length === 0) {
      console.warn("No knowledge base found in DB, using empty context.");
    } else {
      knowledgeBase = kbRows[0].content;
    }

    // ── Step 3: Build Brickman system prompt ───────────────────────────────
    const systemPrompt = `Eres Brickman, el asistente virtual amable y cercano de Brickshare, el primer servicio de alquiler y suscripción circular de sets de construcción en España.

Tu personalidad:
- Eres entusiasta, amigable y hablas de forma natural, como si charlaras con una familia española
- Usas un tono cálido y positivo, con algún emoji ocasional (🧱 🎉 😊) para dar vida a la conversación
- Siempre tratas de ayudar; si no sabes algo, lo dices con honestidad y ofreces alternativas
- Hablas siempre en español
- Eres conciso: responde en un máximo de 3-4 frases cortas. Si necesitan más detalle, ofrece ampliar.
- Cuando menciones precios o condiciones, sé preciso con los datos del servicio

Tu misión:
- Responder preguntas sobre Brickshare basándote EXCLUSIVAMENTE en la información proporcionada
- Si la pregunta no está cubierta, indica amablemente que pueden contactar con el equipo en www.brickshare.es
- NUNCA inventes información que no aparezca en el contexto del servicio

Información completa del servicio Brickshare:
===
${knowledgeBase}
===

Recuerda: Eres Brickman, el asistente de Brickshare. No menciones que eres una IA ni que consultas una "base de datos". Responde con naturalidad como el asistente del servicio.`;

    // ── Step 4: Build messages array for Groq ─────────────────────────────
    const recentHistory = (conversationHistory as Message[]).slice(-6);

    const messages = [
      { role: "system", content: systemPrompt },
      ...recentHistory,
      { role: "user", content: message },
    ];

    // ── Step 5: Save user message to DB ───────────────────────────────────
    if (activeConversationId) {
      const { error: userMsgErr } = await supabase
        .from("chat_messages")
        .insert({
          conversation_id: activeConversationId,
          role: "user",
          content: message,
        });
      if (userMsgErr) {
        console.warn("Could not save user message:", userMsgErr.message);
      }
    }

    // ── Step 6: Call Groq API ──────────────────────────────────────────────
    const groqResponse = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${groqApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "llama-3.1-8b-instant",
          messages,
          max_tokens: 300,
          temperature: 0.65,
          stream: false,
        }),
      }
    );

    if (!groqResponse.ok) {
      const err = await groqResponse.text();
      console.error("Groq API error:", err);
      throw new Error("Failed to get response from Groq");
    }

    const groqData = await groqResponse.json();
    const assistantContent = groqData.choices[0]?.message?.content ?? "";

    // ── Step 7: Save assistant message to DB and return its id ────────────
    let assistantMessageId: string | null = null;

    if (activeConversationId) {
      const { data: aMsg, error: aMsgErr } = await supabase
        .from("chat_messages")
        .insert({
          conversation_id: activeConversationId,
          role: "assistant",
          content: assistantContent,
        })
        .select("id")
        .single();

      if (!aMsgErr && aMsg) {
        assistantMessageId = aMsg.id;
      } else {
        console.warn("Could not save assistant message:", aMsgErr?.message);
      }
    }

    return new Response(
      JSON.stringify({
        message: assistantContent,
        role: "assistant",
        conversationId: activeConversationId,
        messageId: assistantMessageId,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("brickman-chat error:", error);
    return new Response(
      JSON.stringify({
        error: "Lo siento, ha ocurrido un error. Por favor, inténtalo de nuevo.",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});