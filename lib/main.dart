// Importación de la librería principal de Material Design para Flutter
import 'package:flutter/material.dart';

// Punto de entrada principal de la aplicación
void main() {
  // Inicializa y ejecuta la aplicación cargando el widget principal
  runApp(const MiAplicacionPortafolio());
}

// ================================================================
// APLICACIÓN PRINCIPAL (CONFIGURACIÓN GLOBAL)
// ================================================================

/// Widget raíz sin estado que define la configuración global de la app.
class MiAplicacionPortafolio extends StatelessWidget {
  const MiAplicacionPortafolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Oculta la etiqueta "DEBUG" en la esquina superior derecha durante el desarrollo
      debugShowCheckedModeBanner: false,
      // Título de la aplicación utilizado por el sistema operativo
      title: 'Portafolio Profesional',
      // Configuración del tema visual de la aplicación
      theme: ThemeData(
        // Activa los estándares y estilos de Material Design 3
        useMaterial3: true,
        // Genera la paleta de colores a partir del color añil (indigo)
        colorSchemeSeed: Colors.indigo,
        // Define el color de fondo por defecto para las pantallas (gris claro)
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      // Define la pantalla inicial de la aplicación
      home: const Proyecto1PortafolioProfesional(),
    );
  }
}

// ================================================================
// PANTALLA PRINCIPAL DEL PORTAFOLIO
// ================================================================

/// Widget principal que estructura la vista completa del portafolio.
class Proyecto1PortafolioProfesional extends StatelessWidget {
  const Proyecto1PortafolioProfesional({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación
      appBar: AppBar(
        title: const Text(
          'Mi Portafolio Profesional',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Texto en negrita
          ),
        ),
        centerTitle: true, // Centra el título en la barra superior
      ),

      // Cuerpo de la pantalla con desplazamiento vertical
      body: SingleChildScrollView(
        // Permite obtener las restricciones de espacio disponible para hacer el diseño responsivo
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determina si la pantalla actual corresponde a un dispositivo móvil (< 600px)
            final bool esMovil = constraints.maxWidth < 600;

            // Calcula el ancho máximo del contenido según el tamaño de la pantalla
            double anchoContenido = esMovil
                ? constraints.maxWidth
                : (constraints.maxWidth < 840 ? 800 : 1100);

            // Asegura que el ancho calculado no sobrepase el ancho máximo del dispositivo
            anchoContenido = anchoContenido.clamp(0.0, constraints.maxWidth);

            return Center(
              // Centra el contenedor de contenido en pantallas anchas
              child: SizedBox(
                width: anchoContenido, // Aplica el ancho adaptativo calculado
                child: Padding(
                  // Márgenes internos horizontales y verticales adaptables
                  padding: EdgeInsets.symmetric(
                    horizontal: esMovil ? 16 : 24,
                    vertical: 20,
                  ),
                  child: Column(
                    // Estira los elementos hijos a lo ancho del contenedor
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. SECCIÓN DE PERFIL PROFESIONAL
                      _buildPerfil(context, esMovil),

                      const SizedBox(height: 24), // Espaciador vertical

                      // 2. SECCIÓN DE ESTADÍSTICAS
                      _buildTituloSeccion(
                        'Resumen profesional',
                        Icons.analytics_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildEstadisticas(esMovil),

                      const SizedBox(height: 28),

                      // 3. SECCIÓN DE HABILIDADES TÉCNICAS
                      _buildTituloSeccion(
                        'Habilidades técnicas',
                        Icons.code,
                      ),
                      const SizedBox(height: 12),
                      _buildHabilidades(),

                      const SizedBox(height: 28),

                      // 4. SECCIÓN DE PROYECTOS DESTACADOS
                      _buildTituloSeccion(
                        'Proyectos destacados',
                        Icons.folder_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildProyectos(esMovil),

                      const SizedBox(height: 28),

                      // 5. SECCIÓN DE CONTACTO Y ACCIONES
                      _buildTituloSeccion(
                        'Contacto',
                        Icons.contact_mail_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildContacto(esMovil),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Elemento seleccionado actualmente
        type: BottomNavigationBarType.fixed, // Mantiene fijos los íconos
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.email),
            label: 'Contacto',
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PERFIL PROFESIONAL
  // ================================================================

  /// Construye la tarjeta superior de perfil con portada, foto de avatar e información del usuario.
  Widget _buildPerfil(BuildContext context, bool esMovil) {
    return Card(
      elevation: 3, // Sombreado de la tarjeta
      clipBehavior: Clip.antiAlias, // Recorta los bordes hijos según el radio de la tarjeta
      child: Column(
        children: [
          // Stack permite superponer la foto de perfil sobre el fondo del encabezado
          Stack(
            clipBehavior: Clip.none, // Permite que el avatar sobresalga de los límites del Stack
            children: [
              // Fondo con degradado (Banner superior)
              Container(
                height: esMovil ? 130 : 180, // Altura adaptativa
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.laptop_mac,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),

              // AVATAR CON INDICADOR DE DISPONIBILIDAD SUPERPUESTO
              Positioned(
                left: esMovil ? 20 : 32,
                bottom: -50, // Desplaza la imagen hacia abajo para sobreponerla
                child: Stack(
                  children: [
                    // Contenedor blanco alrededor del avatar para simular un borde
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/eddy.jpg'), // Carga de la foto
                      ),
                    ),
                    // Badge/Etiqueta flotante de "Disponible"
                    Positioned(
                      right: 0,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Disponible',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Espacio reservado para compensar el avatar superpuesto
          const SizedBox(height: 65),

          // Datos personales adaptados según el dispositivo
          Padding(
            padding: EdgeInsets.all(esMovil ? 18 : 28),
            child: esMovil
                ? _buildDatosPerfilMovil()
                : _buildDatosPerfilEscritorio(),
          ),
        ],
      ),
    );
  }

  /// Estructura vertical para mostrar los datos de perfil en dispositivos móviles.
  Widget _buildDatosPerfilMovil() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Juan Pérez Huamán',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          'Ingeniería Informática y de Sistemas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text('UNSAAC • VII Ciclo', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 16),
        Text(
          'Estudiante de Ingeniería Informática y de Sistemas interesado en el '
          'desarrollo de aplicaciones, diseño de interfaces y tecnologías de software.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  /// Estructura en fila (horizontal) para mostrar los datos de perfil en pantallas grandes.
  Widget _buildDatosPerfilEscritorio() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda con título y grado (ocupa 2 partes del espacio)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Juan Pérez Huamán',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Ingeniería Informática y de Sistemas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'UNSAAC • VII Ciclo',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
        SizedBox(width: 30),
        // Columna derecha con la descripción personal (ocupa 3 partes del espacio)
        Expanded(
          flex: 3,
          child: Text(
            'Estudiante de Ingeniería Informática y de Sistemas interesado en el '
            'desarrollo de aplicaciones, diseño de interfaces y tecnologías de software.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ],
    );
  }

  /// Reutilizable: Genera el encabezado estándar para cada sección con ícono y texto.
  Widget _buildTituloSeccion(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 25),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ================================================================
  // ESTADÍSTICAS
  // ================================================================

  /// Construye la tarjeta con las métricas principales del desarrollador.
  Widget _buildEstadisticas(bool esMovil) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(esMovil ? 12 : 18),
        child: Row(
          children: [
            // Reparte el espacio equitativamente entre los 3 indicadores
            Expanded(
              child: _buildEstadistica('Proyectos', '12', Icons.folder),
            ),
            Expanded(
              child: _buildEstadistica('Certificaciones', '18', Icons.school),
            ),
            Expanded(
              child: _buildEstadistica('Promedio', '17.8', Icons.star),
            ),
          ],
        ),
      ),
    );
  }

  /// Reutilizable: Diseña un ítem individual de estadística (icono, cifra, título).
  Widget _buildEstadistica(String titulo, String valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, size: 28),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ================================================================
  // HABILIDADES
  // ================================================================

  /// Construye la lista de etiquetas de habilidades de forma flexible.
  Widget _buildHabilidades() {
    // Lista con las tecnologías conocidas
    final habilidades = [
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 8, // Espaciado horizontal entre Chips
          runSpacing: 10, // Espaciado vertical cuando pasa a la siguiente línea
          // Mapea cada string de la lista a un widget Chip
          children: habilidades.map((habilidad) {
            return Chip(
              avatar: const Icon(Icons.code, size: 17),
              label: Text(habilidad),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================================================================
  // PROYECTOS (GRIDVIEW EN ANCHOS MAYORES)
  // ================================================================

  /// Construye la sección de proyectos mostrando una lista en móvil o una cuadrícula en pantallas más grandes.
  Widget _buildProyectos(bool esMovil) {
    // Colección de datos de los proyectos
    final proyectos = [
      {
        'titulo': 'Sistema de Gestión Académica',
        'descripcion':
            'Aplicación orientada a organizar información académica.',
        'icono': Icons.school,
      },
      {
        'titulo': 'Aplicación de Recolección',
        'descripcion':
            'Propuesta para mejorar la organización de recolección.',
        'icono': Icons.recycling,
      },
      {
        'titulo': 'Cableado Estructurado',
        'descripcion': 'Diseño y documentación de infraestructura de red.',
        'icono': Icons.lan,
      },
    ];

    // Si es móvil, muestra los proyectos verticalmente en una Column
    if (esMovil) {
      return Column(
        children: proyectos.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildTarjetaProyecto(
              p['titulo'] as String,
              p['descripcion'] as String,
              p['icono'] as IconData,
            ),
          );
        }).toList(),
      );
    }

    // GridView de 2 columnas para escritorio / tablet según la rúbrica
    return GridView.builder(
      shrinkWrap: true, // Se adapta a la altura del contenido
      physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll interno
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas por fila
        crossAxisSpacing: 12, // Espacio entre columnas
        mainAxisSpacing: 12, // Espacio entre filas
        childAspectRatio: 1.1, // Relación de aspecto ancho/alto
      ),
      itemCount: proyectos.length,
      itemBuilder: (context, index) {
        final p = proyectos[index];
        return _buildTarjetaProyecto(
          p['titulo'] as String,
          p['descripcion'] as String,
          p['icono'] as IconData,
        );
      },
    );
  }

  /// Reutilizable: Estructura la tarjeta visual de un proyecto individual.
  Widget _buildTarjetaProyecto(
    String titulo,
    String descripcion,
    IconData icono,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor del ícono superior con fondo suave
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo.withValues(alpha: 0.1),
              ),
              child: Icon(icono, size: 40),
            ),
            const SizedBox(height: 12),
            // Título del proyecto junto con ícono indicador
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Acorta con "..." si el texto es muy largo
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            // Descripción breve del proyecto (se quitó Expanded para resolver el error de renderizado)
            Text(
              descripcion,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // Tags/Etiquetas de tecnologías utilizadas
            const Wrap(
              spacing: 6,
              children: [
                Chip(
                  label: Text('Flutter', style: TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('UI', style: TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // CONTACTO Y ACCIONES DE CONTACTO
  // ================================================================

  /// Construye la tarjeta contenedora de los datos de contacto y botones de acción.
  Widget _buildContacto(bool esMovil) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Lista con información detallada de contacto
            _buildItemContacto(
              Icons.email_outlined,
              'Correo',
              'juan.perez@unsaac.edu.pe',
            ),
            const Divider(), // Línea divisora
            _buildItemContacto(
              Icons.phone_outlined,
              'Teléfono',
              '+51 999 999 999',
            ),
            const Divider(),
            _buildItemContacto(
              Icons.location_on_outlined,
              'Ubicación',
              'Cusco, Perú',
            ),
            const SizedBox(height: 20),

            // BARRA DE ACCIONES DE CONTACTO (Row + Expanded)
            Row(
              children: [
                Expanded(
                  child: _buildAccionContacto(Icons.email, 'Correo'),
                ),
                Expanded(
                  child: _buildAccionContacto(Icons.phone, 'Llamar'),
                ),
                Expanded(
                  child: _buildAccionContacto(Icons.link, 'Perfil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Reutilizable: Genera una fila con un ícono, título y valor de contacto.
  Widget _buildItemContacto(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícono dentro de un cuadrado redondeado con fondo tenue
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.indigo.withValues(alpha: 0.1),
            ),
            child: Icon(icono),
          ),
          const SizedBox(width: 14),
          // Textos informativos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(valor, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reutilizable: Genera un botón de acción rápida (icono + texto corto).
  Widget _buildAccionContacto(IconData icono, String texto) {
    return SizedBox(
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono),
          const SizedBox(height: 4),
          Text(texto, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}