'use client';

import { Activity } from 'lucide-react';
import { Area, AreaChart, CartesianGrid, XAxis, YAxis } from 'recharts';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '@/components/ui/chart';
import type { DriHistoryPoint } from '@/lib/types';

type DriHistoryChartProps = {
  history: DriHistoryPoint[];
};

export function DriHistoryChart({ history }: DriHistoryChartProps) {
  const chartConfig = {
    dri: {
      label: 'DRI',
      color: 'hsl(var(--primary))',
    },
  };
  
  const chartData = history.map(point => ({
    time: new Date(point.time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    dri: point.dri,
  }));

  return (
    <Card className="glass-card">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <div>
          <CardTitle className="text-foreground">DRI History</CardTitle>
          <CardDescription className="text-muted-foreground">Driver Risk Index over the current session</CardDescription>
        </div>
        <Activity className="h-5 w-5 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <ChartContainer config={chartConfig} className="h-64 w-full">
          <AreaChart
            accessibilityLayer
            data={chartData}
            margin={{
              left: 12,
              right: 12,
              top: 10,
            }}
          >
            <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="hsla(var(--border), 0.5)" />
            <XAxis
              dataKey="time"
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              tickFormatter={(value) => value.slice(0, 5)}
              stroke="hsl(var(--foreground))"
            />
            <YAxis
              domain={[0, 100]}
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              stroke="hsl(var(--foreground))"
            />
            <ChartTooltip
              cursor={false}
              content={
                <ChartTooltipContent
                  indicator="dot"
                  labelFormatter={(label, payload) => {
                    return payload[0]?.payload.time || label;
                  }}
                  className="bg-background/80 backdrop-blur-sm"
                />
              }
            />
            <defs>
              <linearGradient id="fillGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-dri)" stopOpacity={0.8} />
                <stop offset="95%" stopColor="var(--color-dri)" stopOpacity={0.1} />
              </linearGradient>
            </defs>
            <Area
              dataKey="dri"
              type="natural"
              fill="url(#fillGradient)"
              stroke="var(--color-dri)"
              stackId="a"
            />
          </AreaChart>
        </ChartContainer>
      </CardContent>
    </Card>
  );
}
