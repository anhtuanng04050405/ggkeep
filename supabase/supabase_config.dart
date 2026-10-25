import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {

  static const String url = '';
  static const String publishableKey = '';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }
}

final supabase = Supabase.instance.client;