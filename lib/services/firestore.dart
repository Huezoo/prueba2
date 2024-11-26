import 'package:cloud_firestore/cloud_firestore.dart';

// Jalar visitantes a la app
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

  // Obtener un visitante específico
  Future<DocumentSnapshot> getVisitor(String docID) {
    return visitors.doc(docID).get();
  }

  // Actualizar visitante
  Future<void> updateVisitor(String docID, Map<String, dynamic> newVisitorData) {
    return visitors.doc(docID).update(newVisitorData);
  }

  // Eliminar visitante
  Future<void> deleteVisitor(String docID) {
    return visitors.doc(docID).delete();
  }
}

