import 'package:flutter/material.dart';
import '../../widgets/admin_timetable_widget.dart';

class AdminTimetableScreen extends StatelessWidget {
  const AdminTimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Teacher Timetables', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: AdminTimetableWidget(),
      ),
    );
  }
}
