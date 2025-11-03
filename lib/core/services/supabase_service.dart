import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url:
          'https://rldhovodfjzlalnlbjwo.supabase.co', // 🔑 Ganti dengan URL project
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsZGhvdm9kZmp6bGFsbmxiandvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4NzQ4MDEsImV4cCI6MjA3NzQ1MDgwMX0.KhoHd3q2EevMSSqNfJxe2XO3X6wn0niALIBqkP52ERE', // 🔑 Ganti dengan anon key
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
