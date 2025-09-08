'use server';

/**
 * @fileOverview Generates a daily summary of driving sessions, including key stats and safety advice.
 *
 * - generateDailySessionSummary - A function that generates the daily session summary.
 * - GenerateDailySessionSummaryInput - The input type for the generateDailySessionSummary function.
 * - GenerateDailySessionSummaryOutput - The return type for the generateDailySessionSummary function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GenerateDailySessionSummaryInputSchema = z.object({
  driverId: z.string().describe('The ID of the driver.'),
  date: z.string().describe('The date for which to generate the summary (YYYY-MM-DD).'),
  maxDRI: z.number().describe('The maximum Driver Risk Index (DRI) reached during the day.'),
  averageDRI: z.number().describe('The average Driver Risk Index (DRI) during the day.'),
  alertFrequency: z
    .number()
    .describe('The frequency of alerts triggered during the day.'),
  safetyTips: z.array(z.string()).describe('An array of safety tips to include in the summary.'),
});
export type GenerateDailySessionSummaryInput = z.infer<
  typeof GenerateDailySessionSummaryInputSchema
>;

const GenerateDailySessionSummaryOutputSchema = z.object({
  summary: z.string().describe('The generated daily session summary.'),
});
export type GenerateDailySessionSummaryOutput = z.infer<
  typeof GenerateDailySessionSummaryOutputSchema
>;

export async function generateDailySessionSummary(
  input: GenerateDailySessionSummaryInput
): Promise<GenerateDailySessionSummaryOutput> {
  return generateDailySessionSummaryFlow(input);
}

const generateDailySessionSummaryPrompt = ai.definePrompt({
  name: 'generateDailySessionSummaryPrompt',
  input: {schema: GenerateDailySessionSummaryInputSchema},
  output: {schema: GenerateDailySessionSummaryOutputSchema},
  prompt: `You are an AI assistant that generates daily summaries of driving sessions.

  Based on the driver's performance data for the day, including the maximum DRI, average DRI, alert frequency, and any specific safety tips, create a concise and informative summary.

  The summary should highlight key statistics, potential areas for improvement, and personalized safety advice.

  Driver ID: {{{driverId}}}
  Date: {{{date}}}
  Maximum DRI: {{{maxDRI}}}
  Average DRI: {{{averageDRI}}}
  Alert Frequency: {{{alertFrequency}}}
  Safety Tips: {{#each safetyTips}} - {{{this}}}{{/each}}

  Summary:`,
});

const generateDailySessionSummaryFlow = ai.defineFlow(
  {
    name: 'generateDailySessionSummaryFlow',
    inputSchema: GenerateDailySessionSummaryInputSchema,
    outputSchema: GenerateDailySessionSummaryOutputSchema,
  },
  async input => {
    const {output} = await generateDailySessionSummaryPrompt(input);
    return output!;
  }
);
