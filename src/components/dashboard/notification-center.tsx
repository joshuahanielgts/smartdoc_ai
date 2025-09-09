'use client';

import { useState } from 'react';
import { Bell, ShieldAlert, Lightbulb } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog';
import { ScrollArea } from '@/components/ui/scroll-area';
import { DriHistoryChart } from '@/components/dashboard/dri-history-chart';
import type { Alert, AlertContext } from '@/lib/types';

type NotificationCenterProps = {
  alerts: Alert[];
  getAlertContext: (alertId: string) => AlertContext | undefined;
};

export function NotificationCenter({ alerts, getAlertContext }: NotificationCenterProps) {
  const [selectedAlert, setSelectedAlert] = useState<{ alert: Alert; context: AlertContext } | null>(null);

  const handleAlertClick = (alert: Alert) => {
    const context = getAlertContext(alert.id);
    if (context) {
      setSelectedAlert({ alert, context });
    }
  };

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon" className="relative">
            <Bell className="h-5 w-5" />
            {alerts.length > 0 && (
              <span className="absolute top-1 right-1 flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-primary"></span>
              </span>
            )}
            <span className="sr-only">Notifications</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-80">
          <DropdownMenuLabel>Notifications</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <ScrollArea className="h-96">
            {alerts.length === 0 ? (
              <div className="p-4 text-sm text-center text-muted-foreground">No new notifications</div>
            ) : (
              alerts.map((alert) => (
                <DropdownMenuItem key={alert.id} onSelect={() => handleAlertClick(alert)} className="cursor-pointer">
                  <div className="flex items-start gap-3 p-2">
                    <div className="p-2 bg-destructive/20 rounded-full mt-1">
                      <ShieldAlert className="h-4 w-4 text-destructive" />
                    </div>
                    <div className="grid gap-1">
                      <p className="font-medium text-foreground/90 text-sm">{alert.message}</p>
                      <p className="text-xs text-muted-foreground">
                        {formatDistanceToNow(new Date(alert.time), { addSuffix: true })} at DRI {alert.dri}
                      </p>
                    </div>
                  </div>
                </DropdownMenuItem>
              ))
            )}
          </ScrollArea>
        </DropdownMenuContent>
      </DropdownMenu>

      <Dialog open={!!selectedAlert} onOpenChange={(isOpen) => !isOpen && setSelectedAlert(null)}>
        <DialogContent className="sm:max-w-2xl glass-card">
          {selectedAlert && (
            <>
              <DialogHeader>
                <DialogTitle>Alert Details</DialogTitle>
                <DialogDescription>
                  {`Alert triggered ${formatDistanceToNow(new Date(selectedAlert.alert.time), { addSuffix: true })}`}
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="space-y-4">
                  <h4 className="font-semibold">DRI History at Time of Alert</h4>
                  <DriHistoryChart history={selectedAlert.context.history} container="div" />
                </div>
                <div className="space-y-4">
                    <h4 className="font-semibold">Safety Tip Provided</h4>
                     <p className="flex items-start gap-2 text-sm text-foreground/90">
                        <Lightbulb className="h-4 w-4 mt-1 shrink-0 text-primary" />
                        <span>{selectedAlert.context.safetyTip}</span>
                    </p>
                </div>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}
