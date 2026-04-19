import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_matriculado.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';


class FakeCourseRepository implements ICursoRepository {

  final List<CursoCurso> _cursos = [];
  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(String emailEstudiante) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      CursoMatriculado(
        curso: CursoCurso(
            id: "202610_1852",
            nombre: "Movil",
            idProfesor: "f66b8ad3-9e8e-49ac-a745-573206f64466"
        ),
        grupos: [
          CategoriaGrupo(idCat: "1774449735424", categoriaNombre: "CategoríaPyFlutter", grupoNombre: "Grupo 3"),
          CategoriaGrupo(idCat: "1776479426491", categoriaNombre: "CategoriaAleatoriaPrueba", grupoNombre: "Grupo 6"),

        ],
      ),
      CursoMatriculado(
        curso: CursoCurso(
            id: "NRC-5678",
            nombre: "Inteligencia Artificial",
            idProfesor: "PROFE-002"
        ),
        grupos: [
          CategoriaGrupo(idCat: "CAT-02", categoriaNombre: "Laboratorio", grupoNombre: "Grupo 3")
        ],
      ),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoriasByCurso(String idCurso) async {
    return [{'id': 'CAT-01', 'nombre': 'Proyecto Final'}];
  }

  @override
  Future<void> createCurso(String codigo, String nombre) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cursos.add(CursoCurso(
        id: codigo,
        nombre: nombre,
        idProfesor: 'f66b8ad3-9e8e-49ac-a745-573206f64466'
    ));
  }

  @override
  Future<void> deleteCurso(String idCurso) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cursos.removeWhere((curso) => curso.id == idCurso);
  }
  @override
  Future<List<CursoCurso>> getCursosByProfe() async {
    return List.from(_cursos);
  }
  @override
  Future<List<String>> getCompanerosDeGrupo(String idCat, String nombreGrupo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      "gmrey@uninorte.edu.co",
      "mpreston@uninorte.edu.co",
      "acoronellm@uninorte.edu.co",
      "jdimitola@uninorte.edu.co"
    ];
  }
  @override
  Future<List<Map<String, dynamic>>> getDatosDeGruposPorCategoria(String idCat) async => [];
  @override
  Future<void> updateCurso(CursoCurso curso, String NomNuevo) async {}
  @override
  Future<void> vaciarContenidoCurso(String idCurso) async {}
}