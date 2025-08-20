import 'package:flutter/material.dart';

class AdminStudentSmsDetailsScreen extends StatelessWidget {
  const AdminStudentSmsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final studentId = args != null ? args['studentId'] : null;
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Details')),
      body: Center(child: Text('SMS details for student: $studentId')),
    );
  }
}


