import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentsList(),
    );
  }
}

class StudentsList extends StatefulWidget {
  @override
  _StudentsListState createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  late Future<List<Student>> _students;

  @override
  void initState() {
    super.initState();
    _students = fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: Center(
        child: FutureBuilder<List<Student>>(
          future: _students,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(
                      'Class: ${snapshot.data![index].className} | Roll No: ${snapshot.data![index].rollNo}',
                    ),
                    onTap: () {
                      // Call function to mark attendance
                      markAttendance(snapshot.data![index].id);
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<List<Student>> fetchStudents() async {
    final response = await http.get(
      Uri.parse('https://alihaidarproject.000webhostapp.com/'), // Replace with your PHP script URL
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Student.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> markAttendance(int studentId) async {
    final response = await http.post(
      Uri.parse('https://alihaidarproject.000webhostapp.com/'), // Replace with your PHP script URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId, 'date': '2024-01-02', 'status': 'present'}), // Replace date and status
    );

    if (response.statusCode == 200) {
      print('Attendance marked successfully for Student ID: $studentId');
    } else {
      throw Exception('Failed to mark attendance');
    }
  }
}

class Student {
  final int id;
  final String name;
  final String className;
  final String rollNo;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNo,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      className: json['class'],
      rollNo: json['roll_no'],
    );
  }
}
