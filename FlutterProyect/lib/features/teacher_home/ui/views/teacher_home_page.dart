import 'package:flutter/material.dart';

class TeacherHomePage extends StatelessWidget {
  final String email;

  const TeacherHomePage({super.key, required this.email});

  final Color primaryGold = const Color(0xFFE6C363);
  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color accentButtonColor = const Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: accentButtonColor,
        elevation: 6,
        shape: const CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ulogo.png', width: 50, height: 50),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Bienvenido ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildTeacherSummaryCard(),

              const SizedBox(height: 20),

              Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCourseCard(
                      title: 'PROGRAMACIÓN MÓVIL',
                      subtitle: 'MOVIL_202610_1852',
                      id: '202610_1852 - 202610',
                      students: 32,
                      color: const Color(0xFFB8860B),
                    ),
                    _buildCourseCard(
                      title: 'DLLO APLICACIONES WEB',
                      subtitle: 'FRONTEND_202610_2085',
                      id: '202610_2085 - 202610',
                      students: 28,
                      color: const Color(0xFFB8860B),
                    ),
                    _buildCourseCard(
                      title: 'DISEÑO DEL SOFTWARE',
                      subtitle: 'II_202610_2064',
                      id: '202610_2064 - 202610',
                      students: 35,
                      color: const Color(0xFFB8860B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: primaryGold,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Cursos activos', '3'),
          _buildSummaryItem('Casos críticos', '7'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String subtitle,
    required String id,
    required int students,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: primaryGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  id,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  'Estudiantes: $students',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
