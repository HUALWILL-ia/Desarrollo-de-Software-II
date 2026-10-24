import 'constantes.dart';

/// Reglas de validación reutilizables para los formularios.
class Validadores {
  Validadores._();

  static final RegExp _correo = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');
  static final RegExp _telefono = RegExp(r'^[+0-9 ()\-]{7,20}$');

  /// Texto obligatorio con longitud mínima y máxima.
  static String? longitud(String? v, int min, int max, String mensaje) {
    final t = v?.trim() ?? '';
    if (t.length < min || t.length > max) return mensaje;
    return null;
  }

  // ---------------- Proyecto ----------------

  static String? titulo(String? v) => longitud(
        v,
        6,
        80,
        'El título debe tener entre 6 y 80 caracteres.',
      );

  static String? descripcion(String? v) {
    final t = v?.trim() ?? '';
    if (t.length < 20) return 'Describa el proyecto con al menos 20 caracteres.';
    if (t.length > 300) return 'La descripción no puede superar los 300 caracteres.';
    return null;
  }

  static String? tecnologias(List<String> lista) {
    if (lista.length < 3) return 'Seleccione o escriba al menos 3 tecnologías.';
    return null;
  }

  /// URL opcional que debe empezar con https://.
  static String? urlHttps(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null; // es opcional
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'Ingrese una URL válida que empiece con https://.';
    }
    return null;
  }

  static String? anio(int? v, {int minimo = Limites.anioMinimo}) {
    if (v == null || v < minimo || v > Limites.anioActual) {
      return 'Seleccione un año válido.';
    }
    return null;
  }

  // ---------------- Perfil ----------------

  static String? nombres(String? v) => longitud(
        v,
        3,
        60,
        'Ingrese sus nombres (entre 3 y 60 caracteres).',
      );

  static String? carrera(String? v) => longitud(
        v,
        5,
        80,
        'Ingrese su carrera (entre 5 y 80 caracteres).',
      );

  static String? biografia(String? v) => longitud(
        v,
        20,
        300,
        'La biografía debe tener entre 20 y 300 caracteres.',
      );

  static String? ubicacion(String? v) => longitud(
        v,
        3,
        60,
        'Ingrese su ubicación (entre 3 y 60 caracteres).',
      );

  static String? correo(String? v) {
    final t = v?.trim() ?? '';
    if (!_correo.hasMatch(t)) return 'Ingrese un correo electrónico válido.';
    return null;
  }

  static String? telefono(String? v) {
    final t = v?.trim() ?? '';
    if (!_telefono.hasMatch(t)) return 'Ingrese un teléfono válido (7 a 20 dígitos).';
    return null;
  }

  // ---------------- Certificación ----------------

  static String? nombreCertificacion(String? v) => longitud(
        v,
        4,
        100,
        'El nombre debe tener entre 4 y 100 caracteres.',
      );

  static String? entidad(String? v) => longitud(
        v,
        2,
        80,
        'Ingrese la entidad emisora (entre 2 y 80 caracteres).',
      );

  /// Horas opcionales: entero entre 1 y 2000.
  static String? horas(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n < 1 || n > 2000) return 'Ingrese horas entre 1 y 2000.';
    return null;
  }
}
