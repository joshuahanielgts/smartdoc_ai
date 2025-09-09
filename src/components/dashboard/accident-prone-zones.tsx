'use client';

import { useState } from 'react';
import { MapPin, TrafficCone, Loader2, TriangleAlert } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getAccidentProneZones as getAccidentProneZonesAction } from '@/lib/actions';
import { useToast } from '@/hooks/use-toast';
import type { AccidentProneZone } from '@/lib/types';
import { Badge } from '@/components/ui/badge';

export function AccidentProneZones() {
  const [zones, setZones] = useState<AccidentProneZone[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const { toast } = useToast();

  const handlePredict = () => {
    setIsLoading(true);
    setZones([]);

    if (!navigator.geolocation) {
      toast({
        variant: 'destructive',
        title: 'Geolocation Not Supported',
        description: 'Your browser does not support geolocation.',
      });
      setIsLoading(false);
      return;
    }

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords;
        const result = await getAccidentProneZonesAction(latitude, longitude);
        setZones(result.zones);
        setIsLoading(false);
      },
      (error) => {
        console.error('Geolocation Error:', error);
        toast({
          variant: 'destructive',
          title: 'Location Access Denied',
          description: 'Please enable location permissions in your browser settings.',
        });
        setIsLoading(false);
      }
    );
  };

  const getRiskBadgeVariant = (riskLevel: 'High' | 'Medium' | 'Low') => {
    switch (riskLevel) {
      case 'High':
        return 'destructive';
      case 'Medium':
        return 'secondary';
      case 'Low':
        return 'default';
      default:
        return 'outline';
    }
  };

  return (
    <Card className="glass-card">
      <CardHeader>
        <CardTitle className="text-foreground">Accident Prone Zones</CardTitle>
        <CardDescription className="text-muted-foreground">
          Identify high-risk driving areas nearby.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading && (
          <div className="space-y-4">
            {[...Array(2)].map((_, i) => (
              <div key={i} className="flex items-center gap-4">
                <Skeleton className="h-10 w-10 rounded-lg bg-muted/50" />
                <div className="space-y-2 flex-1">
                  <Skeleton className="h-4 w-3/4 bg-muted/50" />
                  <Skeleton className="h-4 w-1/2 bg-muted/50" />
                </div>
              </div>
            ))}
          </div>
        )}
        {zones.length > 0 && !isLoading && (
          <div className="space-y-3">
            {zones.map((zone, index) => (
              <div key={index} className="flex flex-col gap-2 p-3 rounded-lg bg-muted/30 border border-white/10">
                 <div className="flex items-start gap-3">
                    <TriangleAlert className="h-5 w-5 shrink-0 text-amber-500 mt-0.5" />
                    <div className="flex-1">
                      <div className="flex justify-between items-center">
                         <p className="font-semibold text-foreground">{zone.name}</p>
                         <Badge variant={getRiskBadgeVariant(zone.riskLevel)}>{zone.riskLevel}</Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">{zone.description}</p>
                    </div>
                 </div>
              </div>
            ))}
          </div>
        )}
        {!isLoading && zones.length === 0 && (
          <div className="text-sm text-muted-foreground text-center py-4">
            Click to check for nearby accident-prone zones.
          </div>
        )}
        <Button onClick={handlePredict} disabled={isLoading} variant="secondary">
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Analyzing...
            </>
          ) : (
            'Check for Zones'
          )}
        </Button>
      </CardContent>
    </Card>
  );
}
