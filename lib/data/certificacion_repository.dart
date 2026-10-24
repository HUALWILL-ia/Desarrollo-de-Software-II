import 'package:sqflite/sqflite.dart';

import '../models/certificacion.dart';
import 'database_helper.dart';

/// Operaciones CRUD de la tabla `certificaciones`.
class CertificacionRepository {
  CertificacionRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instancia;

  final DatabaseHelper _helper;

  Future<List<Certificacion>> listar() async {
    final db = await _helper.database;
    final filas = await db.query(
      'certificaciones',
      orderBy: 'anio DESC, nombre COLLATE NOCASE ASC',
    );
    return filas.map(Certificacion.fromMap).toList();
  }

  Future<int> insertar(Certificacion c) async {
    final db = await _helper.database;
    final datos = c.toMap()..remove('id');
    return db.insert('certificaciones', datos);
  }

  Future<int> actualizar(Certificacion c) async {
    final db = await _helper.database;
    return db.update(
      'certificaciones',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _helper.database;
    return db.delete('certificaciones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contar() async {
    final db = await _helper.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM certificaciones'),
        ) ??
        0;
  }

  /// Promedio de horas por certificación (ignora las que no tienen horas).
  Future<double> promedioHoras() async {
    final db = await _helper.database;
    final filas = await db.rawQuery(
      'SELECT AVG(horas) AS promedio FROM certificaciones WHERE horas IS NOT NULL',
    );
    final valor = filas.first['promedio'];
    return valor == null ? 0 : (valor as num).toDouble();
  }
}
