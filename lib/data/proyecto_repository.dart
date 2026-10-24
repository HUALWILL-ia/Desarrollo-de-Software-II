import 'package:sqflite/sqflite.dart';

import '../models/proyecto.dart';
import 'database_helper.dart';

/// Operaciones CRUD de la tabla `proyectos`.
class ProyectoRepository {
  ProyectoRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instancia;

  final DatabaseHelper _helper;

  /// Lista los proyectos ordenados por año descendente (RF-1.2).
  /// Si [tecnologia] no es nulo, filtra por esa tecnología (RF-1.7).
  Future<List<Proyecto>> listar({String? tecnologia}) async {
    final db = await _helper.database;
    final filas = await db.query(
      'proyectos',
      orderBy: 'anio DESC, titulo COLLATE NOCASE ASC',
    );
    var lista = filas.map(Proyecto.fromMap).toList();
    if (tecnologia != null && tecnologia.isNotEmpty) {
      final buscada = tecnologia.toLowerCase();
      lista = lista
          .where((p) => p.tecnologias.any((t) => t.toLowerCase() == buscada))
          .toList();
    }
    return lista;
  }

  Future<Proyecto?> obtener(int id) async {
    final db = await _helper.database;
    final filas =
        await db.query('proyectos', where: 'id = ?', whereArgs: [id], limit: 1);
    return filas.isEmpty ? null : Proyecto.fromMap(filas.first);
  }

  /// Devuelve el id generado.
  Future<int> insertar(Proyecto proyecto) async {
    final db = await _helper.database;
    final datos = proyecto.toMap()..remove('id');
    return db.insert('proyectos', datos);
  }

  Future<int> actualizar(Proyecto proyecto) async {
    final db = await _helper.database;
    return db.update(
      'proyectos',
      proyecto.toMap(),
      where: 'id = ?',
      whereArgs: [proyecto.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _helper.database;
    return db.delete('proyectos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contar() async {
    final db = await _helper.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM proyectos'),
        ) ??
        0;
  }

  /// Validación de título único (ignora mayúsculas y espacios sobrantes).
  Future<bool> existeTitulo(String titulo, {int? excluirId}) async {
    final db = await _helper.database;
    final filas = await db.query('proyectos', columns: ['id', 'titulo']);
    final buscado = titulo.trim().toLowerCase();
    return filas.any(
      (f) =>
          f['id'] != excluirId &&
          (f['titulo'] as String).trim().toLowerCase() == buscado,
    );
  }

  /// Tecnologías distintas usadas en los proyectos (para el filtro).
  Future<List<String>> tecnologiasDisponibles() async {
    final db = await _helper.database;
    final filas = await db.query('proyectos', columns: ['tecnologias']);
    final unicas = <String, String>{};
    for (final fila in filas) {
      final texto = (fila['tecnologias'] as String?) ?? '';
      for (final t in texto.split(',')) {
        final limpia = t.trim();
        if (limpia.isNotEmpty) unicas.putIfAbsent(limpia.toLowerCase(), () => limpia);
      }
    }
    final lista = unicas.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return lista;
  }
}
