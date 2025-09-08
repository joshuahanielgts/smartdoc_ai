'use client';

import { ShieldAlert } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { ScrollArea } from '@/components/ui/scroll-area';
import { formatDistanceToNow } from 'date-fns';
import type { Alert } from '@/lib/types';

type AlertLogProps = {
  alerts: Alert[];
};

export function AlertLog({ alerts }: AlertLogProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Alert Log</CardTitle>
        <CardDescription>Recent drowsiness and fatigue alerts.</CardDescription>
      </CardHeader>
      <CardContent>
        <ScrollArea className="h-64">
          {alerts.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
              <ShieldAlert className="h-10 w-10 mb-2" />
              <p>No alerts yet. Safe driving!</p>
            </div>
          ) : (
            <div className="space-y-4">
              {alerts.map((alert) => (
                <div key={alert.id} className="flex items-start gap-4">
                  <div className="p-2 bg-destructive/20 rounded-full">
                    <ShieldAlert className="h-5 w-5 text-destructive" />
                  </div>
                  <div className="grid gap-1">
                    <p className="font-medium">{alert.message}</p>
                    <p className="text-sm text-muted-foreground">
                      {formatDistanceToNow(new Date(alert.time), { addSuffix: true })} at DRI {alert.dri}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </ScrollArea>
      </CardContent>
    </Card>
  );
}
