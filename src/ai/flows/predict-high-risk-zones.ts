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
  prompt: `You are an emergency service locator. Based on the provided GPS coordinates, which you should assume are in Vadapalani, Chennai, India, identify the two closest hospitals and the single closest police station using the exact information provided below.

  Driver's Location:
  - Latitude: {{{latitude}}}
  - Longitude: {{{longitude}}}

  Use ONLY the following information for your response. Do not use any other hospital or police station names.

  - Hospital 1:
    - Name: SIMS Hospital
    - Address: No.1, Jawaharlal Nehru Salai, 100 Feet Road, Vadapalani, Chennai, Tamil Nadu 600026
    - Phone: "+91 44 4921 2121"
    - Google Maps URL: "https://www.google.com/maps/search/?api=1&query=SIMS+Hospital+Vadapalani"

  - Hospital 2:
    - Name: Kauvery Hospital
    - Address: 100 Feet Rd, opp. to Vadapalani Metro Station, Vadapalani, Chennai, Tamil Nadu 600026
    - Phone: "+91 44 4020 6000"
    - Google Maps URL: "https://www.google.com/maps/search/?api=1&query=Kauvery+Hospital+Vadapalani"
    
  - Police Station:
    - Name: Vadapalani Police Station (H4)
    - Address: Jawaharlal Nehru Rd, opp. to SRM college, Vadapalani, Chennai, Tamil Nadu 600026
    - Phone: "+91 44 2345 2596"
    - Google Maps URL: "https://www.google.com/maps/search/?api=1&query=Vadapalani+Police+Station+H4"

  Return a list of these three locations exactly as specified.`,
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
