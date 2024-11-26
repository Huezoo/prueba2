import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final CollectionReference visitors =
      FirebaseFirestore.instance.collection('visitors');

  // Crear nuevo visitante
  Future<void> addVisitor(Map<String, dynamic> visitorData) {
    return visitors.add(visitorData);
  }

  // Leer visitantes
  Stream<QuerySnapshot> getVisitorsStream() {
    return visitors.orderBy('timestamp', descending: true).snapshots();
  }

  // Actualizar visitante
  Future<void> updateVisitor(String docID, Map<String, dynamic> newVisitorData) {
    return visitors.doc(docID).update(newVisitorData);
  }

  // Eliminar visitante
  Future<void> deleteVisitor(String docID) {
    return visitors.doc(docID).delete();
  }

  // Subir imagen del vehículo a Firebase Storage
  Future<String> uploadVehicleImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('vehicle_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }
}

