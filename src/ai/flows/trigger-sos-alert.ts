'use server';
/**
 * @fileOverview Triggers an SOS alert to emergency services.
 *
 * - triggerSOSAlert - A function that triggers an SOS alert.
 * - TriggerSOSAlertInput - The input type for the triggerSOSAlert function.
 * - TriggerSOSAlertOutput - The return type for the triggerSOSAlert function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const TriggerSOSAlertInputSchema = z.object({
  driverId: z.string().describe('The ID of the driver.'),
  lastKnownLocation: z.string().describe('The last known location of the driver.'),
});
export type TriggerSOSAlertInput = z.infer<typeof TriggerSOSAlertInputSchema>;

const TriggerSOSAlertOutputSchema = z.object({
  confirmationId: z.string().describe('The confirmation ID for the dispatched SOS alert.'),
  message: z.string().describe('A message confirming the action taken.'),
});
export type TriggerSOSAlertOutput = z.infer<typeof TriggerSOSAlertOutputSchema>;

export async function triggerSOSAlert(input: TriggerSOSAlertInput): Promise<TriggerSOSAlertOutput> {
  return triggerSOSAlertFlow(input);
}

const prompt = ai.definePrompt({
  name: 'triggerSOSAlertPrompt',
  input: {schema: TriggerSOSAlertInputSchema},
  output: {schema: TriggerSOSAlertOutputSchema},
  prompt: `You are an emergency dispatch system. An SOS has been triggered for a driver.

  Driver ID: {{{driverId}}}
  Last Known Location: {{{lastKnownLocation}}}

  Generate a confirmation message indicating that emergency services have been dispatched to the location. Create a unique confirmation ID for this event.

  Example output:
  - confirmationId: "SOS-2024-XYZ-123"
  - message: "Emergency services have been dispatched to [Last Known Location]. Help is on the way."
  `,
});


const triggerSOSAlertFlow = ai.defineFlow(
  {
    name: 'triggerSOSAlertFlow',
    inputSchema: TriggerSOSAlertInputSchema,
    outputSchema: TriggerSOSAlertOutputSchema,
  },
  async input => {
    // In a real application, this would contact an emergency service API.
    // For this simulation, we'll just generate the confirmation.
    const {output} = await prompt(input);
    return output!;
  }
);
