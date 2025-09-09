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
  latitude: z.number().describe('The latitude of the driver.'),
  longitude: z.number().describe('The longitude of the driver.'),
});
export type PredictHighRiskZonesInput = z.infer<typeof PredictHighRiskZonesInputSchema>;

const PredictHighRiskZonesOutputSchema = z.object({
  emergencyServices: z.array(z.string()).describe('A list of nearby emergency services.'),
});
export type PredictHighRiskZonesOutput = z.infer<typeof PredictHighRiskZonesOutputSchema>;

export async function predictHighRiskZones(input: PredictHighRiskZonesInput): Promise<PredictHighRiskZonesOutput> {
  return predictHighRiskZonesFlow(input);
}

const prompt = ai.definePrompt({
  name: 'predictHighRiskZonesPrompt',
  input: {schema: PredictHighRiskZonesInputSchema},
  output: {schema: PredictHighRiskZonesOutputSchema},
  prompt: `You are an emergency service locator. Based on the provided GPS coordinates, identify the two closest hospitals and the single closest police station.

  Driver's Location:
  - Latitude: {{{latitude}}}
  - Longitude: {{{longitude}}}

  Provide a list of these three locations. For each, specify if it is a "Hospital" or "Police Station" and provide a realistic, fictional name and address for the purpose of this simulation.

  Example format for the output array:
  - "Hospital: Mercy General Hospital, 123 Health St, Cityville"
  - "Hospital: City Central Hospital, 456 Care Ave, Cityville"
  - "Police Station: 1st Precinct, 789 Law Blvd, Cityville"
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
