import 'package:flutter/material.dart';

/// Estados posibles de una pantalla que carga datos de forma asíncrona.
enum EstadoCarga { cargando, listo, error }

/// Nombres de las rutas (contrato de navegación).
class Rutas {
  Rutas._();

  static const portafolio = '/';
  static const proyectoForm = '/proyecto';
  static const proyectoDetalle = '/proyecto/detalle';
  static const perfil = '/perfil';
  static const certificaciones = '/certificaciones';
}

/// Colores globales de la aplicación.
class Colores {
  Colores._();

  static const Color fondo = Color(0xFFF5F7FB);
  static const Color semilla = Colors.indigo;
  static const Color bannerInicio = Colors.indigo;
  static const Color bannerFin = Colors.deepPurple;
}

/// Unidades de espaciado reutilizables.
class Espaciado {
  Espaciado._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 28;
}

/// Límites de validación.
class Limites {
  Limites._();

  static const int anioMinimo = 2018;
  static int get anioActual => DateTime.now().year;
}

/// Textos y listas fijas de la interfaz.
class Textos {
  Textos._();

  static const String tituloApp = 'Portafolio Profesional';
  static const String tituloPantalla = 'Mi Portafolio Profesional';

  static const List<String> habilidades = [
    'Dart',
    'Flutter',
    'Git & GitHub',
    'Layouts Adaptables',
    'POO',
    'SQL',
    'Python',
    'Java',
    'C++',
    'HTML & CSS',
    'UML',
    'Bases de Datos',
  ];

  /// Tecnologías sugeridas en el formulario de proyectos (FilterChip).
  static const List<String> tecnologiasSugeridas = [
    'Flutter',
    'Dart',
    'SQLite',
    'Python',
    'Java',
    'C++',
    'SQL',
    'Git',
    'HTML',
    'CSS',
    'UML',
    'Redes',
  ];

  static const List<String> ciclos = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
  ];
}
