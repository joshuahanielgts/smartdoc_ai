'use client';

import { useEffect, useRef, useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Video } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

export function WebcamFeed() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [hasCameraPermission, setHasCameraPermission] = useState<boolean | null>(null);
  const { toast } = useToast();
  const toastId = useRef<string | null>(null);

  useEffect(() => {
    const getCameraPermission = async () => {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        setHasCameraPermission(false);
        return;
      }

      try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: true });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
        setHasCameraPermission(true);
      } catch (error) {
        console.error('Error accessing camera:', error);
        setHasCameraPermission(false);
      }
    };

    getCameraPermission();
  }, []);

  useEffect(() => {
    if (hasCameraPermission === false) {
      if (!toastId.current) {
        const { id } = toast({
          variant: 'destructive',
          title: 'Camera Access Denied',
          description: 'Please enable camera permissions in your browser settings to use this feature.',
        });
        toastId.current = id;
      }
    }
  }, [hasCameraPermission, toast]);

  return (
    <Card className="h-full bg-card/10 backdrop-blur-lg border-white/20">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-base font-medium text-foreground">Live Feed</CardTitle>
        <Video className="h-5 w-5 text-muted-foreground" />
      </CardHeader>
      <CardContent className="relative aspect-video">
        <video ref={videoRef} className="w-full aspect-video rounded-md" autoPlay muted playsInline />
        {hasCameraPermission === false && (
          <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-lg">
            <Alert variant="destructive" className="w-auto">
              <AlertTitle>Camera Access Required</AlertTitle>
              <AlertDescription>Please allow camera access to use this feature.</AlertDescription>
            </Alert>
          </div>
        )}
        <div className="absolute bottom-2 right-2 flex items-center gap-2 rounded-full bg-destructive/80 px-3 py-1 text-xs text-destructive-foreground">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-destructive-foreground opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-destructive-foreground"></span>
          </span>
          REC
        </div>
      </CardContent>
    </Card>
  );
}
