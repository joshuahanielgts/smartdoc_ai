'use client';

import { useState } from 'react';
import { useDriverMonitoring } from '@/hooks/use-driver-monitoring';
import { DashboardHeader } from '@/components/dashboard/dashboard-header';
import { WebcamFeed } from '@/components/dashboard/webcam-feed';
import { DriMeter } from '@/components/dashboard/dri-meter';
import { AlertLog } from '@/components/dashboard/alert-log';
import { DriHistoryChart } from '@/components/dashboard/dri-history-chart';
import { SafetyTips } from '@/components/dashboard/safety-tips';
import { SessionSummary } from '@/components/dashboard/session-summary';

export default function DashboardPage() {
  const [isMonitoring, setIsMonitoring] = useState(false);
  const { dri, history, alerts, startMonitoring, stopMonitoring } = useDriverMonitoring(isMonitoring);
  const [showSummary, setShowSummary] = useState(false);

  const handleStart = () => {
    setShowSummary(false);
    setIsMonitoring(true);
    startMonitoring();
  };

  const handleStop = () => {
    setIsMonitoring(false);
    stopMonitoring();
    setShowSummary(true);
  };

  return (
    <div className="flex flex-col min-h-screen bg-transparent text-foreground">
      <DashboardHeader 
        isMonitoring={isMonitoring}
        onStart={handleStart}
        onStop={handleStop}
      />
      <main className="flex-1 p-4 md:p-6 lg:p-8">
        {showSummary && !isMonitoring ? (
          <div className="max-w-4xl mx-auto mt-8">
             <SessionSummary history={history} alerts={alerts} autoGenerate={true} />
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6 md:grid-cols-3 lg:grid-cols-4">
            <div className="lg:col-span-2 xl:col-span-3 flex flex-col gap-6">
              <DriHistoryChart history={history} />
              <AlertLog alerts={alerts} />
              <SafetyTips history={history} alerts={alerts} />
            </div>
            <div className="lg:col-span-1 xl:col-span-1 flex flex-col gap-6">
              <WebcamFeed isMonitoring={isMonitoring} />
              <DriMeter dri={dri} />
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
