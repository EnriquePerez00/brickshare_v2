# Brickman Chatbot — Guía de Despliegue

Brickman es el asistente virtual de Brickshare, implementado con:

- **Supabase** (PostgreSQL) — almacenamiento del knowledge base como texto
- **Groq llama-3.1-8b-instant** — LLM de respuesta (**100% gratuito**, free tier)
- **Supabase Edge Function** — lógica del chatbot
- **React ChatWidget** — widget flotante en páginas públicas

> **Coste: $0/mes**. Solo necesitas una cuenta gratuita de Groq. Sin OpenAI, sin otros servicios de pago.

---

## ¿Por qué no RAG/vectores?

El knowledge base de Brickshare es pequeño (~3.500 caracteres, ~900 tokens). Cabe perfectamente en el contexto del LLM, por lo que no necesitamos embeddings ni búsqueda vectorial. El KB completo se inyecta directamente en el system prompt en cada petición.

Esto es:
- ✅ Más sencillo (no hay proceso de ingesta de embeddings)
- ✅ Más preciso (no hay errores de recuperación vectorial)
- ✅ Completamente gratuito (solo Groq)
- ✅ Fácil de actualizar (edita el markdown, ejecuta el script)

Cuando el KB crezca significativamente (>50.000 tokens), se puede migrar a RAG en ese momento.

---

## 1. Obtener API Key de Groq (gratuito)

1. Regístrate en https://console.groq.com
2. Ve a **API Keys** → **Create API Key**
3. Copia la clave: `gsk_...`

**Free tier**: 14.400 requests/día, 30 req/minuto — más que suficiente para una startup.

---

## 2. Configurar el secret en Supabase

```bash
supabase secrets set GROQ_API_KEY=gsk_tu_clave_aqui
```

Para verificar:
```bash
supabase secrets list
```

---

## 3. Aplicar la migración de base de datos

```bash
supabase db push
```

Esto crea la tabla `brickman_knowledge` con RLS configurado:
- Lectura pública (la Edge Function puede leer sin autenticación)
- Escritura solo para service_role (script de ingesta)

---

## 4. Desplegar la Edge Function

```bash
supabase functions deploy brickman-chat
```

---

## 5. Ingestar la base de conocimiento

Crea `.env.local` en la raíz del proyecto:

```env
SUPABASE_URL=https://tevoogkifiszfontzkgd.supabase.co
SUPABASE_SERVICE_ROLE_KEY=tu_service_role_key
```
> El `SUPABASE_SERVICE_ROLE_KEY` está en: Supabase Dashboard → Settings → API → service_role key

Instala dependencias del script si no las tienes:
```bash
npm install -D tsx dotenv @supabase/supabase-js
```

Ejecuta la ingesta:
```bash
npx tsx scripts/ingest-knowledge-base.ts
```

Salida esperada:
```
🧱 Brickman Knowledge Base Ingestion
=====================================

✅ Loaded: .../public/knowledge-base.md
   Size: 3842 characters (~960 tokens)

🗑️  Removing existing knowledge base...
   ✅ Cleared

📝 Inserting knowledge base...
   ✅ Knowledge base inserted successfully

🎉 Done! Brickman is ready to answer questions about Brickshare.
```

---

## 6. Actualizar la base de conocimiento

Cuando edites `public/knowledge-base.md`, simplemente vuelve a ejecutar:

```bash
npx tsx scripts/ingest-knowledge-base.ts
```

---

## 7. Arquitectura del flujo

```
Usuario escribe mensaje
        ↓
ChatWidget.tsx (React)
        ↓
supabase.functions.invoke('brickman-chat')
        ↓
Edge Function: brickman-chat/index.ts
  1. Lee el KB completo desde brickman_knowledge (Supabase)
  2. Construye system prompt: personalidad Brickman + KB completo
  3. Añade historial de conversación (últimos 6 mensajes)
  4. Llama a Groq API → llama-3.1-8b-instant → respuesta
        ↓
ChatWidget muestra la respuesta
```

---

## 8. Escalabilidad futura: datos de usuario autenticado

Para que Brickman consulte datos de la cuenta del usuario autenticado, modifica `brickman-chat/index.ts`:

```typescript
// Detectar usuario autenticado desde el JWT
const authHeader = req.headers.get("Authorization");
if (authHeader) {
  const userSupabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } }
  });
  const { data: { user } } = await userSupabase.auth.getUser();
  if (user) {
    const { data: profile } = await userSupabase
      .from("profiles")
      .select("full_name, subscription_plan, subscription_status")
      .eq("id", user.id)
      .single();
    // Inyectar en el system prompt:
    // `El usuario que está chateando se llama ${profile.full_name} y tiene el plan ${profile.subscription_plan}.`
  }
}
```

Y en `ChatWidget.tsx`, enviar el token cuando el usuario esté logado:
```typescript
const { data: { session } } = await supabase.auth.getSession();
const { data } = await supabase.functions.invoke("brickman-chat", {
  body: { message: trimmed, conversationHistory: history },
  headers: session ? { Authorization: `Bearer ${session.access_token}` } : {},
});
```

---

## 9. Resumen de costes

| Servicio | Plan | Coste |
|---|---|---|
| Groq (LLM) | Free tier | $0 |
| Supabase (DB + Edge Function) | Free tier | $0 |
| OpenAI | No se usa | $0 |
| **TOTAL** | | **$0/mes** |

---

## 10. Archivos del sistema

| Archivo | Descripción |
|---|---|
| `public/knowledge-base.md` | Base de conocimiento editable |
| `supabase/migrations/20260320000001_brickman_rag.sql` | Tabla `brickman_knowledge` |
| `supabase/functions/brickman-chat/index.ts` | Edge Function (solo Groq) |
| `scripts/ingest-knowledge-base.ts` | Script de ingesta (sin embeddings) |
| `src/components/ChatWidget.tsx` | Widget flotante de chat |
| `src/App.tsx` | Integración en rutas públicas |
| `supabase/config.toml` | Registro de la función |