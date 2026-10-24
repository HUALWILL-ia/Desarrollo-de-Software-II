/// Certificación del estudiante (tabla `certificaciones`).
class Certificacion {
  const Certificacion({
    this.id,
    required this.nombre,
    required this.entidad,
    required this.anio,
    this.horas,
    this.url,
  });

  final int? id;
  final String nombre;
  final String entidad;
  final int anio;
  final int? horas;
  final String? url;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'entidad': entidad,
        'anio': anio,
        'horas': horas,
        'url': url,
      };

  factory Certificacion.fromMap(Map<String, Object?> map) => Certificacion(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        entidad: map['entidad'] as String,
        anio: map['anio'] as int,
        horas: map['horas'] as int?,
        url: map['url'] as String?,
      );
}
