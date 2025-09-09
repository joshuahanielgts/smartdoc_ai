'use server';

/**
 * @fileOverview Identifies accident-prone zones based on GPS coordinates.
 *
 * - getAccidentProneZones - A function that identifies accident-prone zones.
 * - GetAccidentProneZonesInput - The input type for the getAccidentProneZones function.
 * - GetAccidentProneZonesOutput - The return type for the getAccidentProneZones function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GetAccidentProneZonesInputSchema = z.object({
  latitude: z.number().describe('The latitude of the driver.'),
  longitude: z.number().describe('The longitude of the driver.'),
});
export type GetAccidentProneZonesInput = z.infer<typeof GetAccidentProneZonesInputSchema>;

const ZoneSchema = z.object({
  name: z.string().describe('The name or identifier of the accident-prone zone.'),
  description: z.string().describe('A brief description of why this zone is high-risk.'),
  riskLevel: z.enum(['High', 'Medium', 'Low']).describe('The assessed risk level of the zone.'),
});

const GetAccidentProneZonesOutputSchema = z.object({
  zones: z.array(ZoneSchema).describe('A list of nearby accident-prone zones.'),
});
export type GetAccidentProneZonesOutput = z.infer<typeof GetAccidentProneZonesOutputSchema>;

export async function getAccidentProneZones(
  input: GetAccidentProneZonesInput
): Promise<GetAccidentProneZonesOutput> {
  return getAccidentProneZonesFlow(input);
}

const prompt = ai.definePrompt({
  name: 'getAccidentProneZonesPrompt',
  input: {schema: GetAccidentProneZonesInputSchema},
  output: {schema: GetAccidentProneZonesOutputSchema},
  prompt: `You are a traffic safety analyst. Based on the provided GPS coordinates, which you should assume are in or near Vadapalani, Chennai, India, identify known accident-prone zones from the list below.

  Driver's Location:
  - Latitude: {{{latitude}}}
  - Longitude: {{{longitude}}}

  Use ONLY the following information for your response. Do not invent new zones.

  - Zone 1:
    - Name: Arcot Road Junction
    - Description: Heavy traffic congestion and frequent signal violations. High pedestrian activity.
    - RiskLevel: High
  - Zone 2:
    - Name: Jawaharlal Nehru Road (100 Feet Road)
    - Description: High-speed corridor with multiple intersections. Risk of speeding and lane indiscipline.
    - RiskLevel: High
  - Zone 3:
    - Name: Vadapalani Bus Depot Entrance/Exit
    - Description: Congestion due to frequent bus movement and pedestrian cross-traffic.
    - RiskLevel: Medium
  
  Return a list of these three zones.`,
});

const getAccidentProneZonesFlow = ai.defineFlow(
  {
    name: 'getAccidentProneZonesFlow',
    inputSchema: GetAccidentProneZonesInputSchema,
    outputSchema: GetAccidentProneZonesOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    return output!;
  }
);
