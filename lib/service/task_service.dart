import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/feature/home/model/task_model.dart';

class TaskService {
  final _collection = FirebaseFirestore.instance.collection("tasks");
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> addTask(TaskModel task) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();

      final updatedTask = task.copyWith(
        userId: _userId,
        createdAt: now,
        description: task.description == "No description has been made yet" ?
        "No description has been made yet" : task.description,
        iconCodePoint: task.iconCodePoint == 62504 ? 
          62504 : task.iconCodePoint,
      );

      final newTask = await _collection.add(updatedTask.toMap());

      await newTask.update({'id': newTask.id});
    } catch (e) {
      throw Exception('An error occurred while adding the task: $e');
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      final querySnapshot =
          await _collection.where('userId', isEqualTo: _userId).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('An error occurred while fetching tasks: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      await _collection.doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('An error occurred while updating the task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      await _collection.doc(taskId).delete();
    } catch (e) {
      throw Exception('An error occurred while deleting the task: $e');
    }
  }
}
