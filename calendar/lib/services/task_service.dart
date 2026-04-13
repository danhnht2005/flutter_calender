import 'package:calender/utils/request.dart'; 

Future<dynamic> getListTasks() async {
  final result = await ApiService.get('tasks');
  return result;
}