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
  prompt: `You are an AI assistant that generates personalized safety tips for drivers based on their driving data.

  Analyze the following driving data to provide specific and actionable advice to the driver.

  DRI History: {{{driHistory}}}
  Alert Frequency: {{{alertFrequency}}}

  Based on this data, generate 3-5 personalized safety tips to help the driver improve their driving habits and reduce fatigue. Make the tips specific to the data provided.  If the DRI is high, suggest taking more breaks. If alert frequency is high, suggest getting more sleep before driving.  Be direct and to the point.
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
