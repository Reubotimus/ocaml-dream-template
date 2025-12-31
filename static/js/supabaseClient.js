import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = "https://ybdeqyezvbdipkiocngl.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliZGVxeWV6dmJkaXBraW9jbmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5MTcwMzIsImV4cCI6MjA4MjQ5MzAzMn0.ECzSkeTMnkky93lkBsKwAioNs7WeiEgd7xzm2RMhxvE";

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
