import 'package:calender/widget/back_home/back_home.dart';
import 'package:flutter/material.dart';

class DetailCategoryScreen extends StatefulWidget {
  final String id;

  const DetailCategoryScreen({super.key, required this.id});

  @override
  State<DetailCategoryScreen> createState() => _DetailCategoryScreenState();
}

class _DetailCategoryScreenState extends State<DetailCategoryScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết danh mục'),
        leading: const BackHome(),
      ),
      body: Center(
        child: Text(
          'Detail Category ID: ${widget.id}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
