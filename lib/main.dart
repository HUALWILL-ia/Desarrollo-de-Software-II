// Arranque de la aplicación: preferencias, base de datos (se abre bajo demanda) y rutas.
import 'package:flutter/material.dart';

import 'models/proyecto.dart';
import 'screens/certificaciones_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/portafolio_screen.dart';
import 'screens/proyecto_detalle_screen.dart';
import 'screens/proyecto_form_screen.dart';
import 'services/preferencias_service.dart';
import 'utils/constantes.dart';

Future<void> main() async {
  // Necesario antes de usar plugins (SharedPreferences, SQLite, cámara...)
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las preferencias guardadas (perfil, foto, último filtro)
  await PreferenciasService.inicializar();

  // La base de datos SQLite la abre DatabaseHelper la primera vez que se usa.
  runApp(const MiAplicacionPortafolio());
}

// ================================================================
// APLICACIÓN PRINCIPAL (CONFIGURACIÓN GLOBAL)
// ================================================================

/// Widget raíz que define el tema global y el contrato de navegación.
class MiAplicacionPortafolio extends StatelessWidget {
  const MiAplicacionPortafolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Textos.tituloApp,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colores.semilla,
        scaffoldBackgroundColor: Colores.fondo,
      ),
      initialRoute: Rutas.portafolio,
      onGenerateRoute: _generarRuta,
    );
  }

  /// Contrato de navegación: ruta → pantalla, argumentos y resultado.
  Route<dynamic> _generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case Rutas.proyectoForm:
        return MaterialPageRoute<Proyecto>(
          settings: settings,
          builder: (_) =>
              ProyectoFormScreen(proyecto: settings.arguments as Proyecto?),
        );
      case Rutas.proyectoDetalle:
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) =>
              ProyectoDetalleScreen(proyecto: settings.arguments as Proyecto),
        );
      case Rutas.perfil:
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => const PerfilScreen(),
        );
      case Rutas.certificaciones:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CertificacionesScreen(),
        );
      case Rutas.portafolio:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PortafolioScreen(),
        );
    }
  }
}
