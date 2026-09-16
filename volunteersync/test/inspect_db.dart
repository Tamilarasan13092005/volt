import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://mspciorhvkjxsfllnvwn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zcGNpb3JodmtqeHNmbGxudnduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjA4ODAsImV4cCI6MjA5NTY5Njg4MH0.1TCj_TOGpYQJeFc4n6SodqMzd6ZqKTTeJ5YDBVc9RUQ',
  );

  print('--- TESTING PROFILES PREFERENCES COLUMN ---');
  try {
    final res = await supabase.from('profiles').select('preferences').limit(1);
    print('profiles has preferences column! Result: $res');
  } catch (e) {
    print('profiles preferences check error: $e');
  }

  print('--- TESTING SQL EXECUTION RPCS ---');
  for (final name in ['exec', 'run_sql', 'execute_sql', 'sql', 'query']) {
    try {
      final res = await supabase.rpc(name, params: {'query': 'SELECT 1;'});
      print('RPC $name exists and succeeded! Result: $res');
    } catch (e) {
      print('RPC $name check failed: $e');
    }
  }
}
