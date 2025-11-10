"use server";

import { createClient } from "@/lib/supabase/server";

/**
 * Generate sample driving sessions for testing purposes
 * This creates realistic mock data for the current month
 */
export async function generateSampleData(userId: string) {
  const supabase = await createClient();

  // Generate 10 sample sessions for current month
  const currentDate = new Date();
  const sessionsToCreate = [];

  for (let i = 0; i < 10; i++) {
    const sessionDate = new Date(
      currentDate.getFullYear(),
      currentDate.getMonth(),
      Math.floor(Math.random() * 28) + 1, // Random day of month
      Math.floor(Math.random() * 12) + 8, // Random hour between 8am-8pm
      Math.floor(Math.random() * 60)
    );

    const durationMinutes = Math.floor(Math.random() * 60) + 15; // 15-75 minutes
    const avgDRI = Math.floor(Math.random() * 60) + 20; // 20-80 DRI
    const maxDRI = avgDRI + Math.floor(Math.random() * 20); // Max higher than avg
    const alertCount =
      maxDRI > 70
        ? Math.floor(Math.random() * 5) + 1
        : Math.floor(Math.random() * 2);

    sessionsToCreate.push({
      user_id: userId,
      session_date: sessionDate.toISOString(),
      duration_minutes: durationMinutes,
      max_dri: maxDRI,
      avg_dri: avgDRI,
      alert_count: alertCount,
    });
  }

  // Insert all sessions
  const { data: sessions, error } = await supabase
    .from("driving_sessions")
    .insert(sessionsToCreate)
    .select();

  if (error) {
    throw error;
  }

  return sessions;
}
