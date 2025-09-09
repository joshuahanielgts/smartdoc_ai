'use server';

import { config } from 'dotenv';
config();

import '@/ai/flows/provide-voice-assistant-warnings.ts';
import '@/ai/flows/generate-personalized-safety-tips.ts';
import '@/ai/flows/generate-daily-session-summaries.ts';
import '@/ai/flows/generate-speech.ts';
import '@/ai/flows/predict-high-risk-zones.ts';
import '@/ai/flows/trigger-sos-alert.ts';
import '@/ai/flows/get-accident-prone-zones.ts';
