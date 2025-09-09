'use server';

import { provideVoiceAssistantWarnings } from '@/ai/flows/provide-voice-assistant-warnings';
import { generatePersonalizedSafetyTips } from '@/ai/flows/generate-personalized-safety-tips';
import { generateDailySessionSummary, type GenerateDailySessionSummaryInput } from '@/ai/flows/generate-daily-session-summaries';
import { generateSpeech } from '@/ai/flows/generate-speech';
import { predictHighRiskZones } from '@/ai/flows/predict-high-risk-zones';
import { triggerSOSAlert } from '@/ai/flows/trigger-sos-alert';

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

export async function getSpeech(text: string) {
  try {
    const result = await generateSpeech({ text });
    return result.audio;
  } catch (error)
  {
    console.error('Error getting speech:', error);
    throw new Error('Could not generate speech.');
  }
}

export async function getHighRiskZonePrediction(driverId: string, historicalData: string[]) {
  try {
    const result = await predictHighRiskZones({ driverId, historicalData });
    return result;
  } catch (error) {
    console.error('Error getting high risk zone prediction:', error);
    return { predictedZones: ['Error predicting zones.'] };
  }
}

export async function triggerSOS(driverId: string, lastKnownLocation: string) {
  try {
    const result = await triggerSOSAlert({ driverId, lastKnownLocation });
    return result;
  } catch (error) {
    console.error('Error triggering SOS:', error);
    throw new Error('Could not trigger SOS alert.');
  }
}
