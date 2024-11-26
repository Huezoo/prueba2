import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba2/services/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController visitToController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController companionsController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();
  final TextEditingController exitTimeController = TextEditingController();
  final TextEditingController visitDateController = TextEditingController();
  File? _vehicleImage;

  Future<void> pickVehicleImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _vehicleImage = File(pickedFile.path);
      }
    });
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        visitDateController.text = selected.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selected != null) {
      setState(() {
        controller.text = selected.format(context);
      });
    }
  }

  void openVisitorBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'Identificación'),
              ),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: 'Motivo de la visita'),
              ),
              TextField(
                controller: visitToController,
                decoration: InputDecoration(labelText: 'A quién visita'),
              ),
              TextField(
                controller: visitDateController,
                decoration: InputDecoration(labelText: 'Fecha de visita'),
                onTap: () => selectDate(context),
                readOnly: true,
              ),
              TextField(
                controller: entryTimeController,
                decoration: InputDecoration(labelText: 'Hora de entrada'),
                onTap: () => selectTime(context, entryTimeController),
                readOnly: true,
              ),
              TextField(
                controller: exitTimeController,
                decoration: InputDecoration(labelText: 'Hora de salida'),
                onTap: () => selectTime(context, exitTimeController),
                readOnly: true,
              ),
              TextField(
                controller: vehicleController,
                decoration: InputDecoration(labelText: 'Medio de transporte'),
              ),
              TextField(
                controller: companionsController,
                decoration: InputDecoration(labelText: 'Número de acompañantes'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              if (_vehicleImage != null)
                Image.file(_vehicleImage!)
              else
                TextButton(
                  onPressed: pickVehicleImage,
                  child: Text('Subir Imagen del Vehículo'),
                ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Subir la imagen a Firebase Storage y obtener la URL
              String? vehicleImageUrl;
              if (_vehicleImage != null) {
                vehicleImageUrl = await firestoreService.uploadVehicleImage(_vehicleImage!);
              }

              final visitorData = {
                'nombre': nameController.text,
                'identificación': idController.text,
                'motivo': reasonController.text,
                'visita_a': visitToController.text,
                'fecha_visita': visitDateController.text,
                'hora_entrada': entryTimeController.text,
                'hora_salida': exitTimeController.text,
                'medio_transporte': vehicleController.text,
                'numero_acompañantes': int.tryParse(companionsController.text) ?? 0,
                'timestamp': Timestamp.now(),
                'imagen_vehiculo': vehicleImageUrl ?? '',
              };

              // Agregar nuevo visitante
              if (docID == null) {
                await firestoreService.addVisitor(visitorData);
              } else {
                // Actualizar visitante existente
                await firestoreService.updateVisitor(docID, visitorData);
              }

              // Limpiar los controladores de texto
              nameController.clear();
              idController.clear();
              reasonController.clear();
              visitToController.clear();
              visitDateController.clear();
              entryTimeController.clear();
              exitTimeController.clear();
              vehicleController.clear();
              companionsController.clear();
              setState(() {
                _vehicleImage = null;
              });

              // Cerrar cuadro de diálogo
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control de Visitantes")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openVisitorBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getVisitorsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List visitorList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: visitorList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = visitorList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text(data['nombre']),
                  subtitle: Text(data['motivo']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => openVisitorBox(docID: docID),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deleteVisitor(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text("Sin visitantes...");
          }
        },
      ),
    );
  }
}


