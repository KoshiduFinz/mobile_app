import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://nhpuauletjycserfautv.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ocHVhdWxldGp5Y3NlcmZhdXR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0ODYxMTcsImV4cCI6MjA3MTA2MjExN30.v3bbkSJ4lIKUVF1mdURiAC4KGrAImiZz8dwNS_lWRao',
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }
  
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first. Error: $e');
    }
  }
}
