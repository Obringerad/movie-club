// Supabase project settings. Both values are safe to publish: the database's
// access rules (supabase/schema.sql) decide what each visitor can change.
// Find them in Supabase under Project Settings > API.
window.MOVIE_CLUB = {
  supabaseUrl: "PASTE_PROJECT_URL_HERE",
  supabaseAnonKey: "PASTE_ANON_PUBLIC_KEY_HERE",
  // Login names map to these addresses. No email is ever sent to them.
  emailDomain: "jboiz.example.com"
};
