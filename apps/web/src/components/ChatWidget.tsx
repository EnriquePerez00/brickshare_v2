import { useState, useRef, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { MessageCircle, X, Send, Loader2, ThumbsUp, ThumbsDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  timestamp: Date;
  /** DB id returned by the edge function for assistant messages */
  dbId?: string;
  /** Whether to show the feedback buttons below this message */
  showFeedback?: boolean;
  /** Feedback already given: 1 = 👍, -1 = 👎 */
  feedback?: 1 | -1 | null;
}

const WELCOME_MESSAGE: Message = {
  id: "welcome",
  role: "assistant",
  content:
    "¡Hola! 👋 Soy **Brickman**, el asistente de Brickshare. Estoy aquí para ayudarte con cualquier pregunta sobre nuestro servicio de alquiler de sets de construcción. ¿En qué puedo ayudarte? 🧱",
  timestamp: new Date(),
};

/** Generate a UUID in the browser (crypto.randomUUID or fallback) */
function newUUID(): string {
  return crypto.randomUUID();
}

function formatMessage(text: string) {
  const parts = text.split(/(\*\*[^*]+\*\*)/g);
  return parts.map((part, i) => {
    if (part.startsWith("**") && part.endsWith("**")) {
      return <strong key={i}>{part.slice(2, -2)}</strong>;
    }
    return <span key={i}>{part}</span>;
  });
}

export default function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([WELCOME_MESSAGE]);
  const [inputValue, setInputValue] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  // ── Session / conversation tracking ─────────────────────────────────────
  const sessionId = useRef<string>(newUUID());
  const conversationId = useRef<string | null>(null);

  // Count how many assistant messages have been received (excl. welcome)
  const assistantMsgCount = useRef<number>(0);

  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // Scroll to bottom whenever messages change
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Focus input when chat opens
  useEffect(() => {
    if (isOpen) {
      setTimeout(() => inputRef.current?.focus(), 300);
    }
  }, [isOpen]);

  // ── Feedback handler ─────────────────────────────────────────────────────
  const handleFeedback = useCallback(
    async (messageId: string, dbId: string | undefined, value: 1 | -1) => {
      // Optimistic update in UI
      setMessages((prev) =>
        prev.map((m) =>
          m.id === messageId
            ? { ...m, feedback: value, showFeedback: false }
            : m
        )
      );

      // Persist to Supabase if we have a DB id
      if (dbId) {
        const { error } = await supabase
          .from("chat_messages")
          .update({ feedback: value })
          .eq("id", dbId);

        if (error) {
          console.warn("Could not save feedback:", error.message);
        }
      }
    },
    []
  );

  // ── Send message ──────────────────────────────────────────────────────────
  const sendMessage = async () => {
    const trimmed = inputValue.trim();
    if (!trimmed || isLoading) return;

    const userMessage: Message = {
      id: newUUID(),
      role: "user",
      content: trimmed,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInputValue("");
    setIsLoading(true);

    try {
      // Build conversation history (exclude welcome, keep last 6)
      const history = messages
        .filter((m) => m.id !== "welcome")
        .slice(-6)
        .map((m) => ({ role: m.role, content: m.content }));

      const { data, error } = await supabase.functions.invoke("brickman-chat", {
        body: {
          message: trimmed,
          conversationHistory: history,
          conversationId: conversationId.current ?? undefined,
          sessionId: sessionId.current,
          pageUrl: window.location.href,
        },
      });

      if (error) throw error;

      // Persist the conversation id for subsequent messages
      if (data?.conversationId && !conversationId.current) {
        conversationId.current = data.conversationId;
      }

      // Increment assistant message counter
      assistantMsgCount.current += 1;

      // Show feedback buttons every 5th assistant response
      const showFeedback = assistantMsgCount.current % 5 === 0;

      const assistantMessage: Message = {
        id: newUUID(),
        role: "assistant",
        content:
          data?.message ||
          "Lo siento, no pude procesar tu pregunta. ¿Puedes intentarlo de nuevo?",
        timestamp: new Date(),
        dbId: data?.messageId ?? undefined,
        showFeedback,
        feedback: null,
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (err) {
      console.error("Chat error:", err);
      const errorMessage: Message = {
        id: newUUID(),
        role: "assistant",
        content:
          "Lo siento, ha ocurrido un problema técnico 😅. Por favor, inténtalo de nuevo o contáctanos en brickshare.es.",
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div className="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-3">
      {/* Chat popup */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, scale: 0.85, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.85, y: 20 }}
            transition={{ type: "spring", stiffness: 300, damping: 25 }}
            className="w-[350px] sm:w-[380px] bg-background border border-border rounded-2xl shadow-2xl flex flex-col overflow-hidden"
            style={{ maxHeight: "calc(100vh - 120px)", height: "520px" }}
          >
            {/* Header */}
            <div className="flex items-center gap-3 px-4 py-3 bg-primary text-primary-foreground">
              <div className="relative">
                <div className="w-9 h-9 rounded-full bg-primary-foreground/20 flex items-center justify-center">
                  <span className="text-lg">🧱</span>
                </div>
                {/* Online dot */}
                <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-400 border-2 border-primary rounded-full" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-sm leading-tight">Brickman</p>
                <p className="text-xs text-primary-foreground/75 leading-tight">
                  Asistente de Brickshare · En línea
                </p>
              </div>
              <button
                onClick={() => setIsOpen(false)}
                className="rounded-full p-1 hover:bg-primary-foreground/20 transition-colors"
                aria-label="Cerrar chat"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Messages area */}
            <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3 bg-muted/20">
              {messages.map((msg) => (
                <motion.div
                  key={msg.id}
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.2 }}
                  className={`flex flex-col gap-1 ${
                    msg.role === "user" ? "items-end" : "items-start"
                  }`}
                >
                  <div
                    className={`flex gap-2 ${
                      msg.role === "user" ? "flex-row-reverse" : "flex-row"
                    }`}
                  >
                    {/* Avatar */}
                    {msg.role === "assistant" && (
                      <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                        <span className="text-sm">🧱</span>
                      </div>
                    )}

                    {/* Bubble */}
                    <div
                      className={`max-w-[80%] rounded-2xl px-3 py-2 text-sm leading-relaxed ${
                        msg.role === "user"
                          ? "bg-primary text-primary-foreground rounded-tr-sm"
                          : "bg-background border border-border rounded-tl-sm shadow-sm"
                      }`}
                    >
                      {formatMessage(msg.content)}
                    </div>
                  </div>

                  {/* Feedback row — only for assistant messages when showFeedback */}
                  {msg.role === "assistant" && msg.showFeedback && msg.feedback === null && (
                    <motion.div
                      initial={{ opacity: 0, y: 4 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.3, duration: 0.25 }}
                      className="flex items-center gap-2 pl-9"
                    >
                      <span className="text-xs text-muted-foreground">
                        ¿Te ha sido útil?
                      </span>
                      <button
                        onClick={() => handleFeedback(msg.id, msg.dbId, 1)}
                        className="rounded-full p-1 hover:bg-green-100 text-muted-foreground hover:text-green-600 transition-colors"
                        aria-label="Respuesta útil"
                      >
                        <ThumbsUp className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleFeedback(msg.id, msg.dbId, -1)}
                        className="rounded-full p-1 hover:bg-red-100 text-muted-foreground hover:text-red-500 transition-colors"
                        aria-label="Respuesta no útil"
                      >
                        <ThumbsDown className="w-3.5 h-3.5" />
                      </button>
                    </motion.div>
                  )}

                  {/* Feedback confirmation */}
                  {msg.role === "assistant" && msg.feedback !== undefined && msg.feedback !== null && (
                    <motion.p
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      className="text-xs text-muted-foreground pl-9"
                    >
                      {msg.feedback === 1 ? "¡Gracias! 😊" : "Gracias por el feedback 🙏"}
                    </motion.p>
                  )}
                </motion.div>
              ))}

              {/* Loading indicator */}
              {isLoading && (
                <motion.div
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="flex gap-2 flex-row"
                >
                  <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-sm">🧱</span>
                  </div>
                  <div className="bg-background border border-border rounded-2xl rounded-tl-sm px-4 py-3 shadow-sm">
                    <div className="flex gap-1 items-center">
                      <span
                        className="w-1.5 h-1.5 bg-muted-foreground/50 rounded-full animate-bounce"
                        style={{ animationDelay: "0ms" }}
                      />
                      <span
                        className="w-1.5 h-1.5 bg-muted-foreground/50 rounded-full animate-bounce"
                        style={{ animationDelay: "150ms" }}
                      />
                      <span
                        className="w-1.5 h-1.5 bg-muted-foreground/50 rounded-full animate-bounce"
                        style={{ animationDelay: "300ms" }}
                      />
                    </div>
                  </div>
                </motion.div>
              )}

              <div ref={messagesEndRef} />
            </div>

            {/* Input area */}
            <div className="px-3 py-3 border-t border-border bg-background">
              <div className="flex gap-2 items-center">
                <input
                  ref={inputRef}
                  type="text"
                  value={inputValue}
                  onChange={(e) => setInputValue(e.target.value)}
                  onKeyDown={handleKeyDown}
                  placeholder="Escribe tu pregunta..."
                  disabled={isLoading}
                  className="flex-1 bg-muted/50 rounded-xl px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/30 placeholder:text-muted-foreground disabled:opacity-50 transition-all"
                />
                <Button
                  size="icon"
                  onClick={sendMessage}
                  disabled={!inputValue.trim() || isLoading}
                  className="rounded-xl w-10 h-10 flex-shrink-0"
                  aria-label="Enviar mensaje"
                >
                  {isLoading ? (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  ) : (
                    <Send className="w-4 h-4" />
                  )}
                </Button>
              </div>
              <p className="text-center text-xs text-muted-foreground/60 mt-2">
                Brickman · Asistente IA de Brickshare
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Toggle button */}
      <motion.button
        onClick={() => setIsOpen((prev) => !prev)}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        className="relative w-14 h-14 rounded-full bg-primary text-primary-foreground shadow-lg flex items-center justify-center transition-shadow hover:shadow-xl"
        aria-label={isOpen ? "Cerrar chat" : "Abrir chat con Brickman"}
      >
        <AnimatePresence mode="wait">
          {isOpen ? (
            <motion.span
              key="close"
              initial={{ rotate: -90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: 90, opacity: 0 }}
              transition={{ duration: 0.15 }}
            >
              <X className="w-6 h-6" />
            </motion.span>
          ) : (
            <motion.span
              key="open"
              initial={{ rotate: 90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: -90, opacity: 0 }}
              transition={{ duration: 0.15 }}
            >
              <MessageCircle className="w-6 h-6" />
            </motion.span>
          )}
        </AnimatePresence>

        {/* Pulse ring when closed */}
        {!isOpen && (
          <span className="absolute inset-0 rounded-full bg-primary/30 animate-ping" />
        )}
      </motion.button>
    </div>
  );
}