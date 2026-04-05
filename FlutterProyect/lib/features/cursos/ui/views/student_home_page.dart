import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  final String email;

  const StudentHomePage({super.key, required this.email});

  // Colores de diseño
  final Color primaryGold = const Color(0xFFE6C363);
  final Color backgroundColor = const Color(0xFFF4F5EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('studentHomeScaffold'),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),
              Row(
                key: const Key('studentHomeHeader'),
                children: [
                  Image.asset(
                    'assets/images/ulogo.png',
                    width: 50,
                    height: 50,
                    key: const Key('studentHomeLogo'),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Bienvenido",
                    key: Key('studentHomeWelcomeText'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- TARJETA EVALUACIONES ---
              _buildSummaryCard(),
              const SizedBox(height: 20),

              // --- LISTA DE CURSOS ---
              Expanded(
                child: ListView(
                  key: const Key('studentHomeCourseList'),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCourseCard(
                      key: const Key('courseCard_0'),
                      title: "PROGRAMACIÓN MÓVIL",
                      subtitle: "MOVIL_202610_1852",
                      id: "202610_1852 - 202610",
                      pending: 1,
                      color: const Color(0xFFB8860B),
                    ),
                    _buildCourseCard(
                      key: const Key('courseCard_1'),
                      title: "DLLO APLICACIONES WEB",
                      subtitle: "FRONTEND_202610_2085",
                      id: "202610_2085 - 202610",
                      pending: 0,
                      color: const Color(0xFFB8860B),
                    ),
                    _buildCourseCard(
                      key: const Key('courseCard_2'),
                      title: "DISEÑO DEL SOFTWARE",
                      subtitle: "II_202610_2064",
                      id: "202610_2064 - 202610",
                      pending: 2,
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

  // Widget tarjeta superior de evaluaciones
  Widget _buildSummaryCard() {
    return Container(
      key: const Key('studentHomeSummaryCard'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGold,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            "EVALUACIONES",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("Realizadas", "12", const Key('summaryItem_realizadas')),
              _buildSummaryItem("Pendientes", "3", const Key('summaryItem_pendientes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Key key) {
    return Column(
      key: key,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Widget tarjetas de cursos
  Widget _buildCourseCard({
    required Key key,
    required String title,
    required String subtitle,
    required String id,
    required int pending,
    required Color color,
  }) {
    return Container(
      key: key,
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
          // Color imagen curso
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
          // Informacion del curso
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
                const SizedBox(height: 8),
                Text(
                  "Evaluaciones pendientes: $pending.",
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
