import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_prueba/features/cursos/ui/views/student_home_page.dart';

void main() {
  const String testEmail = "marcus@uninorte.edu.co";

  group('StudentHomePage Widget Tests', () {

    testWidgets('Debe renderizar el header con logo y bienvenida', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(
        home: StudentHomePage(email: testEmail),
      ));

      expect(find.byKey(const Key('studentHomeLogo')), findsOneWidget);
      expect(find.byKey(const Key('studentHomeWelcomeText')), findsOneWidget);
      expect(find.text("Bienvenido"), findsOneWidget);
    });

    testWidgets('Debe mostrar la tarjeta de resumen de evaluaciones', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(
        home: StudentHomePage(email: testEmail),
      ));

      expect(find.text("EVALUACIONES"), findsOneWidget);

      expect(find.byKey(const Key('summaryItem_realizadas')), findsOneWidget);
      expect(find.byKey(const Key('summaryItem_pendientes')), findsOneWidget);

      expect(find.text("12"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de cursos con scroll', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(
        home: StudentHomePage(email: testEmail),
      ));

      expect(find.byKey(const Key('studentHomeCourseList')), findsOneWidget);

      expect(find.text("MOVIL_202610_1852"), findsOneWidget);
      expect(find.text("202610_1852 - 202610"), findsOneWidget);

      final course0 = find.byKey(const Key('courseCard_0'));
      expect(
          find.descendant(of: course0, matching: find.textContaining("202610_1852")),
          findsNWidgets(2)
      );
    });

    testWidgets('Debe poder hacer scroll para ver el último curso', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(
        home: StudentHomePage(email: testEmail),
      ));

      final lastCourseFinder = find.byKey(const Key('courseCard_2'));

      await tester.scrollUntilVisible(
        lastCourseFinder,
        200.0,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text("DISEÑO DEL SOFTWARE"), findsOneWidget);
      expect(find.textContaining("Evaluaciones pendientes: 2."), findsOneWidget);
    });
  });
}