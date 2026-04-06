import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/services/categoriService.dart';
import 'package:calender/services/userServices.dart';
import 'package:calender/services/tasksService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic dataUser;
  List<dynamic> categories = <dynamic>[];
  List<dynamic> tasks = <dynamic>[];

  Color _getCategoryColor(dynamic categoryId) {
    if (categoryId == null) return Colors.blueAccent;
    final String catIdStr = categoryId.toString();
    for (final cat in categories) {
      if (cat['id'].toString() == catIdStr) {
        return _getColor(cat['color']);
      }
    }
    return Colors.blueAccent;
  }

  Color _getColor(dynamic colorName) {
    final String value = (colorName ?? '').toString().toLowerCase();
    switch (value) {
      case 'red':
        return const Color(0xFFEF4444);
      case 'green':
        return const Color(0xFF22C55E);
      case 'orange':
        return const Color(0xFFF97316);
      case 'yellow':
        return const Color(0xFFEAB308);
      case 'purple':
        return const Color(0xFFA855F7);
      case 'blue':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  List<Appointment> get appointments {
    return tasks
        .whereType<Map>()
        .map((Map raw) => Map<String, dynamic>.from(raw))
        .map((Map<String, dynamic> data) {
          final DateTime? from = DateTime.tryParse(
            (data['from'] ?? '').toString(),
          );
          final DateTime? to = DateTime.tryParse((data['to'] ?? '').toString());
          if (from == null || to == null) return null;

          return Appointment(
            startTime: from,
            endTime: to,
            subject: (data['subject'] ?? 'Công việc').toString(),
            isAllDay: data['isAllDay'] == true,
            color: _getCategoryColor(data['categoryId']),
          );
        })
        .whereType<Appointment>()
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getListTasks(id);
    if (response is List) {
      setState(() {
        tasks = List<dynamic>.from(response);
      });
      return;
    }

    if (response is Map && response['data'] is List) {
      setState(() {
        tasks = List<dynamic>.from(response['data'] as List<dynamic>);
      });
    }
  }

  Future<void> _loadCategories() async {
    final dynamic response = await getListCategories();
    if (response != null && response is List) {
      setState(() {
        categories = List<dynamic>.from(response);
      });
    }
  }

  Future<void> _loadUser() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getUser(id);
    if (response == null || response.isEmpty) return;
    setState(() {
      dataUser = response;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await Token.removeToken();
    await Token.removeId();
    if (!context.mounted) return;
    context.go('/login');
  }

  Color getColor(dynamic colorName) {
    final String value = (colorName ?? '').toString().toLowerCase();
    switch (value) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.greenAccent;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.amber;
      case 'purple':
        return Colors.purpleAccent;
      case 'blue':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _navigateToAddEvent({DateTime? selectedDate}) async {
    final result = await context.push<bool>(
      '/add-event',
      extra: selectedDate,
    );
    // Refresh tasks list if a new event was added
    if (result == true) {
      _loadTasks();
    }
  }

  Map<String, dynamic>? _findCategoryById(dynamic categoryId) {
    if (categoryId == null) return null;
    final String catIdStr = categoryId.toString();
    for (final cat in categories) {
      if (cat['id'].toString() == catIdStr) {
        return Map<String, dynamic>.from(cat as Map);
      }
    }
    return null;
  }

  Map<String, dynamic>? _findTaskByAppointment(Appointment appointment) {
    for (final task in tasks) {
      if (task is! Map) continue;
      final DateTime? from = DateTime.tryParse((task['from'] ?? '').toString());
      final DateTime? to = DateTime.tryParse((task['to'] ?? '').toString());
      final String subject = (task['subject'] ?? '').toString();
      if (from != null &&
          to != null &&
          from == appointment.startTime &&
          to == appointment.endTime &&
          subject == appointment.subject) {
        return Map<String, dynamic>.from(task);
      }
    }
    return null;
  }

  Future<void> _navigateToEventDetail(Appointment appointment) async {
    final Map<String, dynamic>? taskData = _findTaskByAppointment(appointment);
    if (taskData == null) return;

    final Map<String, dynamic>? categoryData =
        _findCategoryById(taskData['categoryId']);

    final result = await context.push<bool>(
      '/event-detail',
      extra: {
        'task': taskData,
        'category': categoryData,
      },
    );
    if (result == true) {
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = (dataUser?['fullName'] ?? 'Người dùng').toString();
    final String email = (dataUser?['email'] ?? '').toString();
    final String avatarChar = fullName.isNotEmpty
        ? fullName[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(fullName),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(child: Text(avatarChar)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  'Lịch của tôi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: getColor(item['color']),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 1),

                        Expanded(
                          child: Text(
                            (item['name'] ?? 'Danh mục').toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Cài đặt'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: () async {
                  await _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SfCalendar(
        view: CalendarView.workWeek,
        dataSource: _TaskDataSource(appointments),
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          numberOfDaysInView: 3,
          nonWorkingDays: <int>[DateTime.friday, DateTime.saturday],
        ),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment &&
              details.appointments != null &&
              details.appointments!.isNotEmpty) {
            final Appointment tapped = details.appointments!.first as Appointment;
            _navigateToEventDetail(tapped);
          } else if (details.targetElement == CalendarElement.calendarCell) {
            _navigateToAddEvent(selectedDate: details.date);
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEvent(),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm lịch',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
