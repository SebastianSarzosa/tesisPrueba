import 'package:flutter/material.dart';
import '../../services/data_service.dart';

class ViewPlantRecordsScreen extends StatelessWidget {
  final int plantId;
  final String plantName;

  ViewPlantRecordsScreen({required this.plantId, required this.plantName});

  final DataService dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros - $plantName'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dataService.fetchPlantRecords(plantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Text(
                'No hay registros para esta planta.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final variables = record['variables'] ?? [];

              final Map<String, dynamic> uniqueVariables = {};
              for (var variable in variables) {
                uniqueVariables[variable['nombre_variable']] = variable;
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    'Control ${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${record['fecha_control'] ?? 'No disponible'}'),
                      Text('Descripción: ${record['descripcion'] ?? 'No disponible'}'),
                      SizedBox(height: 10),
                      Text('Variables:', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (uniqueVariables.isEmpty)
                        Text('No hay variables registradas para este control.')
                      else
                        ...uniqueVariables.values.map<Widget>((variable) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${variable['nombre_variable'] ?? 'No disponible'}'),
                              Text('Valor: ${_getVariableValue(variable)}'),
                              Divider(),
                            ],
                          );
                        }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón +
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewRecordScreen(plantId: plantId)),
          );
        },
        child: Icon(Icons.add), // Ícono de "+" (add)
        backgroundColor: Colors.blueAccent, // Color del botón
      ),
    );
  }

  String _getVariableValue(Map<String, dynamic> variable) {
    if (variable['valor_texto'] != null) {
      return variable['valor_texto'] ?? 'No disponible';
    } else if (variable['valor_numerico'] != null) {
      return variable['valor_numerico'].toString();
    } else if (variable['valor_fecha'] != null) {
      return variable['valor_fecha'].toString();
    } else {
      return 'No disponible';
    }
  }
}

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
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nombre de la variable'),
                      onChanged: (value) {
                        variable['nombre_variable'] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre de la variable.';
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