-- ============================================================
-- WELLNESS HUB — Supabase DB setup
-- Paleisk Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Maisto žurnalas
CREATE TABLE IF NOT EXISTS wellness_food_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  log_date DATE NOT NULL,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
  food_name TEXT NOT NULL,
  calories INT DEFAULT 0,
  portion TEXT,
  protein DECIMAL(6,1) DEFAULT 0,
  carbs DECIMAL(6,1) DEFAULT 0,
  fat DECIMAL(6,1) DEFAULT 0,
  photo_url TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Periodo žurnalas
CREATE TABLE IF NOT EXISTS wellness_period_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  log_date DATE NOT NULL UNIQUE,
  flow TEXT CHECK (flow IN ('light','medium','heavy')),
  symptoms TEXT[] DEFAULT '{}',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Nuotaikos žurnalas
CREATE TABLE IF NOT EXISTS wellness_mood_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  log_date DATE NOT NULL UNIQUE,
  mood INT CHECK (mood BETWEEN 1 AND 5),
  energy INT CHECK (energy BETWEEN 1 AND 5),
  emotions TEXT[] DEFAULT '{}',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Vaistų sąrašas
CREATE TABLE IF NOT EXISTS wellness_medications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  dosage TEXT,
  frequency TEXT DEFAULT 'Kasdien',
  color TEXT DEFAULT '#7C3AED',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Vaistų vartojimo žurnalas
CREATE TABLE IF NOT EXISTS wellness_medication_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_id UUID NOT NULL REFERENCES wellness_medications(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  taken BOOLEAN DEFAULT false,
  taken_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(medication_id, log_date)
);

-- ============================================================
-- RLS (Row Level Security) — asmeniniam naudojimui
-- ============================================================

ALTER TABLE wellness_food_logs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_period_logs     ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_mood_logs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_medications     ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_medication_logs ENABLE ROW LEVEL SECURITY;

-- Visi gali skaityti ir rašyti (asmeninis app, naudoji tik tu)
-- Jei nori apsaugos — pakeisk į auth.role() = 'authenticated'

DROP POLICY IF EXISTS "food_all" ON wellness_food_logs;
CREATE POLICY "food_all" ON wellness_food_logs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "period_all" ON wellness_period_logs;
CREATE POLICY "period_all" ON wellness_period_logs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "mood_all" ON wellness_mood_logs;
CREATE POLICY "mood_all" ON wellness_mood_logs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "meds_all" ON wellness_medications;
CREATE POLICY "meds_all" ON wellness_medications FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "med_logs_all" ON wellness_medication_logs;
CREATE POLICY "med_logs_all" ON wellness_medication_logs FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- STORAGE BUCKET
-- Supabase Dashboard → Storage → New bucket
-- Name: wellness-photos
-- Public: ON
-- Allowed MIME types: image/*
-- ============================================================
