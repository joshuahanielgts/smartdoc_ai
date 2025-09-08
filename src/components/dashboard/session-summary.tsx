'use client';

import { useState, useEffect } from 'react';
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
  autoGenerate?: boolean;
};

export function SessionSummary({ history, alerts, autoGenerate = false }: SessionSummaryProps) {
  const [summary, setSummary] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);

  const handleGenerateSummary = async () => {
    setIsLoading(true);
    setSummary('');

    const driValues = history.map((p) => p.dri);
    if (driValues.length === 0) {
        setSummary("No driving data was recorded for this session.");
        setIsLoading(false);
        return;
    }
    const maxDRI = Math.max(...driValues, 0);
    const averageDRI = driValues.length > 0 ? Math.round(driValues.reduce((a, b) => a + b, 0) / driValues.length) : 0;
    
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

  useEffect(() => {
    if (autoGenerate) {
      handleGenerateSummary();
    }
  }, [autoGenerate]);


  return (
    <Card className="bg-card/10 backdrop-blur-lg border-white/20">
      <CardHeader>
        <CardTitle className="text-foreground">Session Summary</CardTitle>
        <CardDescription className="text-muted-foreground">An AI-powered summary of your driving session.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading && (
          <div className="space-y-2">
            <Skeleton className="h-4 w-full bg-muted/50" />
            <Skeleton className="h-4 w-4/5 bg-muted/50" />
            <Skeleton className="h-4 w-full bg-muted/50" />
            <Skeleton className="h-4 w-3/5 bg-muted/50" />
          </div>
        )}
        {summary && !isLoading && (
          <div className="text-sm text-foreground/90 space-y-2 prose prose-invert prose-p:my-1">
            <p className="flex items-start gap-3">
              <BookText className="h-4 w-5 mt-1 shrink-0 text-primary" />
              <span>{summary}</span>
            </p>
          </div>
        )}
        {!summary && !isLoading && (
           <div className="text-sm text-muted-foreground text-center py-4">
             { autoGenerate ? 'Generating summary...' : 'Click the button to generate a session summary.'}
          </div>
        )}
        {!autoGenerate && (
            <Button onClick={handleGenerateSummary} disabled={isLoading} variant="secondary" className="bg-primary/80 hover:bg-primary text-primary-foreground">
                {isLoading ? 'Generating...' : 'Generate Summary'}
            </Button>
        )}
      </CardContent>
    </Card>
  );
}
