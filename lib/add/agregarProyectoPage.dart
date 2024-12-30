import 'package:flutter/material.dart';
import 'package:tesis_libros_de_campo/services/data_service.dart';
class AgregarProyectoPage extends StatefulWidget {
  final int bookId; // ID del libro al que pertenece el proyecto

  const AgregarProyectoPage({Key? key, required this.bookId}) : super(key: key);

  @override
  State<AgregarProyectoPage> createState() => _AgregarProyectoPageState();
}

class _AgregarProyectoPageState extends State<AgregarProyectoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaInicio;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _agregarProyecto() async {
    if (_formKey.currentState!.validate() && _fechaInicio != null) {
      try {
        await DataService().addProject(
          bookId: widget.bookId,
          projectName: _nombreController.text,
          description: _descripcionController.text,
          startDate: _fechaInicio!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto agregado exitosamente')),
        );

        Navigator.pop(context); // Regresa a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar proyecto: $e')),
        );
      }
    } else if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha de inicio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Proyecto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del proyecto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaInicio != null
                          ? 'Fecha de inicio: ${_fechaInicio!.toLocal()}'.split(' ')[0]
                          : 'Selecciona una fecha de inicio',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _fechaInicio = pickedDate;
                        });
                      }
                    },
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: _agregarProyecto,
                  child: const Text('Agregar Proyecto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
