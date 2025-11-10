# Database Setup Instructions

## Setting up Supabase Database for LucidDrive AI

Follow these steps to set up your database schema in Supabase:

### Step 1: Access Supabase SQL Editor

1. Go to your Supabase project: https://supabase.com/dashboard/project/xxekhcicwwkuhtbjzjmq
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**

### Step 2: Run the Schema SQL

1. Copy the entire contents of `supabase-schema.sql`
2. Paste it into the SQL Editor
3. Click **Run** or press `Ctrl+Enter`

This will create:

- ✅ `driving_sessions` table - Stores session metadata
- ✅ `dri_history` table - Stores DRI time-series data
- ✅ `session_alerts` table - Stores alerts triggered during sessions
- ✅ Indexes for better performance
- ✅ Row Level Security (RLS) policies - Users can only see their own data
- ✅ Proper foreign key relationships

### Step 3: Verify Tables Created

1. Go to **Table Editor** in Supabase dashboard
2. You should see three new tables:
   - `driving_sessions`
   - `dri_history`
   - `session_alerts`

### Database Schema Overview

```
driving_sessions
├── id (UUID, Primary Key)
├── user_id (UUID, Foreign Key to auth.users)
├── session_date (Timestamp)
├── duration_minutes (Integer)
├── max_dri (Numeric)
├── avg_dri (Numeric)
├── alert_count (Integer)
└── created_at (Timestamp)

dri_history
├── id (UUID, Primary Key)
├── session_id (UUID, Foreign Key to driving_sessions)
├── timestamp (Timestamp)
└── dri_value (Numeric)

session_alerts
├── id (UUID, Primary Key)
├── session_id (UUID, Foreign Key to driving_sessions)
├── alert_time (Timestamp)
├── alert_message (Text)
└── dri_at_alert (Numeric)
```

### Step 4: Test the Setup

1. Sign in to your app
2. Start a monitoring session
3. Stop the session (this should save to database)
4. Go to Supabase Table Editor and verify data is saved
5. Try exporting a monthly report

### Security Features

- **Row Level Security (RLS)** is enabled on all tables
- Users can only access their own driving data
- Authentication is required to read/write data
- All operations are validated through Supabase Auth

### Troubleshooting

If you encounter errors:

1. **Error: "permission denied"**

   - Make sure RLS policies are created correctly
   - Check that you're signed in to the app

2. **Error: "relation does not exist"**

   - The SQL schema wasn't run successfully
   - Re-run the `supabase-schema.sql` script

3. **Error: "foreign key violation"**
   - Make sure the `driving_sessions` record exists before adding `dri_history` or `session_alerts`
   - The app handles this automatically, but if manually inserting data, create parent records first

### Next Steps

Once the database is set up:

1. ✅ Users can sign up/sign in
2. ✅ Driving sessions are automatically saved
3. ✅ Monthly reports can be generated and downloaded
4. ✅ All data is secure and private to each user

For any issues, check the Supabase logs in the Dashboard → Logs section.
