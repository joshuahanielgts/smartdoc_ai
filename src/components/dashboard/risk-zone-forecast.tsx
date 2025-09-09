'use client';

import { useState } from 'react';
import { Map, Loader2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getHighRiskZonePrediction } from '@/lib/actions';

export function RiskZoneForecast() {
  const [zones, setZones] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const handlePredict = async () => {
    setIsLoading(true);
    setZones([]);
    // Using mock historical data for the simulation
    const mockHistory = ['Downtown financial district', 'Highway 101 junction', 'Main Street & 5th Ave'];
    const result = await getHighRiskZonePrediction('user-001', mockHistory);
    setZones(result.predictedZones);
    setIsLoading(false);
  };

  return (
    <Card className="glass-card">
      <CardHeader>
        <CardTitle className="text-foreground">Risk Zone Forecast</CardTitle>
        <CardDescription className="text-muted-foreground">
          Predict high-risk zones based on historical data.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading && (
          <div className="space-y-2">
            <Skeleton className="h-4 w-full bg-muted/50" />
            <Skeleton className="h-4 w-4/5 bg-muted/50" />
            <Skeleton className="h-4 w-full bg-muted/50" />
          </div>
        )}
        {zones.length > 0 && !isLoading && (
          <ul className="text-sm text-foreground space-y-2">
            {zones.map((zone, index) => (
              <li key={index} className="flex items-start gap-2">
                <Map className="h-4 w-4 mt-1 shrink-0 text-amber-400" />
                <span>{zone}</span>
              </li>
            ))}
          </ul>
        )}
        {!isLoading && zones.length === 0 && (
          <div className="text-sm text-muted-foreground text-center py-4">
            Click the button to forecast potential high-risk zones.
          </div>
        )}
        <Button onClick={handlePredict} disabled={isLoading} variant="secondary">
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Forecasting...
            </>
          ) : (
            'Forecast Zones'
          )}
        </Button>
      </CardContent>
    </Card>
  );
}
