import { config } from 'dotenv';
config();

import '@/ai/flows/provide-voice-assistant-warnings.ts';
import '@/ai/flows/generate-personalized-safety-tips.ts';
import '@/ai/flows/generate-daily-session-summaries.ts';