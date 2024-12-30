import 'package:flutter/material.dart';
import '../../services/data_service.dart';

class AddNewRecordScreen extends StatefulWidget {
  final int plantId;

  AddNewRecordScreen({required this.plantId});

  @override
  _AddNewRecordScreenState createState() => _AddNewRecordScreenState();
}

class _AddNewRecordScreenState extends State<AddNewRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final DataService dataService = DataService();
  final List<Map<String, dynamic>> _variables = [];
  List<Map<String, dynamic>> _availableVariables = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableVariables();
  }

  Future<void> _fetchAvailableVariables() async {
    try {
      final variables = await dataService.fetchAvailableVariables();
      setState(() {
        _availableVariables = variables;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las variables disponibles')),
      );
    }
  }

  void _addVariable() {
    setState(() {
      _variables.add({'nombre_variable': '', 'valor': ''});
    });
  }

  void _removeVariable(int index) {
    setState(() {
      _variables.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar nuevo registro'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la fecha.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Variables', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._variables.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> variable = entry.value;
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Nombre de la variable'),
                      items: _availableVariables.map((availableVariable) {
                        return DropdownMenuItem<String>(
                          value: availableVariable['nombre_variable'],
                          child: Text(availableVariable['nombre_variable']),
                        );
                      }).toList()
                      ..add(
                        DropdownMenuItem<String>(
                          value: 'Nueva Variable',
                          child: Text('Nueva Variable'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == 'Nueva Variable') {
                            variable['nombre_variable'] = '';
                          } else {
                            variable['nombre_variable'] = value;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona una variable.';
                        }
                        return null;
                      },
                    ),
                    if (variable['nombre_variable'] == '')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Nombre de la nueva variable'),
                        onChanged: (value) {
                          variable['nombre_variable'] = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el nombre de la nueva variable.';
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Valor'),
                      onChanged: (value) {
                        variable['valor'] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el valor de la variable.';
                        }
                        return null;
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () => _removeVariable(index),
                    ),
                  ],
                );
              }).toList(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addVariable,
                child: Text('Agregar Variable'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final fechaControl = DateTime.parse(_fechaController.text);
                      final controlId = await dataService.agregarControl(
                        widget.plantId,
                        fechaControl,
                        _descripcionController.text,
                      );

                      for (var variable in _variables) {
                        await dataService.agregarVariable(
                          controlId: controlId,
                          nombreVariable: variable['nombre_variable'],
                          valorTexto: variable['valor'],
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registro agregado con éxito')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al agregar el registro')),
                      );
                    }
                  }
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}