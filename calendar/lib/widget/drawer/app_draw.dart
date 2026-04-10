import 'package:calender/screens/add_category/add_catetory.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/services/categori_service.dart';
import 'package:calender/services/user_services.dart';
import 'package:calender/models/user.dart';
import 'package:calender/models/categories.dart';
import 'package:calender/helpers/get_color.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User dataUser = User();
  List<Categories> categories = <Categories>[];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getListCategories(id);
    if (response != null && response is List) {
      setState(() {
        categories = List<Categories>.from(
          response.map((e) => Categories.fromJson(e)),
        );
      });
    }
  }

  Future<void> _loadUser() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getUser(id);
    if (response == null || response.isEmpty) return;
    setState(() {
      dataUser = User.fromJson(response);
    });
  }

  Future<void> _logout(BuildContext context) async {
    await Token.removeToken();
    await Token.removeId();
    if (!context.mounted) return;
    context.go('/login');
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AddCategoryScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 0, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      dataUser.fullName != null && dataUser.fullName!.isNotEmpty
                          ? dataUser.fullName![0].toUpperCase()
                          : 'U',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataUser.fullName ?? 'Người dùng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          dataUser.email ?? '',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined),
                    color: Colors.grey.shade600,
                    iconSize: 16,
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Lịch của tôi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            ...categories.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: getColor(item.color),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.go('/details-category/${item.id}');
                        },
                        child: Text(
                          (item.name ?? 'Danh mục').toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              horizontalTitleGap: 8,
              leading: const Icon(Icons.add, color: Colors.grey, size: 20),
              title: const Text(
                'Thêm danh mục lịch',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              onTap: () => {
                Navigator.pop(context),
                _showAddCategorySheet(context),
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Được chia sẻ với tôi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
