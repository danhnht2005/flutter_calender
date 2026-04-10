import 'package:calender/utils/request.dart'; 

Future<dynamic> getListColor() async {
  final result = await ApiService.get('colors');
  return result;
}