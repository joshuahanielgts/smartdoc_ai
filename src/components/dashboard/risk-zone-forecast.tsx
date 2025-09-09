'use client';

import { useState } from 'react';
import { Map, Loader2, Hospital, Building } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getHighRiskZonePrediction } from '@/lib/actions';
import { useToast } from '@/hooks/use-toast';

export function RiskZoneForecast() {
  const [services, setServices] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const { toast } = useToast();

  const handlePredict = () => {
    setIsLoading(true);
    setServices([]);

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
        const result = await getHighRiskZonePrediction(latitude, longitude);
        setServices(result.emergencyServices);
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

  const getIconForService = (service: string) => {
    if (service.toLowerCase().startsWith('hospital')) {
      return <Hospital className="h-5 w-5 shrink-0 text-red-500" />;
    }
    if (service.toLowerCase().startsWith('police')) {
      return <Building className="h-5 w-5 shrink-0 text-blue-500" />;
    }
    return <Map className="h-4 w-4 mt-1 shrink-0 text-amber-400" />;
  };

  return (
    <Card className="glass-card">
      <CardHeader>
        <CardTitle className="text-foreground">Emergency Services Nearby</CardTitle>
        <CardDescription className="text-muted-foreground">
          Find nearby hospitals and police stations based on your current location.
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
        {services.length > 0 && !isLoading && (
          <ul className="text-sm text-foreground space-y-3">
            {services.map((service, index) => (
              <li key={index} className="flex items-center gap-3">
                {getIconForService(service)}
                <span>{service}</span>
              </li>
            ))}
          </ul>
        )}
        {!isLoading && services.length === 0 && (
          <div className="text-sm text-muted-foreground text-center py-4">
            Click the button to find local emergency services.
          </div>
        )}
        <Button onClick={handlePredict} disabled={isLoading} variant="secondary">
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Locating...
            </>
          ) : (
            'Find Services'
          )}
        </Button>
      </CardContent>
    </Card>
  );
}
