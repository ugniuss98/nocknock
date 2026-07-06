# Darbo žurnalas

Agentūros savaitinių darbų sekimo įrankis. Adminas įveda užduotis, klientas mato savo peržiūros puslapį realiu laiku.

## Funkcijos

- **Multi-klientų sistema** — kiekvienas klientas gauna savo unikalią nuorodą
- **Admin prisijungimas** — apsaugotas Supabase Auth slaptažodžiu
- **Realaus laiko atnaujinimas** — klientas mato pakeitimus iš karto
- **Savaitės navigacija** — peržiūra pagal savaitę
- **PDF / spausdinimas** — savaitės ataskaita vienu paspaudimu
- **Kopijuoti ataskaitą** — teksto formatas el. paštui ar žinutei
- **Facebook & Instagram ataskaitos** — praėjusio mėnesio statistika su palyginimu prieš tai buvusį mėnesį (Graph API)

## Facebook & Instagram ataskaitos

Admin skiltis **Ataskaitos** sugeneruoja kliento FB puslapio ir IG verslo paskyros
mėnesio ataskaitą ir automatiškai palygina praėjusį mėnesį su dar prieš tai buvusiu
(pvz. Birželis vs Gegužė) — kiekvienai metrikai parodo pokytį %.

### Nustatymas

1. Eik į [Graph API Explorer](https://developers.facebook.com/tools/explorer/) ir
   sugeneruok prieigos raktą (token) su teisėmis:
   `pages_read_engagement`, `read_insights`, `instagram_basic`, `instagram_manage_insights`.
2. Admin → **Ataskaitos** tab → pasirink klientą → įklijuok tokeną → **Įkelti puslapius**.
3. Pasirink kliento Facebook puslapį (susietas Instagram paskyros ID paimamas automatiškai) →
   **Išsaugoti prisijungimą** (įrašoma į `fb_report_settings` lentelę kiekvienam klientui).
4. **Generuoti ataskaitą** — duomenys traukiami tiesiai iš Facebook Graph API naršyklėje.
   **Kopijuoti tekstą** paruošia ataskaitą siuntimui klientui.

> Graph API Explorer tokenai trumpaamžiai (~1–2 val.). Ilgalaikiam naudojimui
> iškeisk jį į „long-lived" tokeną (Access Token Tool) ir įklijuok iš naujo, kai baigsis.
> Metrikos, kurių paskyra ar API versija nepalaiko, tyliai praleidžiamos.

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
