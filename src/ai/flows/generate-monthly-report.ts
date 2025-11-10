import { ai } from "@/ai/genkit";
import { z } from "genkit";

const GenerateMonthlyReportInputSchema = z.object({
  userId: z.string(),
  month: z.string().describe("Month name (e.g., January)"),
  year: z.number(),
  totalSessions: z.number(),
  totalDrivingHours: z.number(),
  averageDRI: z.number(),
  maxDRI: z.number(),
  totalAlerts: z.number(),
  sessionsData: z.string().describe("JSON string of session data"),
});

const GenerateMonthlyReportOutputSchema = z.object({
  summary: z
    .string()
    .describe("Comprehensive monthly summary (2-3 paragraphs)"),
  insights: z
    .array(z.string())
    .describe("Key insights from the month (3-5 points)"),
  recommendations: z
    .array(z.string())
    .describe("Safety recommendations (3-5 points)"),
  overallScore: z.number().describe("Overall safety score out of 100"),
});

const monthlyReportPrompt = ai.definePrompt({
  name: "monthlyReportPrompt",
  input: { schema: GenerateMonthlyReportInputSchema },
  output: { schema: GenerateMonthlyReportOutputSchema },
  prompt: `You are an AI safety analyst for LucidDrive AI, a driver monitoring system. Generate a comprehensive monthly driving report.

**Driving Statistics:**
- Month: {{{month}}} {{{year}}}
- Total Sessions: {{{totalSessions}}}
- Total Driving Hours: {{{totalDrivingHours}}}
- Average DRI: {{{averageDRI}}}
- Maximum DRI: {{{maxDRI}}}
- Total Alerts: {{{totalAlerts}}}

**Sessions Data:**
{{{sessionsData}}}

**Note:** DRI (Driver Risk Index) ranges from 0-100:
- 0-40: Low Risk (Safe driving)
- 41-70: Moderate Risk (Caution needed)
- 71-100: High Risk (Unsafe, immediate action required)

Provide:
1. **Summary**: A comprehensive 2-3 paragraph analysis of the month's driving performance
2. **Insights**: 3-5 key insights about driving patterns, trends, and areas of concern
3. **Recommendations**: 3-5 actionable safety recommendations based on the data
4. **Overall Score**: A safety score out of 100 based on DRI values, alerts, and driving patterns`,
});

export const generateMonthlyReport = ai.defineFlow(
  {
    name: "generateMonthlyReport",
    inputSchema: GenerateMonthlyReportInputSchema,
    outputSchema: GenerateMonthlyReportOutputSchema,
  },
  async (input) => {
    const { output } = await monthlyReportPrompt(input);
    return output!;
  }
);
