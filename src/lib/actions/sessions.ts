"use server";

import { createClient } from "@/lib/supabase/server";
import type { DriHistoryPoint, Alert } from "@/lib/types";

export async function saveSession(
  userId: string,
  sessionDate: Date,
  durationMinutes: number,
  history: DriHistoryPoint[],
  alerts: Alert[]
) {
  const supabase = await createClient();

  // Calculate DRI stats
  const driValues = history.map((h) => h.dri);
  const maxDRI = Math.max(...driValues);
  const avgDRI = driValues.reduce((a, b) => a + b, 0) / driValues.length;

  // Save session metadata
  const { data: session, error: sessionError } = await supabase
    .from("driving_sessions")
    .insert({
      user_id: userId,
      session_date: sessionDate.toISOString(),
      duration_minutes: durationMinutes,
      max_dri: maxDRI,
      avg_dri: avgDRI,
      alert_count: alerts.length,
    })
    .select()
    .single();

  if (sessionError) throw sessionError;

  // Save DRI history points
  const historyRecords = history.map((point) => ({
    session_id: session.id,
    timestamp: new Date(point.time).toISOString(),
    dri_value: point.dri,
  }));

  const { error: historyError } = await supabase
    .from("dri_history")
    .insert(historyRecords);

  if (historyError) throw historyError;

  // Save alerts
  const alertRecords = alerts.map((alert) => ({
    session_id: session.id,
    alert_time: new Date(alert.time).toISOString(),
    alert_message: alert.message,
    dri_at_alert: alert.dri,
  }));

  if (alertRecords.length > 0) {
    const { error: alertsError } = await supabase
      .from("session_alerts")
      .insert(alertRecords);

    if (alertsError) throw alertsError;
  }

  return session;
}

export async function getMonthlyReport(
  userId: string,
  year: number,
  month: number
) {
  const supabase = await createClient();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0, 23, 59, 59);

  const { data: sessions, error } = await supabase
    .from("driving_sessions")
    .select(
      `
      *,
      dri_history(*),
      session_alerts(*)
    `
    )
    .eq("user_id", userId)
    .gte("session_date", startDate.toISOString())
    .lte("session_date", endDate.toISOString())
    .order("session_date", { ascending: true });

  if (error) throw error;
  return sessions;
}

export async function getUserSessions(userId: string, limit: number = 10) {
  const supabase = await createClient();

  const { data: sessions, error } = await supabase
    .from("driving_sessions")
    .select("*")
    .eq("user_id", userId)
    .order("session_date", { ascending: false })
    .limit(limit);

  if (error) throw error;
  return sessions;
}
