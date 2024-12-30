import 'package:flutter/material.dart';
import 'package:tesis_libros_de_campo/add/agregarPlantaPage.dart'; // Importa la página de agregar planta
import 'package:tesis_libros_de_campo/add/agregarProyectoPage.dart'; // Importa la página de agregar proyecto
import 'package:tesis_libros_de_campo/view/ViewPlantsScreen.dart';
import '../../services/data_service.dart';

class ViewProjectsScreen extends StatelessWidget {
  final int bookId; // ID del libro actual
  final String bookName; // Nombre del libro actual

  ViewProjectsScreen({required this.bookId, required this.bookName});

  final DataService dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyectos - $bookName'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dataService.fetchProjects(bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) {
            return Center(
              child: Text(
                'No hay proyectos para este libro.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    project['nombre_proyecto'], // Nombre del proyecto
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(project['descripcion']), // Descripción del proyecto
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          // Navegar a la pantalla de agregar plantas con el projectId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgregarPlantaPage(projectId: project['id_proyecto']),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_red_eye, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewPlantsScreen(
                                projectId: project['id_proyecto'], // Pasar el ID del proyecto
                                projectName: project['nombre_proyecto'], // Pasar el nombre del proyecto
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Agregar un FloatingActionButton para crear un nuevo proyecto
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de agregar proyecto
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarProyectoPage(bookId: bookId), // Pasar el bookId
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 121, 191, 107),
        child: Icon(Icons.add), // Icono de agregar proyecto
      ),
    );
  }
}
