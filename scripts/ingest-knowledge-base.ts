/**
 * Brickman Knowledge Base Ingestion Script
 *
 * Reads public/knowledge-base.md and stores it as plain text in Supabase.
 * No embeddings needed — the KB is small enough to fit in the LLM context window.
 * Only requires GROQ for the chatbot; no OpenAI dependency.
 *
 * Usage:
 *   npx tsx scripts/ingest-knowledge-base.ts
 *
 * Required environment variables (.env.local):
 *   SUPABASE_URL=https://tevoogkifiszfontzkgd.supabase.co
 *   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
 */

import { createClient } from "@supabase/supabase-js";
import { readFileSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";
import { config } from "dotenv";

// Load .env.local
config({ path: ".env.local" });

const __dirname = dirname(fileURLToPath(import.meta.url));

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("❌ Missing required environment variables:");
  if (!SUPABASE_URL) console.error("   - SUPABASE_URL");
  if (!SUPABASE_SERVICE_ROLE_KEY) console.error("   - SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function main() {
  console.log("🧱 Brickman Knowledge Base Ingestion");
  console.log("=====================================\n");

  // Read the knowledge base markdown file
  const kbPath = resolve(__dirname, "../public/knowledge-base.md");
  let kbContent: string;

  try {
    kbContent = readFileSync(kbPath, "utf-8");
    console.log(`✅ Loaded: ${kbPath}`);
    console.log(`   Size: ${kbContent.length} characters (~${Math.ceil(kbContent.length / 4)} tokens)\n`);
  } catch {
    console.error(`❌ Could not read: ${kbPath}`);
    process.exit(1);
  }

  // Delete existing KB entries (full replacement)
  console.log("🗑️  Removing existing knowledge base...");
  const { error: deleteError } = await supabase
    .from("brickman_knowledge")
    .delete()
    .neq("id", 0);

  if (deleteError) {
    console.error("❌ Error deleting existing KB:", deleteError.message);
    process.exit(1);
  }
  console.log("   ✅ Cleared\n");

  // Insert the full KB text as a single record
  console.log("📝 Inserting knowledge base...");
  const { error: insertError } = await supabase
    .from("brickman_knowledge")
    .insert({ content: kbContent, version: "v1" });

  if (insertError) {
    console.error("❌ Insert error:", insertError.message);
    process.exit(1);
  }

  console.log("   ✅ Knowledge base inserted successfully\n");
  console.log("🎉 Done! Brickman is ready to answer questions about Brickshare.");
  console.log("\nNext steps:");
  console.log("  1. Deploy the Edge Function: supabase functions deploy brickman-chat");
  console.log("  2. Set the Groq secret:       supabase secrets set GROQ_API_KEY=gsk_...");
}

main().catch(console.error);