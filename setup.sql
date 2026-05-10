-- ============================================================
-- NOCKNOCK Darbo žurnalas — DB setup
-- Paleisk šias komandas Supabase SQL Editor
-- ============================================================

-- 1. Sukurti klientų lentelę
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Pridėti client_id į tasks lentelę
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id) ON DELETE SET NULL;

-- 3. Įjungti Row Level Security
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- 4. Politikos: skaityti gali visi (klientų peržiūra veikia be login)
DROP POLICY IF EXISTS "clients_read_all" ON clients;
CREATE POLICY "clients_read_all" ON clients FOR SELECT USING (true);

DROP POLICY IF EXISTS "tasks_read_all" ON tasks;
CREATE POLICY "tasks_read_all" ON tasks FOR SELECT USING (true);

-- 5. Politikos: rašyti gali tik prisijungę adminai
DROP POLICY IF EXISTS "clients_write_auth" ON clients;
CREATE POLICY "clients_write_auth" ON clients FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "tasks_write_auth" ON tasks;
CREATE POLICY "tasks_write_auth" ON tasks FOR ALL USING (auth.role() = 'authenticated');

-- ============================================================
-- SVARBU: Supabase Dashboard → Authentication → Providers
-- Įjunk "Email" providerį ir sukurk admin vartotoją:
-- Authentication → Users → "Invite user" arba "Add user"
-- ============================================================
