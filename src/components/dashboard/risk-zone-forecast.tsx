'use client';

import { useState } from 'react';
import { Map, Loader2, Hospital, Building, Phone, MapPin } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { getHighRiskZonePrediction } from '@/lib/actions';
import { useToast } from '@/hooks/use-toast';
import type { EmergencyService } from '@/lib/types';

export function RiskZoneForecast() {
  const [services, setServices] = useState<EmergencyService[]>([]);
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

  const getIconForService = (serviceType: 'Hospital' | 'Police Station') => {
    if (serviceType === 'Hospital') {
      return <Hospital className="h-6 w-6 shrink-0 text-red-500" />;
    }
    return <Building className="h-6 w-6 shrink-0 text-blue-500" />;
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
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
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
        {services.length > 0 && !isLoading && (
          <div className="space-y-4">
            {services.map((service, index) => (
              <div key={index} className="flex flex-col gap-3 p-3 rounded-lg bg-muted/30 border border-white/10">
                <div className="flex items-start gap-4">
                   {getIconForService(service.type)}
                   <div className="flex-1">
                     <p className="font-semibold text-foreground">{service.name}</p>
                     <p className="text-sm text-muted-foreground">{service.address}</p>
                   </div>
                </div>
                <div className="flex items-center gap-2 pl-10">
                  <Button variant="outline" size="sm" asChild className="flex-1">
                    <a href={`tel:${service.phone}`}>
                      <Phone className="mr-2 h-4 w-4" /> Call
                    </a>
                  </Button>
                  <Button variant="outline" size="sm" asChild className="flex-1">
                    <a href={service.mapsUrl} target="_blank" rel="noopener noreferrer">
                      <MapPin className="mr-2 h-4 w-4" /> Directions
                    </a>
                  </Button>
                </div>
              </div>
            ))}
          </div>
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
