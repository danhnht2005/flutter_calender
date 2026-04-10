import 'package:calender/utils/request.dart'; 

Future<dynamic> getListCategories(String id) async {
  final result = await ApiService.get('categories?userId=$id');
  return result;
}

Future<dynamic> createCategory(int userId, String name, String color) async {
  final result = await ApiService.post('categories', {
    'userId': userId,
    'name': name,
    'color': color, 
    'isActive': true,
  });
  return result;
}