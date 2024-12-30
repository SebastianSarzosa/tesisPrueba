import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';  // Importar Hive
import 'supabase_service.dart';

class DataService {
  final SupabaseClient client = SupabaseService.client;
  late Box<Map<String, dynamic>> booksBox; // Caja para libros

  // Inicializar Hive
  Future<void> _initHive() async {
    booksBox = await Hive.openBox<Map<String, dynamic>>('booksBox');
  }

  // Método para traer los libros de campo (primero desde Supabase, luego guardarlos localmente)
  Future<List<Map<String, dynamic>>> fetchBooks() async {
    await _initHive(); // Inicializa Hive

    final response = await client.from('librosdecampo').select().execute();

    if (response.error != null) {
      throw response.error!.message;
    }

    // Guardar los libros en Hive después de obtenerlos de Supabase
    await _saveBooksLocally(List<Map<String, dynamic>>.from(response.data));

    return List<Map<String, dynamic>>.from(response.data);
  }

  // Método para obtener los libros almacenados localmente
  List<Map<String, dynamic>> getLocalBooks() {
    return booksBox.values.toList();
  }

  // Método para guardar los libros en Hive
  Future<void> _saveBooksLocally(List<Map<String, dynamic>> books) async {
    for (var book in books) {
      await booksBox.put(book['id_libro'], book); // Guardamos el libro usando su id_libro
    }
  }

  // Método para traer los proyectos según el id del libro de campo
  Future<List<Map<String, dynamic>>> fetchProjects(int bookId) async {
    final response = await client
        .from('proyectos') // Tabla de proyectos
        .select('id_proyecto, nombre_proyecto, descripcion') // Columnas requeridas
        .eq('fkid_libro', bookId) // Filtro por el libro de campo
        .execute();

    if (response.error != null) {
      throw response.error!.message;
    }

    return List<Map<String, dynamic>>.from(response.data);
  }

  // Método para traer las plantas según el id del proyecto
  Future<List<Map<String, dynamic>>> fetchPlants(int projectId) async {
    final response = await client
        .from('plantas')
        .select()
        .eq('fkid_proyecto', projectId)
        .execute();

    if (response.error != null) {
      throw response.error!.message;
    }

    return List<Map<String, dynamic>>.from(response.data);
  }

  // Método para obtener los registros de la planta desde la tabla 'controles'
  Future<List<Map<String, dynamic>>> fetchPlantRecords(int plantId) async {
    final response = await client
        .from('controles')
        .select('*, variables(*)') // Trae todos los controles y sus variables asociadas
        .eq('fkid_planta', plantId)
        .execute();

    if (response.error != null) {
      throw response.error!.message;
    }

    return List<Map<String, dynamic>>.from(response.data);
  }

  // Método para agregar un proyecto
  Future<void> addProject({
    required int bookId, // ID del libro al que pertenece el proyecto
    required String projectName,
    required String description,
    required DateTime startDate,
  }) async {
    final response = await client.from('proyectos').insert({
      'fkid_libro': bookId, // Relación con el libro
      'nombre_proyecto': projectName, // Nombre del proyecto
      'descripcion': description, // Descripción del proyecto
      'fecha_inicio': startDate.toIso8601String(), // Fecha de inicio
    }).execute();

    // Manejo de errores
    if (response.error != null) {
      throw response.error!.message;
    }
  }

  // Método para agregar una nueva planta
  Future<void> agregarPlanta(int projectId, String nombrePlanta, String nombreCientifico) async {
    final response = await client.from('plantas').insert([{
      'fkid_proyecto': projectId,
      'nombre_planta': nombrePlanta,
      'nombre_cientifico': nombreCientifico,
    }]).execute();

    if (response.error != null) {
      throw response.error!.message;
    }
  }

  // Método para agregar un control a una planta y devolver el ID del control
  Future<int> agregarControl(int plantId, DateTime fechaControl, String descripcion) async {
    final response = await client.from('controles').insert({
      'fkid_planta': plantId,
      'fecha_control': fechaControl.toIso8601String(),
      'descripcion': descripcion,
    }).select('id_control').single().execute();

    if (response.error != null) {
      throw response.error!.message;
    }

    return response.data['id_control'];
  }

  // Método para agregar una variable asociada a un control
  Future<void> agregarVariable({
    required int controlId,
    required String nombreVariable,
    String? valorTexto,
    num? valorNumerico,
    DateTime? valorFecha,
  }) async {
    final response = await client.from('variables').insert([{
      'fkid_control': controlId,
      'nombre_variable': nombreVariable,
      'valor_texto': valorTexto,
      'valor_numerico': valorNumerico,
      'valor_fecha': valorFecha?.toIso8601String(),
    }]).execute();

    if (response.error != null) {
      throw Exception('Error al agregar variable: ${response.error!.message}');
    }
  }

  // Método para obtener las variables disponibles
  Future<List<Map<String, dynamic>>> fetchAvailableVariables() async {
    final response = await client.from('variables').select('id_variable, nombre_variable').execute();

    if (response.error != null) {
      throw response.error!.message;
    }

    return List<Map<String, dynamic>>.from(response.data);
  }
}

extension on PostgrestResponse {
  get error => null;
}