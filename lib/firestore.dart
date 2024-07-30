import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* For Notes */

  // Get user's notes collection
  CollectionReference getUserNotesCollection() {
    String uid = _auth.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('notes');
  }

  // Create: add a new note with title, description, and color
  Future<void> addNote(String title, String description, String color) {
    return getUserNotesCollection().add({
      'title': title,
      'description': description,
      'color': color,
      'timestamp': Timestamp.now(),
    });
  }

  // Read: get notes from database
  Stream<QuerySnapshot> getNotesStream() {
    return getUserNotesCollection().orderBy('timestamp', descending: true).snapshots();
  }

  // Update: update notes given a doc id with new title, description, and color
  Future<void> updateNote(String docID, String title, String description, String color) {
    return getUserNotesCollection().doc(docID).update({
      'title': title,
      'description': description,
      'color': color,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete: delete notes given a doc id
  Future<void> deleteNote(String docID) {
    return getUserNotesCollection().doc(docID).delete();
  }

  /* For Tasks */

  // Get user's tasks collection
  CollectionReference getUserTasksCollection() {
    String uid = _auth.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('tasks');
  }

  // Create: add a new task with title, status, task_date_time, and color
  Future<void> addTask(String title, bool status, DateTime taskDateTime, String color) {
    return getUserTasksCollection().add({
      'title': title,
      'status': status,
      'task_date_time': Timestamp.fromDate(taskDateTime),
      'color': color,
      'timestamp': Timestamp.now(),
    });
  }

  // Read: get tasks from database
  Stream<QuerySnapshot> getTasksStream() {
    return getUserTasksCollection().orderBy('timestamp', descending: true).snapshots();
  }

  // Update: update tasks given a doc id with new title, status, task_date_time, and color
  Future<void> updateTask(String docID, String title, bool status, DateTime taskDateTime, String color) {
    return getUserTasksCollection().doc(docID).update({
      'title': title,
      'status': status,
      'task_date_time': Timestamp.fromDate(taskDateTime),
      'color': color,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete: delete tasks given a doc id
  Future<void> deleteTask(String docID) {
    return getUserTasksCollection().doc(docID).delete();
  }
}
