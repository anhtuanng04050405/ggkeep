import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = ''; // Điền URL Supabase của bạn vào đây
  static const String publishableKey = ''; // Điền Anon/Publishable Key vào đây

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }
}

SupabaseClient get supabase => Supabase.instance.client;
