-- ============================================================
-- NOCKNOCK Darbo žurnalas — pilnas DB setup
-- Paleisk Supabase SQL Editor
-- ============================================================

-- 1. Klientų lentelė
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Užduočių lentelė
CREATE TABLE IF NOT EXISTS tasks (
  id BIGSERIAL PRIMARY KEY,
  day DATE NOT NULL,
  cat TEXT,
  name TEXT NOT NULL,
  note TEXT,
  qty DECIMAL DEFAULT 1,
  price DECIMAL DEFAULT 0,
  total DECIMAL DEFAULT 0,
  status TEXT DEFAULT 'done',
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  file_url TEXT,
  file_name TEXT,
  file_mime TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Jei tasks jau egzistuoja — pridėk naujus stulpelius
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS file_name TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS file_mime TEXT;

-- 3. Kliento užklausos agentūrai
CREATE TABLE IF NOT EXISTS client_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  notes TEXT,
  category TEXT DEFAULT 'other',
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Meta Ads kredencialai (TIK adminui)
CREATE TABLE IF NOT EXISTS meta_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID UNIQUE REFERENCES clients(id) ON DELETE CASCADE NOT NULL,
  account_id TEXT NOT NULL,
  access_token TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Meta Ads sinchronizuota statistika (matoma klientui)
CREATE TABLE IF NOT EXISTS meta_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID UNIQUE REFERENCES clients(id) ON DELETE CASCADE NOT NULL,
  period TEXT DEFAULT 'this_month',
  spend DECIMAL,
  impressions BIGINT,
  reach BIGINT,
  clicks BIGINT,
  ctr DECIMAL,
  cpm DECIMAL,
  roas DECIMAL,
  conversions BIGINT,
  raw JSONB,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RLS politikos
-- ============================================================

ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE meta_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE meta_stats ENABLE ROW LEVEL SECURITY;

-- Klientai
DROP POLICY IF EXISTS "clients_read_all" ON clients;
DROP POLICY IF EXISTS "clients_write_auth" ON clients;
CREATE POLICY "clients_read_all" ON clients FOR SELECT USING (true);
CREATE POLICY "clients_write_auth" ON clients FOR ALL USING (auth.role() = 'authenticated');

-- Užduotys
DROP POLICY IF EXISTS "tasks_read_all" ON tasks;
DROP POLICY IF EXISTS "tasks_write_auth" ON tasks;
CREATE POLICY "tasks_read_all" ON tasks FOR SELECT USING (true);
CREATE POLICY "tasks_write_auth" ON tasks FOR ALL USING (auth.role() = 'authenticated');

-- Kliento užklausos: visi skaito ir kuria, tik auth redaguoja
DROP POLICY IF EXISTS "requests_read_all" ON client_requests;
DROP POLICY IF EXISTS "requests_insert_all" ON client_requests;
DROP POLICY IF EXISTS "requests_manage_auth" ON client_requests;
CREATE POLICY "requests_read_all" ON client_requests FOR SELECT USING (true);
CREATE POLICY "requests_insert_all" ON client_requests FOR INSERT WITH CHECK (true);
CREATE POLICY "requests_manage_auth" ON client_requests FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "requests_delete_auth" ON client_requests FOR DELETE USING (auth.role() = 'authenticated');

-- Meta kredencialai: TIK auth
DROP POLICY IF EXISTS "meta_settings_auth" ON meta_settings;
CREATE POLICY "meta_settings_auth" ON meta_settings FOR ALL USING (auth.role() = 'authenticated');

-- Meta statistika: visi skaito, tik auth rašo
DROP POLICY IF EXISTS "meta_stats_read_all" ON meta_stats;
DROP POLICY IF EXISTS "meta_stats_write_auth" ON meta_stats;
CREATE POLICY "meta_stats_read_all" ON meta_stats FOR SELECT USING (true);
CREATE POLICY "meta_stats_write_auth" ON meta_stats FOR ALL USING (auth.role() = 'authenticated');

-- ============================================================
-- Supabase Storage: sukurk "client-files" bucket
-- Dashboard → Storage → New bucket → Name: client-files → Public: ON
-- ============================================================

-- ============================================================
-- Admin vartotojas:
-- Authentication → Users → Add user → įvesk el. paštą + slaptažodį
-- ============================================================
