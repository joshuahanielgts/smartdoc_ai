'use client';

import { useState } from 'react';
import { BookText } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getDailySummary } from '@/lib/actions';
import type { Alert, DriHistoryPoint } from '@/lib/types';
import { getSafetyTips } from '@/lib/actions';

type SessionSummaryProps = {
  history: DriHistoryPoint[];
  alerts: Alert[];
};

export function SessionSummary({ history, alerts }: SessionSummaryProps) {
  const [summary, setSummary] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);

  const handleGenerateSummary = async () => {
    setIsLoading(true);
    setSummary('');

    const driValues = history.map((p) => p.dri);
    const maxDRI = Math.max(...driValues, 0);
    const averageDRI = driValues.length > 0 ? Math.round(driValues.reduce((a, b) => a + b, 0) / driValues.length) : 0;
    
    // For the demo, we'll re-generate tips for the summary
    const tipsText = await getSafetyTips(driValues.join(','), alerts.length);
    const safetyTips = tipsText.split('\n').map(t => t.replace(/^- /, ''));

    const generatedSummary = await getDailySummary({
      driverId: 'user-001',
      date: new Date().toISOString().split('T')[0],
      maxDRI,
      averageDRI,
      alertFrequency: alerts.length,
      safetyTips,
    });
    setSummary(generatedSummary);
    setIsLoading(false);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Daily Session Summary</CardTitle>
        <CardDescription>Generate an AI-powered summary of your driving session.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading && (
          <div className="space-y-2">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-4/5" />
            <Skeleton className="h-4 w-full" />
             <Skeleton className="h-4 w-3/5" />
          </div>
        )}
        {summary && !isLoading && (
          <div className="text-sm text-foreground space-y-2">
            <p className="flex items-start gap-2">
              <BookText className="h-4 w-4 mt-1 shrink-0 text-primary" />
              <span>{summary}</span>
            </p>
          </div>
        )}
        {!summary && !isLoading && (
           <div className="text-sm text-muted-foreground text-center py-4">
            Click the button to generate a session summary.
          </div>
        )}
        <Button onClick={handleGenerateSummary} disabled={isLoading}>
          {isLoading ? 'Generating...' : 'Generate Daily Summary'}
        </Button>
      </CardContent>
    </Card>
  );
}
