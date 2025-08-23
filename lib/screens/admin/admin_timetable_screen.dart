import 'package:flutter/material.dart';
import '../../widgets/admin_timetable_widget.dart';
import '../../services/admin_timetable_service.dart';

class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({Key? key}) : super(key: key);

  @override
  State createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: const AdminTimetableWidget(),
    );
  }
}
