'use server';

/**
 * @fileOverview Generates personalized safety tips based on a driver's driving data.
 *
 * - generatePersonalizedSafetyTips - A function that generates personalized safety tips.
 * - GeneratePersonalizedSafetyTipsInput - The input type for the generatePersonalizedSafetyTips function.
 * - GeneratePersonalizedSafetyTipsOutput - The return type for the generatePersonalizedSafetyTips function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GeneratePersonalizedSafetyTipsInputSchema = z.object({
  driHistory: z
    .string()
    .describe('A comma separated list of Driver Risk Index (DRI) values over time.'),
  alertFrequency: z
    .number()
    .describe('The frequency of alerts triggered during the driving session.'),
});

export type GeneratePersonalizedSafetyTipsInput = z.infer<
  typeof GeneratePersonalizedSafetyTipsInputSchema
>;

const GeneratePersonalizedSafetyTipsOutputSchema = z.object({
  safetyTips: z
    .string()
    .describe('Personalized safety tips based on the driving data.'),
});

export type GeneratePersonalizedSafetyTipsOutput = z.infer<
  typeof GeneratePersonalizedSafetyTipsOutputSchema
>;

export async function generatePersonalizedSafetyTips(
  input: GeneratePersonalizedSafetyTipsInput
): Promise<GeneratePersonalizedSafetyTipsOutput> {
  return generatePersonalizedSafetyTipsFlow(input);
}

const prompt = ai.definePrompt({
  name: 'generatePersonalizedSafetyTipsPrompt',
  input: {schema: GeneratePersonalizedSafetyTipsInputSchema},
  output: {schema: GeneratePersonalizedSafetyTipsOutputSchema},
  prompt: `You are an AI assistant for a driver safety app. Your goal is to provide clear, concise, and actionable safety tips.

  Analyze the following driving data:
  - DRI History (a sequence of risk scores): {{{driHistory}}}
  - Alert Frequency (how many times a high-risk alert was triggered): {{{alertFrequency}}}

  Based on this data, generate 2-3 short, direct safety tips.
  - If the DRI was consistently high or spiked frequently, strongly recommend taking a break.
  - If the alert frequency is high, suggest getting more rest before driving.
  - Keep the tips focused on reducing fatigue. Be encouraging but firm.
  `,
});

const generatePersonalizedSafetyTipsFlow = ai.defineFlow(
  {
    name: 'generatePersonalizedSafetyTipsFlow',
    inputSchema: GeneratePersonalizedSafetyTipsInputSchema,
    outputSchema: GeneratePersonalizedSafetyTipsOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    return output!;
  }
);
