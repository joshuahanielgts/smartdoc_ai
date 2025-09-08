'use client';

import { useState } from 'react';
import { Lightbulb } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getSafetyTips } from '@/lib/actions';
import type { Alert, DriHistoryPoint } from '@/lib/types';

type SafetyTipsProps = {
  history: DriHistoryPoint[];
  alerts: Alert[];
};

export function SafetyTips({ history, alerts }: SafetyTipsProps) {
  const [tips, setTips] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);

  const handleGenerateTips = async () => {
    setIsLoading(true);
    setTips('');
    const driHistory = history.map((p) => p.dri).join(',');
    const alertFrequency = alerts.length;
    const generatedTips = await getSafetyTips(driHistory, alertFrequency);
    setTips(generatedTips);
    setIsLoading(false);
  };

  return (
    <Card className="glass-card">
      <CardHeader>
        <CardTitle className="text-foreground">Personalized Safety Tips</CardTitle>
        <CardDescription className="text-muted-foreground">AI-generated advice based on your driving data.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading && (
          <div className="space-y-2">
            <Skeleton className="h-4 w-full bg-muted/50" />
            <Skeleton className="h-4 w-4/5 bg-muted/50" />
            <Skeleton className="h-4 w-full bg-muted/50" />
          </div>
        )}
        {tips && !isLoading && (
          <div className="text-sm text-foreground space-y-2">
            {tips.split('\n').map((tip, index) => (
              <p key={index} className="flex items-start gap-2">
                <Lightbulb className="h-4 w-4 mt-1 shrink-0 text-primary" />
                <span>{tip.replace(/^- /, '')}</span>
              </p>
            ))}
          </div>
        )}
        {!tips && !isLoading && (
          <div className="text-sm text-muted-foreground text-center py-4">
            Click the button to generate personalized tips.
          </div>
        )}
        <Button onClick={handleGenerateTips} disabled={isLoading} variant="secondary" className="bg-primary/80 hover:bg-primary text-primary-foreground">
          {isLoading ? 'Generating...' : 'Generate Tips'}
        </Button>
      </CardContent>
    </Card>
  );
}
