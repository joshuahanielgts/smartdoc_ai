'use server';
/**
 * @fileOverview This file defines a Genkit flow for providing voice assistant warnings to the driver when drowsiness is detected.
 *
 * - provideVoiceAssistantWarnings - A function that triggers voice-based warnings.
 * - ProvideVoiceAssistantWarningsInput - The input type for the provideVoiceAssistantWarnings function.
 * - ProvideVoiceAssistantWarningsOutput - The return type for the provideVoiceAssistantWarnings function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const ProvideVoiceAssistantWarningsInputSchema = z.object({
  dri: z.number().describe('The current Driver Risk Index (DRI).'),
});
export type ProvideVoiceAssistantWarningsInput = z.infer<typeof ProvideVoiceAssistantWarningsInputSchema>;

const ProvideVoiceAssistantWarningsOutputSchema = z.object({
  warning: z.string().describe('The voice warning message to be spoken.'),
});
export type ProvideVoiceAssistantWarningsOutput = z.infer<typeof ProvideVoiceAssistantWarningsOutputSchema>;

export async function provideVoiceAssistantWarnings(input: ProvideVoiceAssistantWarningsInput): Promise<ProvideVoiceAssistantWarningsOutput> {
  return provideVoiceAssistantWarningsFlow(input);
}

const voiceAssistantPrompt = ai.definePrompt({
  name: 'voiceAssistantPrompt',
  input: {schema: ProvideVoiceAssistantWarningsInputSchema},
  output: {schema: ProvideVoiceAssistantWarningsOutputSchema},
  prompt: `You are a voice assistant in a driver safety application. Your job is to provide a short, clear, and direct warning to the driver when their Driver Risk Index (DRI) is high, indicating fatigue.

  Current DRI: {{{dri}}}

  If the DRI is greater than 70, you must generate a warning that is direct and urges action. Examples: "Fatigue detected. Pull over and rest now.", "High risk of falling asleep. Take a break immediately.", "You are too tired to drive safely. Please stop.". If the DRI is 70 or less, return an empty string.
  `,
});

const provideVoiceAssistantWarningsFlow = ai.defineFlow(
  {
    name: 'provideVoiceAssistantWarningsFlow',
    inputSchema: ProvideVoiceAssistantWarningsInputSchema,
    outputSchema: ProvideVoiceAssistantWarningsOutputSchema,
  },
  async input => {
    const {output} = await voiceAssistantPrompt(input);
    return output!;
  }
);
