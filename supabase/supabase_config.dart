import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {

  static const String url = 'https://nfwrufhlsrkkhgnizcaa.supabase.co';
  static const String publishableKey = 'sb_publishable_z9tPnFqmBztWYG1cfnRHPQ_vni82KBf';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }
}

final supabase = Supabase.instance.client;