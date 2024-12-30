import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://rxnqsqfgewuskfllijdz.supabase.co'; // Reemplaza con tu URL de Supabase
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4bnFzcWZnZXd1c2tmbGxpamR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3Nzk1MDIsImV4cCI6MjA1MDM1NTUwMn0.JaF-0fb0csILX55MxKdslU3NavNP7NmCmMwTK00I0jM'; // Reemplaza con tu clave anónima

  // Inicializa Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  
  // Getter para el cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
}

