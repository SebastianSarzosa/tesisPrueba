    import 'package:flutter/material.dart';
    import '../../services/data_service.dart';

    class AgregarPlantaPage extends StatefulWidget {
      final int projectId; // El ID del proyecto actual

      AgregarPlantaPage({required this.projectId});

      @override
      _AgregarPlantaPageState createState() => _AgregarPlantaPageState();
    }

    class _AgregarPlantaPageState extends State<AgregarPlantaPage> {
      final _formKey = GlobalKey<FormState>();
      final TextEditingController _nombrePlantaController = TextEditingController();
      final TextEditingController _nombreCientificoController = TextEditingController();

      final DataService dataService = DataService();

      // Método para agregar una planta
      void _agregarPlanta() async {
        if (_formKey.currentState!.validate()) {
          try {
            await dataService.agregarPlanta(
              widget.projectId, // El ID del proyecto al que se le agrega la planta
              _nombrePlantaController.text,
              _nombreCientificoController.text,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Planta agregada exitosamente')),
            );
            Navigator.pop(context); // Regresar a la pantalla anterior
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al agregar planta: $e')),
            );
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Agregar Planta'),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombrePlantaController,
                    decoration: InputDecoration(labelText: 'Nombre de la Planta'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre de la planta';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _nombreCientificoController,
                    decoration: InputDecoration(labelText: 'Nombre Científico'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre científico';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _agregarPlanta,
                    child: Text('Agregar Planta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
