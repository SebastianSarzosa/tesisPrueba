import 'package:flutter/material.dart';
import 'package:tesis_libros_de_campo/view/ViewPlantRecordsScreen.dart';
import '../../services/data_service.dart';
class ViewPlantsScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  ViewPlantsScreen({required this.projectId, required this.projectName});

  final DataService dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plantas - $projectName'),
        centerTitle: true,
       backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dataService.fetchPlants(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final plants = snapshot.data ?? [];
          if (plants.isEmpty) {
            return Center(
              child: Text(
                'No hay plantas para este proyecto.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    plant['nombre_planta'], // Nombre de la planta
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.book, color: Colors.blueAccent),
                    onPressed: () {
                      // Cuando se presiona el icono del libro, vamos a la pantalla de registros
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPlantRecordsScreen(
                            plantId: plant['id_planta'], // Pasamos el id de la planta
                            plantName: plant['nombre_planta'], // Nombre de la planta
                          ),
                        ),
                      );
                    },
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
