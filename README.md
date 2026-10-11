# JBOIZ Movie Club

The club's site: next screening, schedule, ratings, pick order and vetoes.
Anyone with the link can look. Members log in with their name and a password to rate films, fill in their picks, mark films watched and veto.

- **Site:** `index.html` (+ `config.js`), hosted on GitHub Pages.
- **Data and logins:** a free Supabase project. Access rules live in `supabase/schema.sql`: members can only change their own ratings and vetoes.

## One-time setup

### 1. Create the Supabase project
1. Sign up at [supabase.com](https://supabase.com) and click **New project**.
2. Name it `jboiz-movie-club`, pick any database password (you won't need it here), choose the region nearest you, and create it.

### 2. Create the tables and load the club's data
1. In the project, open **SQL Editor** → **New query**.
2. Paste all of `supabase/schema.sql`, click **Run**.
3. New query again: paste all of `supabase/seed.sql`, click **Run**.

### 3. Turn off public sign-ups
**Authentication → Sign In / Providers**: switch off **Allow new users to sign up**. Only accounts you create can log in.

### 4. Create the 9 member accounts
**Authentication → Users → Add user → Create new user**, once per member:

| Member | Email to enter |
|---|---|
| Jared | `jared@jboiz.example.com` |
| Theo | `theo@jboiz.example.com` |
| Ella | `ella@jboiz.example.com` |
| Tim | `tim@jboiz.example.com` |
| Raito | `raito@jboiz.example.com` |
| Kwams | `kwams@jboiz.example.com` |
| Alex | `alex@jboiz.example.com` |
| Jeff | `jeff@jboiz.example.com` |
| Gio | `gio@jboiz.example.com` |

Give each one a starting password and tick **Auto Confirm User**. These addresses are placeholders; no email is ever sent. On the site, members just pick their name and type the password. They can change it after logging in.

### 5. Link the accounts to member names
SQL Editor → new query → paste `supabase/link-accounts.sql` → **Run**. Every row in the result should say `linked = true`.

### 6. Connect the site
**Project Settings → API**: copy the **Project URL** and the **anon public** key into `config.js`. Both are meant to be public; the access rules protect the data.

## Running the club

**Someone forgot their password.** SQL Editor:
```sql
update auth.users
set encrypted_password = extensions.crypt('their-new-password', extensions.gen_salt('bf'))
where email = 'ella@jboiz.example.com';
```

**Adding a member.** Add them to the members table (`pick_order` null for a guest critic), create their account as in step 4, then run `link-accounts.sql` again:
```sql
insert into public.members (name, pick_order) values ('Sam', 9);
```

**The site says the database is paused.** Free Supabase projects pause after about a week with no visits. Open the Supabase dashboard and click **Restore project**.
