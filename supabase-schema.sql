-- LucidDrive AI Database Schema
-- Run this SQL in your Supabase SQL Editor

-- Create driving_sessions table
CREATE TABLE IF NOT EXISTS driving_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  session_date TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  max_dri NUMERIC(5,2) NOT NULL,
  avg_dri NUMERIC(5,2) NOT NULL,
  alert_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create dri_history table
CREATE TABLE IF NOT EXISTS dri_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES driving_sessions(id) ON DELETE CASCADE NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL,
  dri_value NUMERIC(5,2) NOT NULL
);

-- Create session_alerts table
CREATE TABLE IF NOT EXISTS session_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES driving_sessions(id) ON DELETE CASCADE NOT NULL,
  alert_time TIMESTAMPTZ NOT NULL,
  alert_message TEXT NOT NULL,
  dri_at_alert NUMERIC(5,2) NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_driving_sessions_user_id ON driving_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_driving_sessions_session_date ON driving_sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_dri_history_session_id ON dri_history(session_id);
CREATE INDEX IF NOT EXISTS idx_session_alerts_session_id ON session_alerts(session_id);

-- Enable Row Level Security
ALTER TABLE driving_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE dri_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_alerts ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies for driving_sessions
CREATE POLICY "Users can view own sessions"
  ON driving_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions"
  ON driving_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
  ON driving_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sessions"
  ON driving_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- Create RLS Policies for dri_history
CREATE POLICY "Users can view own DRI history"
  ON dri_history FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM driving_sessions
      WHERE driving_sessions.id = dri_history.session_id
      AND driving_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own DRI history"
  ON dri_history FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM driving_sessions
      WHERE driving_sessions.id = dri_history.session_id
      AND driving_sessions.user_id = auth.uid()
    )
  );

-- Create RLS Policies for session_alerts
CREATE POLICY "Users can view own alerts"
  ON session_alerts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM driving_sessions
      WHERE driving_sessions.id = session_alerts.session_id
      AND driving_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own alerts"
  ON session_alerts FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM driving_sessions
      WHERE driving_sessions.id = session_alerts.session_id
      AND driving_sessions.user_id = auth.uid()
    )
  );

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO postgres, anon, authenticated, service_role;
