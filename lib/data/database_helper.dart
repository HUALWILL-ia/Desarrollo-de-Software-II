import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as ffi_web;

/// Apertura, creación y migración de la base de datos SQLite.
///
/// - Web (Chrome/Edge): usa `sqflite_common_ffi_web` (almacenamiento del navegador).
/// - Android / iOS: usa `sqflite` (carpeta de bases de datos de la app).
/// - Windows / Linux / macOS: usa `sqflite_common_ffi` (carpeta de soporte de la app).
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instancia = DatabaseHelper._();

  static const String _nombreArchivo = 'portafolio.db';
  static const int _version = 1;

  Future<Database>? _abriendo;

  /// Devuelve la base de datos abierta (la abre una sola vez).
  Future<Database> get database async {
    try {
      return await (_abriendo ??= _abrir());
    } catch (_) {
      _abriendo = null; // permite reintentar
      rethrow;
    }
  }

  static bool get _esEscritorio =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Ruta completa del archivo `portafolio.db`.
  Future<String> rutaArchivo() async {
    if (kIsWeb) return _nombreArchivo; // en web no hay archivo físico
    if (_esEscritorio) {
      final dir = await getApplicationSupportDirectory();
      await Directory(dir.path).create(recursive: true);
      return p.join(dir.path, _nombreArchivo);
    }
    return p.join(await getDatabasesPath(), _nombreArchivo);
  }

  Future<Database> _abrir() async {
    final opciones = OpenDatabaseOptions(
      version: _version,
      onCreate: _crear,
      onUpgrade: _migrar,
    );

    // Navegador (Chrome / Edge)
    if (kIsWeb) {
      debugPrint('[BD] Base de datos web: $_nombreArchivo');
      return ffi_web.databaseFactoryFfiWeb.openDatabase(
        _nombreArchivo,
        options: opciones,
      );
    }

    final ruta = await rutaArchivo();
    debugPrint('[BD] Archivo SQLite: $ruta');

    // Windows / Linux / macOS
    if (_esEscritorio) {
      ffi.sqfliteFfiInit();
      return ffi.databaseFactoryFfi.openDatabase(ruta, options: opciones);
    }

    // Android / iOS
    return openDatabase(
      ruta,
      version: _version,
      onCreate: _crear,
      onUpgrade: _migrar,
    );
  }

  Future<void> _crear(Database db, int version) async {
    await db.execute('''
      CREATE TABLE proyectos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        tecnologias TEXT NOT NULL,
        repositorio TEXT,
        anio INTEGER NOT NULL,
        destacado INTEGER NOT NULL DEFAULT 0,
        creado_en TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE certificaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        entidad TEXT NOT NULL,
        anio INTEGER NOT NULL,
        horas INTEGER,
        url TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_proyectos_anio ON proyectos(anio)');

    await _sembrarDatosIniciales(db);
  }

  /// Aquí se agregarían los cambios de esquema en futuras versiones.
  Future<void> _migrar(Database db, int anterior, int nueva) async {
    // Ejemplo: if (anterior < 2) { await db.execute('ALTER TABLE ...'); }
  }

  /// Datos de ejemplo para que la app no arranque vacía (se pueden editar/borrar).
  Future<void> _sembrarDatosIniciales(Database db) async {
    final ahora = DateTime.now().toIso8601String();
    final batch = db.batch();

    batch.insert('proyectos', {
      'titulo': 'Sistema de Gestión Académica',
      'descripcion': 'Aplicación orientada a organizar información académica.',
      'tecnologias': 'Flutter,Dart,SQLite',
      'repositorio': null,
      'anio': 2025,
      'destacado': 1,
      'creado_en': ahora,
    });
    batch.insert('proyectos', {
      'titulo': 'Aplicación de Recolección',
      'descripcion': 'Propuesta para mejorar la organización de recolección.',
      'tecnologias': 'Flutter,Dart,UI',
      'repositorio': null,
      'anio': 2025,
      'destacado': 0,
      'creado_en': ahora,
    });
    batch.insert('proyectos', {
      'titulo': 'Cableado Estructurado',
      'descripcion': 'Diseño y documentación de infraestructura de red.',
      'tecnologias': 'Redes,UML,Documentación',
      'repositorio': null,
      'anio': 2024,
      'destacado': 0,
      'creado_en': ahora,
    });

    batch.insert('certificaciones', {
      'nombre': 'Flutter y Dart desde cero',
      'entidad': 'Curso en línea',
      'anio': 2025,
      'horas': 40,
      'url': null,
    });
    batch.insert('certificaciones', {
      'nombre': 'Fundamentos de Bases de Datos',
      'entidad': 'UNSAAC',
      'anio': 2024,
      'horas': 30,
      'url': null,
    });

    await batch.commit(noResult: true);
  }
}