import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/color_category.dart';
import 'package:calender/services/categori_service.dart';
import 'package:calender/services/color_service.dart';
import 'package:calender/widget/back_home/back_home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = "B8B8B8";

  List<ColorCategory> colorOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchColors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchColors() async {
    final dynamic response = await getListColor();
    if (response != null && response is List) {
      setState(() {
        colorOptions = response.map((e) => ColorCategory.fromJson(e)).toList();
      });
      print('Fetched colors: $colorOptions');
    }
  }

  Future<void> handleAddCategory() async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final String color = _selectedColor;

    final String? id = await Token.getId();
    if (id == null) return;

    dynamic response = await createCategory(int.parse(id), name, color);

    if (response != null) {
      if (!context.mounted) return;
      context.go('/');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm danh mục thành công')));
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm danh mục thất bại')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm danh mục lịch'),
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
        surfaceTintColor: Colors.transparent,
        leading: const BackHome(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                handleAddCategory();
              },
            ),
            const Text(
              'Tên danh mục',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Tiêu đề',
                hintStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            const Text(
              'Mô tả danh mục',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Mô tả',
                hintStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            const Text(
              'Màu danh mục',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 12.0,
                children: colorOptions.map((item) {
                  bool isSelected = _selectedColor == item.color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = item.color ?? 'B8B8B8';
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: getColor(item.color),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.black,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
