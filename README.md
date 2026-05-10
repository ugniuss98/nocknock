# Darbo žurnalas

Agentūros savaitinių darbų sekimo įrankis. Adminas įveda užduotis, klientas mato savo peržiūros puslapį realiu laiku.

## Funkcijos

- **Multi-klientų sistema** — kiekvienas klientas gauna savo unikalią nuorodą
- **Admin prisijungimas** — apsaugotas Supabase Auth slaptažodžiu
- **Realaus laiko atnaujinimas** — klientas mato pakeitimus iš karto
- **Savaitės navigacija** — peržiūra pagal savaitę
- **PDF / spausdinimas** — savaitės ataskaita vienu paspaudimu
- **Kopijuoti ataskaitą** — teksto formatas el. paštui ar žinutei

## Supabase setup

### 1. Paleisk SQL

Supabase Dashboard → **SQL Editor** → paleisk `setup.sql`:

```sql
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tasks ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id) ON DELETE SET NULL;

ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "clients_read_all" ON clients FOR SELECT USING (true);
CREATE POLICY "tasks_read_all" ON tasks FOR SELECT USING (true);
CREATE POLICY "clients_write_auth" ON clients FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "tasks_write_auth" ON tasks FOR ALL USING (auth.role() = 'authenticated');
```

### 2. Sukurk admin vartotoją

Supabase Dashboard → **Authentication** → **Users** → **Add user**

Įvesk el. paštą ir slaptažodį — tai bus tavo admin prisijungimas.

### 3. Įjunk Email auth

Supabase Dashboard → **Authentication** → **Providers** → **Email** → įjungta.

## Naudojimas

| Failas | URL | Aprašas |
|--------|-----|---------|
| `admin.html` | `/admin.html` | Admin — prisijungimas, užduočių valdymas |
| `index.html` | `/index.html?c=SLUG` | Kliento peržiūra (tik skaityti) |

### Workflow

1. Atidaryti `admin.html` → prisijungti
2. Paspausti **+** šalia kliento pasirinkimo → įvesti kliento pavadinimą
3. Pasirinkti klientą → pridėti užduotis
4. Paspausti **Kopijuoti** šalia kliento nuorodos → išsiųsti klientui
5. Klientas atidaro savo nuorodą ir mato viską realiu laiku

## Deploy (GitHub Pages)

1. GitHub repo → **Settings** → **Pages**
2. Source: `main` branch, `/ (root)`
3. Tavo admin URL: `https://USERNAME.github.io/REPO/admin.html`
4. Kliento URL pavyzdys: `https://USERNAME.github.io/REPO/index.html?c=uab-pavyzdys`
