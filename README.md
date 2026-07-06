# Darbo žurnalas

Agentūros savaitinių darbų sekimo įrankis. Adminas įveda užduotis, klientas mato savo peržiūros puslapį realiu laiku.

## Funkcijos

- **Multi-klientų sistema** — kiekvienas klientas gauna savo unikalią nuorodą
- **Admin prisijungimas** — apsaugotas Supabase Auth slaptažodžiu
- **Realaus laiko atnaujinimas** — klientas mato pakeitimus iš karto
- **Savaitės navigacija** — peržiūra pagal savaitę
- **PDF / spausdinimas** — savaitės ataskaita vienu paspaudimu
- **Kopijuoti ataskaitą** — teksto formatas el. paštui ar žinutei
- **Facebook & Instagram ataskaitos** — pasirenkamo laikotarpio statistika su automatiniu palyginimu ir PDF eksportu

## Facebook & Instagram ataskaitos

Admin skiltis **Ataskaitos** sugeneruoja kliento FB puslapio ir IG verslo paskyros
ataskaitą už pasirinktą laikotarpį ir **automatiškai palygina su ankstesniu tokios pat
trukmės laikotarpiu** (pvz. Birželis vs Gegužė, arba pask. 30 d. vs prieš tai buvusios 30 d.).
Kiekvienai metrikai rodomas pokytis % ir stulpelinis grafikas.

### Prisijungimas

Facebook ir Instagram naudoja **atskirus** prieigos raktus:

- **Facebook** — [Graph API Explorer](https://developers.facebook.com/tools/explorer/),
  teisės: `pages_read_engagement`, `read_insights`.
- **Instagram** — atskiras tokenas per **Instagram API su Instagram Login**
  (`graph.instagram.com`), teisės: `instagram_basic`, `instagram_manage_insights`.
  Jei IG verslo paskyra susieta su FB puslapiu, atskiro IG tokeno gali ir nereikėti.

### Naudojimas

1. Admin → **Ataskaitos** tab → pasirink klientą.
2. Įklijuok **Facebook** tokeną → **Įkelti puslapius** → pasirink puslapį.
3. (Nebūtina) Įklijuok **Instagram** tokeną → **Prijungti IG paskyrą**.
4. Prisijungimas **automatiškai išsaugomas naršyklėje** (localStorage). Norint dalintis
   tarp įrenginių — **Išsaugoti debesyje** (įrašo į `fb_report_settings` lentelę).
5. Pasirink **laikotarpį** (praėjęs mėnuo / šis mėnuo / 7 / 30 / 90 d. / pasirinktinai).
6. **Generuoti ataskaitą** → matai KPI korteles su grafikais.
   **Atsisiųsti PDF** atidaro spausdinimo langą (Išsaugoti kaip PDF) su grafikais;
   **Kopijuoti tekstą** paruošia tekstą žinutei/el. paštui.

> Graph API Explorer tokenai trumpaamžiai (~1–2 val.). Ilgalaikiam naudojimui
> iškeisk į „long-lived" tokeną (Access Token Tool) ir įklijuok iš naujo, kai baigsis.
> Metrikos, kurių paskyra ar API versija nepalaiko, tyliai praleidžiamos; jei paskyra
> laikotarpiu neturėjo aktyvumo, visos reikšmės bus 0.

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
