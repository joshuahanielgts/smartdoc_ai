'use server';

import { provideVoiceAssistantWarnings } from '@/ai/flows/provide-voice-assistant-warnings';
import { generatePersonalizedSafetyTips } from '@/ai/flows/generate-personalized-safety-tips';
import { generateDailySessionSummary, type GenerateDailySessionSummaryInput } from '@/ai/flows/generate-daily-session-summaries';

export async function getVoiceWarning(dri: number) {
  try {
    const result = await provideVoiceAssistantWarnings({ dri });
    return result.warning;
  } catch (error) {
    console.error('Error getting voice warning:', error);
    return 'Please be careful.';
  }
}

export async function getSafetyTips(driHistory: string, alertFrequency: number) {
  try {
    const result = await generatePersonalizedSafetyTips({ driHistory, alertFrequency });
    return result.safetyTips;
  } catch (error) {
    console.error('Error getting safety tips:', error);
    return 'Could not generate tips. Please try again later.';
  }
}

export async function getDailySummary(input: GenerateDailySessionSummaryInput) {
    try {
        const result = await generateDailySessionSummary(input);
        return result.summary;
    } catch (error) {
        console.error('Error getting daily summary:', error);
        return 'Could not generate summary. Please try again later.';
    }
}
