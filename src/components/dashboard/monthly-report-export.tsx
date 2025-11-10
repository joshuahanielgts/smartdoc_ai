"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Download, Loader2, Plus } from "lucide-react";
import { generateMonthlyPDFReport } from "@/lib/actions/report";
import { generateSampleData } from "@/lib/actions/sample-data";
import { Alert, AlertDescription } from "@/components/ui/alert";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

type MonthlyReportExportProps = {
  userId: string;
};

export function MonthlyReportExport({ userId }: MonthlyReportExportProps) {
  const [loading, setLoading] = useState(false);
  const [generatingSample, setGeneratingSample] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());

  const months = [
    { value: 1, label: "January" },
    { value: 2, label: "February" },
    { value: 3, label: "March" },
    { value: 4, label: "April" },
    { value: 5, label: "May" },
    { value: 6, label: "June" },
    { value: 7, label: "July" },
    { value: 8, label: "August" },
    { value: 9, label: "September" },
    { value: 10, label: "October" },
    { value: 11, label: "November" },
    { value: 12, label: "December" },
  ];

  const currentYear = new Date().getFullYear();
  const years = Array.from({ length: 5 }, (_, i) => currentYear - i);

  const handleExport = async () => {
    setError(null);
    setSuccess(null);
    setLoading(true);

    try {
      const pdfDataUri = await generateMonthlyPDFReport(
        userId,
        selectedYear,
        selectedMonth
      );

      // Download the PDF
      const link = document.createElement("a");
      link.href = pdfDataUri;
      link.download = `LucidDrive_Report_${
        months[selectedMonth - 1].label
      }_${selectedYear}.pdf`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      setSuccess("Report downloaded successfully!");
    } catch (err: any) {
      console.error("Failed to generate report:", err);

      let errorMessage =
        err.message || "Failed to generate report. Please try again.";

      // Add helpful context for common errors
      if (
        errorMessage.includes("Database tables not set up") ||
        errorMessage.includes("relation")
      ) {
        errorMessage =
          "⚠️ Database Setup Required: Please run the SQL schema from 'supabase-schema.sql' in your Supabase SQL Editor. See DATABASE_SETUP.md for instructions.";
      } else if (errorMessage.includes("No driving sessions found")) {
        errorMessage =
          "📊 No data available for this month. Use 'Generate Sample Data' button or start monitoring to collect driving data!";
      }

      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleGenerateSample = async () => {
    setError(null);
    setSuccess(null);
    setGeneratingSample(true);

    try {
      await generateSampleData(userId);
      setSuccess(
        "✅ Successfully generated 10 sample driving sessions for this month! Now you can download the report."
      );
    } catch (err: any) {
      console.error("Failed to generate sample data:", err);

      let errorMessage = err.message || "Failed to generate sample data.";

      if (errorMessage.includes("relation") || errorMessage.includes("table")) {
        errorMessage =
          "⚠️ Database tables not found. Please run the SQL schema from 'supabase-schema.sql' in your Supabase SQL Editor first.";
      }

      setError(errorMessage);
    } finally {
      setGeneratingSample(false);
    }
  };

  return (
    <Card className="border-white/10 bg-card/50 backdrop-blur-xl">
      <CardHeader>
        <CardTitle>Export Monthly Report</CardTitle>
        <CardDescription>
          Generate a comprehensive PDF report with AI-powered insights and
          driving statistics
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Month</label>
            <Select
              value={selectedMonth.toString()}
              onValueChange={(value) => setSelectedMonth(parseInt(value))}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {months.map((month) => (
                  <SelectItem key={month.value} value={month.value.toString()}>
                    {month.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Year</label>
            <Select
              value={selectedYear.toString()}
              onValueChange={(value) => setSelectedYear(parseInt(value))}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {years.map((year) => (
                  <SelectItem key={year} value={year.toString()}>
                    {year}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        {error && (
          <Alert variant="destructive" className="text-left">
            <AlertDescription className="whitespace-pre-wrap">
              {error}
            </AlertDescription>
          </Alert>
        )}

        {success && (
          <Alert className="text-left border-green-500 bg-green-500/10">
            <AlertDescription className="text-green-400">
              {success}
            </AlertDescription>
          </Alert>
        )}

        <div className="grid grid-cols-2 gap-3">
          <Button
            variant="outline"
            onClick={handleGenerateSample}
            disabled={generatingSample || loading}
            className="w-full"
          >
            {generatingSample ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Generating...
              </>
            ) : (
              <>
                <Plus className="mr-2 h-4 w-4" />
                Sample Data
              </>
            )}
          </Button>

          <Button
            onClick={handleExport}
            disabled={loading || generatingSample}
            className="w-full"
          >
            {loading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Generating...
              </>
            ) : (
              <>
                <Download className="mr-2 h-4 w-4" />
                Download
              </>
            )}
          </Button>
        </div>

        <p className="text-xs text-muted-foreground text-center">
          First time? Click "Sample Data" to generate test sessions, then
          "Download"
        </p>
      </CardContent>
    </Card>
  );
}
