// Supabase project settings. Both values are safe to publish: the database's
// access rules (supabase/schema.sql) decide what each visitor can change.
// Find them in Supabase under Project Settings > API Keys (publishable key).
window.MOVIE_CLUB = {
  supabaseUrl: "https://odzpsnbcztjhmqofwljv.supabase.co",
  supabaseAnonKey: "sb_publishable_94ikJzCE7WqgNnuF3UNk_Q_qpL7JpPZ",
  // Login names map to these addresses. No email is ever sent to them.
  emailDomain: "movieclub.com",
  // TMDB (themoviedb.org) key: film search, posters and details. Read-only, safe to publish.
  tmdbApiKey: "388d77b6077940f3e23b12b868c214e4",
  // Backup for details if TMDB can't be reached (omdbapi.com).
  omdbApiKey: "b57fd6a3"
};
