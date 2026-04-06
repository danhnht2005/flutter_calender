import 'package:calender/utils/request.dart'; 

Future<dynamic> getListTasks(String id) async {
  final result = await ApiService.get('tasks?userId=${Uri.encodeQueryComponent(id)}');
  return result;
}

Future<dynamic> createTask(Map<String, dynamic> taskData) async {
  final result = await ApiService.post('tasks', taskData);
  return result;
}

Future<dynamic> deleteTask(String taskId) async {
  final result = await ApiService.del('tasks/$taskId');
  return result;
}