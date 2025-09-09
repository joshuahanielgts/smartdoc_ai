'use client';

import { useState, useRef } from 'react';
import { Lightbulb, Volume2, Loader2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getSafetyTips, getSpeech } from '@/lib/actions';
import type { Alert, DriHistoryPoint } from '@/lib/types';

type SafetyTipsProps = {
  history: DriHistoryPoint[];
  alerts: Alert[];
};

export function SafetyTips({ history, alerts }: SafetyTipsProps) {
  const [tips, setTips] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  const playAudio = (audioDataUri: string) => {
    if (audioRef.current) {
      audioRef.current.pause();
    }
    const audio = new Audio(audioDataUri);
    audioRef.current = audio;
    audio.play();
    setIsSpeaking(true);
    audio.onended = () => {
      setIsSpeaking(false);
      audioRef.current = null;
    };
  };

  const handleGenerateTips = async () => {
    setIsLoading(true);
    setTips('');
    const driHistory = history.map((p) => p.dri).join(',');
    const alertFrequency = alerts.length;
    const generatedTips = await getSafetyTips(driHistory, alertFrequency);
    setTips(generatedTips);
    setIsLoading(false);

    if (generatedTips) {
      try {
        const audioData = await getSpeech(generatedTips);
        playAudio(audioData);
      } catch (error) {
        console.error("Failed to generate or play speech for tips:", error);
      }
    }
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
        <div className="flex items-center gap-2">
          <Button onClick={handleGenerateTips} disabled={isLoading || isSpeaking} variant="secondary" className="bg-primary hover:bg-primary/90 text-primary-foreground">
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Generating...
              </>
            ) : (
              'Generate Tips'
            )}
          </Button>
          {isSpeaking && <Volume2 className="h-5 w-5 text-primary animate-pulse" />}
        </div>
      </CardContent>
    </Card>
  );
}
