import Image from 'next/image';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Video } from 'lucide-react';

export function WebcamFeed() {
  return (
    <Card className="h-full">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-base font-medium">Live Feed</CardTitle>
        <Video className="h-5 w-5 text-muted-foreground" />
      </CardHeader>
      <CardContent className="relative aspect-video">
        <Image
          src="https://picsum.photos/400/300"
          alt="Webcam feed placeholder"
          width={400}
          height={300}
          data-ai-hint="driver view road"
          className="rounded-lg object-cover"
        />
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
