/// Proyecto destacado del portafolio (tabla `proyectos`).
class Proyecto {
  const Proyecto({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.tecnologias,
    this.repositorio,
    required this.anio,
    this.destacado = false,
    required this.creadoEn,
  });

  final int? id;
  final String titulo;
  final String descripcion;
  final List<String> tecnologias;
  final String? repositorio;
  final int anio;
  final bool destacado;
  final DateTime creadoEn;

  /// Copia del proyecto con el id asignado por la base de datos.
  Proyecto conId(int nuevoId) => Proyecto(
        id: nuevoId,
        titulo: titulo,
        descripcion: descripcion,
        tecnologias: tecnologias,
        repositorio: repositorio,
        anio: anio,
        destacado: destacado,
        creadoEn: creadoEn,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'tecnologias': tecnologias.join(','),
        'repositorio': repositorio,
        'anio': anio,
        'destacado': destacado ? 1 : 0,
        'creado_en': creadoEn.toIso8601String(),
      };

  factory Proyecto.fromMap(Map<String, Object?> map) {
    final texto = (map['tecnologias'] as String?) ?? '';
    return Proyecto(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      tecnologias: texto
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      repositorio: map['repositorio'] as String?,
      anio: map['anio'] as int,
      destacado: ((map['destacado'] as int?) ?? 0) == 1,
      creadoEn:
          DateTime.tryParse((map['creado_en'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}
