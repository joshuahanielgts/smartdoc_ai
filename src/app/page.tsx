'use client';

import { useDriverMonitoring } from '@/hooks/use-driver-monitoring';
import { DashboardHeader } from '@/components/dashboard/dashboard-header';
import { WebcamFeed } from '@/components/dashboard/webcam-feed';
import { DriMeter } from '@/components/dashboard/dri-meter';
import { AlertLog } from '@/components/dashboard/alert-log';
import { DriHistoryChart } from '@/components/dashboard/dri-history-chart';
import { SafetyTips } from '@/components/dashboard/safety-tips';
import { SessionSummary } from '@/components/dashboard/session-summary';

export default function DashboardPage() {
  const { dri, history, alerts } = useDriverMonitoring();

  return (
    <div className="flex flex-col min-h-screen bg-background text-foreground">
      <DashboardHeader />
      <main className="flex-1 p-4 md:p-6 lg:p-8">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          <div className="lg:col-span-1 xl:col-span-1 flex flex-col gap-6">
            <WebcamFeed />
            <DriMeter dri={dri} />
          </div>
          <div className="lg:col-span-2 xl:col-span-3">
            <DriHistoryChart history={history} />
          </div>
          <div className="lg:col-span-3 xl:col-span-4">
            <AlertLog alerts={alerts} />
          </div>
          <div className="lg:col-span-3 xl:col-span-2">
            <SafetyTips history={history} alerts={alerts} />
          </div>
          <div className="lg:col-span-3 xl:col-span-2">
            <SessionSummary history={history} alerts={alerts} />
          </div>
        </div>
      </main>
    </div>
  );
}
