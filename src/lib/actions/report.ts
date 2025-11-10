"use server";

import { jsPDF } from "jspdf";
import { getMonthlyReport } from "./sessions";
import { generateMonthlyReport } from "@/ai/flows/generate-monthly-report";

export async function generateMonthlyPDFReport(
  userId: string,
  year: number,
  month: number
) {
  try {
    // Get data from Supabase
    const sessions = await getMonthlyReport(userId, year, month);

    if (!sessions || sessions.length === 0) {
      throw new Error(
        "No driving sessions found for this month. Start monitoring to collect data!"
      );
    }

    // Calculate stats
    const totalHours =
      sessions.reduce((sum, s) => sum + s.duration_minutes, 0) / 60;
    const avgDRI =
      sessions.reduce((sum, s) => sum + s.avg_dri, 0) / sessions.length;
    const maxDRI = Math.max(...sessions.map((s) => s.max_dri));
    const totalAlerts = sessions.reduce((sum, s) => sum + s.alert_count, 0);

    const monthName = new Date(year, month - 1).toLocaleString("default", {
      month: "long",
    });

    // Generate AI insights
    const aiReport = await generateMonthlyReport({
      userId,
      month: monthName,
      year,
      totalSessions: sessions.length,
      totalDrivingHours: parseFloat(totalHours.toFixed(2)),
      averageDRI: parseFloat(avgDRI.toFixed(2)),
      maxDRI: parseFloat(maxDRI.toFixed(2)),
      totalAlerts,
      sessionsData: JSON.stringify(
        sessions.slice(0, 10).map((s) => ({
          date: s.session_date,
          duration: s.duration_minutes,
          avgDRI: s.avg_dri,
          maxDRI: s.max_dri,
          alerts: s.alert_count,
        }))
      ),
    });

    // Create PDF
    const doc = new jsPDF();

    // Header
    doc.setFillColor(30, 58, 138); // Blue background
    doc.rect(0, 0, 210, 40, "F");
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(28);
    doc.text("LucidDrive AI", 105, 20, { align: "center" });
    doc.setFontSize(16);
    doc.text("Monthly Driving Report", 105, 30, { align: "center" });

    // Month and Year
    doc.setFontSize(14);
    doc.setTextColor(100, 116, 139);
    doc.text(`${monthName} ${year}`, 105, 50, { align: "center" });

    // Stats Section
    let yPos = 65;
    doc.setFontSize(16);
    doc.setTextColor(0, 0, 0);
    doc.text("Driving Statistics", 20, yPos);
    yPos += 10;

    doc.setFontSize(11);
    doc.setTextColor(60, 60, 60);

    const stats = [
      { label: "Total Sessions:", value: sessions.length.toString() },
      { label: "Total Driving Hours:", value: totalHours.toFixed(1) },
      {
        label: "Average DRI:",
        value: avgDRI.toFixed(1),
        color: getColorForDRI(avgDRI),
      },
      {
        label: "Maximum DRI:",
        value: maxDRI.toFixed(1),
        color: getColorForDRI(maxDRI),
      },
      { label: "Total Alerts:", value: totalAlerts.toString() },
    ];

    stats.forEach((stat) => {
      doc.setTextColor(60, 60, 60);
      doc.text(stat.label, 25, yPos);
      if (stat.color) {
        doc.setTextColor(...stat.color);
      }
      doc.text(stat.value, 80, yPos);
      yPos += 8;
    });

    // Overall Score
    yPos += 5;
    doc.setFontSize(14);
    doc.setTextColor(0, 0, 0);
    doc.text("Overall Safety Score", 20, yPos);
    yPos += 10;
    doc.setFontSize(24);
    const scoreColor = getColorForScore(aiReport.overallScore);
    doc.setTextColor(...scoreColor);
    doc.text(`${aiReport.overallScore}/100`, 25, yPos);

    // AI Summary
    yPos += 15;
    doc.setFontSize(16);
    doc.setTextColor(0, 0, 0);
    doc.text("AI Analysis", 20, yPos);
    yPos += 10;

    doc.setFontSize(10);
    doc.setTextColor(40, 40, 40);
    const splitSummary = doc.splitTextToSize(aiReport.summary, 170);
    doc.text(splitSummary, 20, yPos);
    yPos += splitSummary.length * 5 + 10;

    // Check if we need a new page
    if (yPos > 240) {
      doc.addPage();
      yPos = 20;
    }

    // Key Insights
    doc.setFontSize(16);
    doc.setTextColor(0, 0, 0);
    doc.text("Key Insights", 20, yPos);
    yPos += 10;

    doc.setFontSize(10);
    doc.setTextColor(40, 40, 40);
    aiReport.insights.forEach((insight, index) => {
      if (yPos > 270) {
        doc.addPage();
        yPos = 20;
      }
      const bulletPoint = `${index + 1}. ${insight}`;
      const splitInsight = doc.splitTextToSize(bulletPoint, 165);
      doc.text(splitInsight, 25, yPos);
      yPos += splitInsight.length * 5 + 5;
    });

    // Check if we need a new page
    if (yPos > 240) {
      doc.addPage();
      yPos = 20;
    }

    // Recommendations
    yPos += 5;
    doc.setFontSize(16);
    doc.setTextColor(0, 0, 0);
    doc.text("Safety Recommendations", 20, yPos);
    yPos += 10;

    doc.setFontSize(10);
    doc.setTextColor(40, 40, 40);
    aiReport.recommendations.forEach((rec, index) => {
      if (yPos > 270) {
        doc.addPage();
        yPos = 20;
      }
      const bulletPoint = `${index + 1}. ${rec}`;
      const splitRec = doc.splitTextToSize(bulletPoint, 165);
      doc.text(splitRec, 25, yPos);
      yPos += splitRec.length * 5 + 5;
    });

    // Footer
    const pageCount = doc.getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(150, 150, 150);
      doc.text(
        `Generated by LucidDrive AI | Page ${i} of ${pageCount} | ${new Date().toLocaleDateString()}`,
        105,
        290,
        { align: "center" }
      );
    }

    // Return as base64
    return doc.output("datauristring");
  } catch (error: any) {
    console.error("Error generating PDF report:", error);

    // Check if it's a database error
    if (error.message?.includes("relation") || error.code === "42P01") {
      throw new Error(
        "Database tables not set up. Please run the SQL schema from supabase-schema.sql in your Supabase dashboard."
      );
    }

    // Re-throw with more context
    throw new Error(
      error.message || "Failed to generate report. Please try again."
    );
  }
}

function getColorForDRI(dri: number): [number, number, number] {
  if (dri > 70) return [239, 68, 68]; // Red
  if (dri > 40) return [245, 158, 11]; // Amber
  return [16, 185, 129]; // Green
}

function getColorForScore(score: number): [number, number, number] {
  if (score >= 80) return [16, 185, 129]; // Green
  if (score >= 60) return [245, 158, 11]; // Amber
  return [239, 68, 68]; // Red
}
