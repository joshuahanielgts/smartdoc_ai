'use client';

import { useEffect, useRef, useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Video, VideoOff, UserX } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

type WebcamFeedProps = {
  isMonitoring: boolean;
  isHumanPresent: boolean;
};

export function WebcamFeed({ isMonitoring, isHumanPresent }: WebcamFeedProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [hasCameraPermission, setHasCameraPermission] = useState<boolean | null>(null);
  const { toast } = useToast();

  useEffect(() => {
    const getCameraPermission = async () => {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        setHasCameraPermission(false);
        return;
      }
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: true });
        streamRef.current = stream;
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
        setHasCameraPermission(true);
      } catch (error) {
        console.error('Error accessing camera:', error);
        setHasCameraPermission(false);
        toast({
            variant: 'destructive',
            title: 'Camera Access Denied',
            description: 'Please enable camera permissions in your browser settings.',
        });
      }
    };

    const stopCamera = () => {
      if (streamRef.current) {
        streamRef.current.getTracks().forEach((track) => track.stop());
        streamRef.current = null;
        if(videoRef.current) videoRef.current.srcObject = null;
      }
    };

    if (isMonitoring) {
      getCameraPermission();
    } else {
      stopCamera();
    }

    return () => {
      stopCamera();
    };
  }, [isMonitoring, toast]);

  return (
    <Card className="h-full glass-card">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-base font-medium text-foreground">Live Feed</CardTitle>
        {isMonitoring ? <Video className="h-5 w-5 text-primary" /> : <VideoOff className="h-5 w-5 text-muted-foreground" /> }
      </CardHeader>
      <CardContent className="relative aspect-video">
        <video ref={videoRef} className="w-full aspect-video rounded-md bg-muted/50" autoPlay muted playsInline />
        {!isMonitoring && hasCameraPermission !== false && (
          <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-lg">
             <div className="flex flex-col items-center gap-2 text-muted-foreground">
                <VideoOff className="h-10 w-10" />
                <p>Camera is off</p>
                 <p className="text-xs">Click "Start Monitoring" to begin.</p>
            </div>
          </div>
        )}
        {isMonitoring && !isHumanPresent && (
          <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-lg">
            <div className="flex flex-col items-center gap-2 text-muted-foreground">
              <UserX className="h-10 w-10" />
              <p>No human present</p>
            </div>
          </div>
        )}
        {hasCameraPermission === false && (
          <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-lg">
            <Alert variant="destructive" className="w-auto">
              <AlertTitle>Camera Access Required</AlertTitle>
              <AlertDescription>Please allow camera access.</AlertDescription>
            </Alert>
          </div>
        )}
        {isMonitoring && (
          <div className="absolute bottom-2 right-2 flex items-center gap-2 rounded-full bg-destructive/80 px-3 py-1 text-xs text-destructive-foreground">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-destructive-foreground opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-destructive-foreground"></span>
            </span>
            REC
          </div>
        )}
      </CardContent>
    </Card>
  );
}
