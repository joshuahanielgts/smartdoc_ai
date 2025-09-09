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

const ServiceSchema = z.object({
  name: z.string().describe('The name of the emergency service.'),
  type: z.enum(['Hospital', 'Police Station']).describe('The type of service.'),
  address: z.string().describe('The full address of the service.'),
  phone: z.string().describe('A realistic, fictional phone number for the service.'),
  mapsUrl: z.string().url().describe('A valid Google Maps URL for the address.'),
});

const PredictHighRiskZonesOutputSchema = z.object({
  emergencyServices: z
    .array(ServiceSchema)
    .describe('A list of nearby emergency services.'),
});
export type PredictHighRiskZonesOutput = z.infer<typeof PredictHighRiskZonesOutputSchema>;

export async function predictHighRiskZones(
  input: PredictHighRiskZonesInput
): Promise<PredictHighRiskZonesOutput> {
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

  For each service, provide a realistic, fictional name, address, phone number, and a valid Google Maps URL for the address.
  - The phone number should be in a plausible local format.
  - The Google Maps URL should be a proper URL pointing to the address.

  Return the list of these three locations.`,
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
