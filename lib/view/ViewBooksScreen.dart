import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'ViewProjectsScreen.dart';
import '../../services/data_service.dart';

class ViewBooksScreen extends StatelessWidget {
  final DataService dataService = DataService();

  // Método para obtener los libros de campo, verificando la conexión
  Future<List<Map<String, dynamic>>> _fetchBooks() async {
    // Verificar la conectividad
    var connectivityResult = await (Connectivity().checkConnectivity());

    // Si no hay conexión, obtener los libros almacenados localmente
    if (connectivityResult == ConnectivityResult.none) {
      return dataService.getLocalBooks(); // Método para obtener los libros desde almacenamiento local
    } else {
      // Si hay conexión, obtener los libros desde Supabase
      try {
        return await dataService.fetchBooks(); // Método para obtener los libros desde Supabase
      } catch (e) {
        throw Exception('Error al obtener los libros: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libros de Campo'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // Usar _fetchBooks() en lugar de dataService.fetchBooks()
        future: _fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final books = snapshot.data ?? [];
          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.9,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewProjectsScreen(
                        bookId: book['id_libro'], // Asegúrate de que coincida con tu base de datos
                        bookName: book['nombre_libro'], // Asegúrate de que coincida con tu base de datos
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7EADFF), Color(0xFF87C6E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        size: 50,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        book['nombre_libro'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
