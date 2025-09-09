
'use client';

import { Play, Square, Siren } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { NotificationCenter } from '@/components/dashboard/notification-center';
import type { Alert, AlertContext } from '@/lib/types';
import { ThemeToggle } from '@/components/theme-toggle';

type DashboardHeaderProps = {
  isMonitoring: boolean;
  onStart: () => void;
  onStop: () => void;
  alerts: Alert[];
  getAlertContext: (alertId: string) => AlertContext | undefined;
};

export function DashboardHeader({ isMonitoring, onStart, onStop, alerts, getAlertContext }: DashboardHeaderProps) {
  const handleSosClick = () => {
    window.location.href = 'tel:+919667745648';
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-white/10 bg-transparent px-4 backdrop-blur-sm md:px-8">
      <div className="flex items-center gap-3">
        <h1 className="text-xl font-bold text-foreground">LucidDrive AI</h1>
      </div>
      <div className="flex items-center gap-4">
        {!isMonitoring ? (
          <Button size="sm" onClick={onStart} className="bg-primary hover:bg-primary/90 text-primary-foreground">
            <Play className="mr-2 h-4 w-4" /> Start Monitoring
          </Button>
        ) : (
          <Button size="sm" onClick={onStop} variant="destructive">
            <Square className="mr-2 h-4 w-4" /> Stop Monitoring
          </Button>
        )}
        <Button size="sm" variant="outline" onClick={handleSosClick} className="border-amber-500 text-amber-500 hover:bg-amber-500/10 hover:text-amber-400">
           <Siren className="mr-2 h-4 w-4" />
          Trigger SOS
        </Button>
        <NotificationCenter alerts={alerts} getAlertContext={getAlertContext} />
        <ThemeToggle />
      </div>
    </header>
  );
}
