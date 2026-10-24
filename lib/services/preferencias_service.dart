import 'package:shared_preferences/shared_preferences.dart';

import '../models/perfil.dart';

/// Acceso a SharedPreferences: perfil, foto y último filtro usado.
class PreferenciasService {
  PreferenciasService._(this._prefs);

  /// Instancia única, se inicializa en `main()` con [inicializar].
  static late PreferenciasService instancia;

  final SharedPreferences _prefs;

  static const _kNombres = 'perfil_nombres';
  static const _kCarrera = 'perfil_carrera';
  static const _kCiclo = 'perfil_ciclo';
  static const _kBiografia = 'perfil_biografia';
  static const _kCorreo = 'perfil_correo';
  static const _kTelefono = 'perfil_telefono';
  static const _kUbicacion = 'perfil_ubicacion';
  static const _kDisponible = 'perfil_disponible';
  static const _kRutaFoto = 'perfil_ruta_foto';
  static const _kUltimoFiltro = 'ultimo_filtro_tecnologia';

  static Future<void> inicializar() async {
    instancia = PreferenciasService._(await SharedPreferences.getInstance());
  }

  /// Lee el perfil guardado; usa los valores por defecto si aún no existe.
  Perfil leerPerfil() {
    final base = Perfil.porDefecto();
    return Perfil(
      nombres: _prefs.getString(_kNombres) ?? base.nombres,
      carrera: _prefs.getString(_kCarrera) ?? base.carrera,
      ciclo: _prefs.getString(_kCiclo) ?? base.ciclo,
      biografia: _prefs.getString(_kBiografia) ?? base.biografia,
      correo: _prefs.getString(_kCorreo) ?? base.correo,
      telefono: _prefs.getString(_kTelefono) ?? base.telefono,
      ubicacion: _prefs.getString(_kUbicacion) ?? base.ubicacion,
      disponible: _prefs.getBool(_kDisponible) ?? base.disponible,
      rutaFoto: _prefs.getString(_kRutaFoto),
    );
  }

  Future<void> guardarPerfil(Perfil p) async {
    await _prefs.setString(_kNombres, p.nombres);
    await _prefs.setString(_kCarrera, p.carrera);
    await _prefs.setString(_kCiclo, p.ciclo);
    await _prefs.setString(_kBiografia, p.biografia);
    await _prefs.setString(_kCorreo, p.correo);
    await _prefs.setString(_kTelefono, p.telefono);
    await _prefs.setString(_kUbicacion, p.ubicacion);
    await _prefs.setBool(_kDisponible, p.disponible);
    if (p.rutaFoto != null) await _prefs.setString(_kRutaFoto, p.rutaFoto!);
  }

  String? get rutaFotoPerfil => _prefs.getString(_kRutaFoto);

  Future<void> setRutaFotoPerfil(String ruta) =>
      _prefs.setString(_kRutaFoto, ruta);

  /// Último filtro por tecnología (RF-1.7 / HU-1.6).
  String? get ultimoFiltro => _prefs.getString(_kUltimoFiltro);

  Future<void> setUltimoFiltro(String? tecnologia) async {
    if (tecnologia == null || tecnologia.isEmpty) {
      await _prefs.remove(_kUltimoFiltro);
    } else {
      await _prefs.setString(_kUltimoFiltro, tecnologia);
    }
  }
}
