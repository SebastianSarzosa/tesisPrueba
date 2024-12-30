import 'package:flutter/material.dart';
import 'package:tesis_libros_de_campo/view/ViewBooksScreen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  try {
    await SupabaseService.initialize();
    runApp(MyApp());
  } catch (e) {
    print('Error al inicializar Supabase: $e');
    runApp(ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libros y Proyectos',
      theme: ThemeData( 
        primarySwatch: Colors.blue,
      ),
      home: ViewBooksScreen(), // Pantalla inicial
      debugShowCheckedModeBanner: false, // Opcional: oculta el banner de debug
    );
  }
}

// Pantalla para mostrar un error en la inicialización
class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error de Inicialización',
      home: Scaffold(
        body: Center(
          child: Text(
            'Error al inicializar Supabase. Intente nuevamente.',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
