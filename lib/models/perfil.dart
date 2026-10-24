/// Datos del perfil profesional (se guardan en SharedPreferences).
class Perfil {
  const Perfil({
    required this.nombres,
    required this.carrera,
    required this.ciclo,
    required this.biografia,
    required this.correo,
    required this.telefono,
    required this.ubicacion,
    required this.disponible,
    this.rutaFoto,
  });

  final String nombres;
  final String carrera;
  final String ciclo; // I, II, ... X
  final String biografia;
  final String correo;
  final String telefono;
  final String ubicacion;
  final bool disponible;
  final String? rutaFoto;

  /// Valores iniciales la primera vez que se abre la aplicación.
  factory Perfil.porDefecto() => const Perfil(
        nombres: 'Juan Pérez Huamán',
        carrera: 'Ingeniería Informática y de Sistemas',
        ciclo: 'VII',
        biografia:
            'Estudiante de Ingeniería Informática y de Sistemas interesado en el '
            'desarrollo de aplicaciones, diseño de interfaces y tecnologías de software.',
        correo: 'juan.perez@unsaac.edu.pe',
        telefono: '+51 999 999 999',
        ubicacion: 'Cusco, Perú',
        disponible: true,
      );
}
