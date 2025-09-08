'use client';

import { TrendingUp } from 'lucide-react';
import { RadialBar, RadialBarChart } from 'recharts';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { ChartContainer } from '@/components/ui/chart';

type DriMeterProps = {
  dri: number;
};

export function DriMeter({ dri }: DriMeterProps) {
  const chartData = [{ name: 'dri', value: dri, fill: 'hsl(var(--primary))' }];
  const getRiskLevel = (value: number) => {
    if (value > 70) return 'High Risk';
    if (value > 40) return 'Moderate Risk';
    return 'Low Risk';
  };
  const riskLevel = getRiskLevel(dri);

  return (
    <Card className="flex flex-col h-full">
      <CardHeader className="items-center pb-0">
        <CardTitle>Driver Risk Index</CardTitle>
        <CardDescription>{riskLevel}</CardDescription>
      </CardHeader>
      <CardContent className="flex-1 pb-0">
        <ChartContainer config={{}} className="mx-auto aspect-square max-h-[250px]">
          <RadialBarChart
            data={chartData}
            startAngle={-90}
            endAngle={270}
            innerRadius="70%"
            outerRadius="100%"
            barSize={20}
            cy="55%"
          >
            <RadialBar
              dataKey="value"
              cornerRadius={10}
              background={{ fill: 'hsl(var(--muted))' }}
            />
            <text
              x="50%"
              y="55%"
              textAnchor="middle"
              dominantBaseline="middle"
              className="fill-foreground text-5xl font-bold"
            >
              {dri}
            </text>
          </RadialBarChart>
        </ChartContainer>
      </CardContent>
      <CardFooter className="flex-col gap-2 text-sm pt-4">
        <div className="flex items-center gap-2 font-medium leading-none">
          <TrendingUp className="h-4 w-4" /> Monitoring Actively
        </div>
        <div className="leading-none text-muted-foreground">Real-time fatigue analysis</div>
      </CardFooter>
    </Card>
  );
}
