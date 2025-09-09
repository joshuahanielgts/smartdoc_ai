'use server';
/**
 * @fileOverview Predicts high-risk driving zones using a machine learning model.
 *
 * - predictHighRiskZones - A function that predicts high-risk zones.
 * - PredictHighRiskZonesInput - The input type for the predictHighRiskZones function.
 * - PredictHighRiskZonesOutput - The return type for the predictHighRiskZones function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const PredictHighRiskZonesInputSchema = z.object({
  driverId: z.string().describe('The ID of the driver.'),
  historicalData: z.array(z.string()).describe('A list of historical locations or routes.'),
});
export type PredictHighRiskZonesInput = z.infer<typeof PredictHighRiskZonesInputSchema>;

const PredictHighRiskZonesOutputSchema = z.object({
  predictedZones: z.array(z.string()).describe('A list of predicted high-risk zones.'),
});
export type PredictHighRiskZonesOutput = z.infer<typeof PredictHighRiskZonesOutputSchema>;

export async function predictHighRiskZones(input: PredictHighRiskZonesInput): Promise<PredictHighRiskZonesOutput> {
  return predictHighRiskZonesFlow(input);
}

const prompt = ai.definePrompt({
  name: 'predictHighRiskZonesPrompt',
  input: {schema: PredictHighRiskZonesInputSchema},
  output: {schema: PredictHighRiskZonesOutputSchema},
  prompt: `You are a predictive analytics model for driver safety. Your task is to identify high-risk driving zones.

  Based on the provided historical driving data, predict three potential high-risk zones for the upcoming trips. These zones could be specific intersections, stretches of highway, or general areas known for congestion or accidents.

  Historical Data: {{#each historicalData}} - {{{this}}}{{/each}}

  For this simulation, provide three realistic but fictional high-risk zones. For example: "Intersection of Oak St and Pine Ave due to morning congestion", "Highway 101, mile 45, known for sharp curves", "Downtown district during evening rush hour".
  `,
});

const predictHighRiskZonesFlow = ai.defineFlow(
  {
    name: 'predictHighRiskZonesFlow',
    inputSchema: PredictHighRiskZonesInputSchema,
    outputSchema: PredictHighRiskZonesOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    return output!;
  }
);
