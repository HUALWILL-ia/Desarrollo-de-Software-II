import 'package:flutter/material.dart';

import '../data/certificacion_repository.dart';
import '../data/proyecto_repository.dart';
import '../models/perfil.dart';
import '../models/proyecto.dart';
import '../services/preferencias_service.dart';
import '../utils/constantes.dart';
import '../widgets/contacto_card.dart';
import '../widgets/estadisticas_card.dart';
import '../widgets/filtro_tecnologias.dart';
import '../widgets/habilidades_card.dart';
import '../widgets/perfil_header.dart';
import '../widgets/tarjeta_proyecto.dart';
import '../widgets/titulo_seccion.dart';

/// Pantalla principal: cabecera + estadísticas + habilidades + proyectos + contacto.
class PortafolioScreen extends StatefulWidget {
  const PortafolioScreen({super.key});

  @override
  State<PortafolioScreen> createState() => _PortafolioScreenState();
}

class _PortafolioScreenState extends State<PortafolioScreen> {
  final _proyectoRepo = ProyectoRepository();
  final _certRepo = CertificacionRepository();
  final _prefs = PreferenciasService.instancia;

  // ---- Estado de la pantalla ----
  EstadoCarga _estado = EstadoCarga.cargando;
  String? _mensajeError;

  Perfil _perfil = Perfil.porDefecto();
  List<Proyecto> _proyectos = [];
  List<String> _tecnologias = [];
  String? _filtro;

  // Estadísticas calculadas desde la base de datos (RF-1.6)
  int _totalProyectos = 0;
  int _totalCertificaciones = 0;
  double _promedioHoras = 0;

  @override
  void initState() {
    super.initState();
    _filtro = _prefs.ultimoFiltro; // recuerda el último filtro (HU-1.6)
    _cargar();
  }

  /// Lee perfil, proyectos y estadísticas. Maneja los estados de carga y error.
  Future<void> _cargar() async {
    try {
      final perfil = _prefs.leerPerfil();
      final tecnologias = await _proyectoRepo.tecnologiasDisponibles();

      // Si la tecnología recordada ya no existe, se descarta el filtro.
      var filtro = _filtro;
      if (filtro != null &&
          !tecnologias.any((t) => t.toLowerCase() == filtro!.toLowerCase())) {
        filtro = null;
        await _prefs.setUltimoFiltro(null);
      }

      final proyectos = await _proyectoRepo.listar(tecnologia: filtro);
      final total = await _proyectoRepo.contar();
      final certificaciones = await _certRepo.contar();
      final promedio = await _certRepo.promedioHoras();

      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _tecnologias = tecnologias;
        _filtro = filtro;
        _proyectos = proyectos;
        _totalProyectos = total;
        _totalCertificaciones = certificaciones;
        _promedioHoras = promedio;
        _mensajeError = null;
        _estado = EstadoCarga.listo;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensajeError = e.toString();
        _estado = EstadoCarga.error;
      });
    }
  }

  void _reintentar() {
    setState(() => _estado = EstadoCarga.cargando);
    _cargar();
  }

  void _mostrarMensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // ---------------- Navegación ----------------

  Future<void> _nuevoProyecto() async {
    final guardado =
        await Navigator.pushNamed<Proyecto>(context, Rutas.proyectoForm);
    if (guardado == null) return;
    _mostrarMensaje('Proyecto registrado');
    await _cargar();
  }

  Future<void> _abrirDetalle(Proyecto proyecto) async {
    final huboCambios = await Navigator.pushNamed<bool>(
      context,
      Rutas.proyectoDetalle,
      arguments: proyecto,
    );
    if (huboCambios == true) await _cargar();
  }

  Future<void> _editarPerfil() async {
    final huboCambios = await Navigator.pushNamed<bool>(context, Rutas.perfil);
    if (huboCambios == true) await _cargar();
  }

  Future<void> _verCertificaciones() async {
    await Navigator.pushNamed(context, Rutas.certificaciones);
    await _cargar(); // las estadísticas pudieron cambiar
  }

  Future<void> _seleccionarFiltro(String? tecnologia) async {
    _filtro = tecnologia;
    await _prefs.setUltimoFiltro(tecnologia);
    await _cargar();
  }

  void _alTocarNavegacion(int indice) {
    if (indice == 1) _verCertificaciones();
    if (indice == 2) _editarPerfil();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Textos.tituloPantalla,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _construirCuerpo(),
      floatingActionButton: _estado == EstadoCarga.listo
          ? FloatingActionButton.extended(
              onPressed: _nuevoProyecto,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo proyecto'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: _alTocarNavegacion,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Certificaciones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _construirCuerpo() {
    switch (_estado) {
      case EstadoCarga.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoCarga.error:
        return _construirError();
      case EstadoCarga.listo:
        return _construirContenido();
    }
  }

  Widget _construirError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar los datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _mensajeError ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _reintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirContenido() {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool esMovil = constraints.maxWidth < 600;

          double anchoContenido = esMovil
              ? constraints.maxWidth
              : (constraints.maxWidth < 840 ? 800 : 1100);
          anchoContenido = anchoContenido.clamp(0.0, constraints.maxWidth);

          return Center(
            child: SizedBox(
              width: anchoContenido,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: esMovil ? 16 : 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. PERFIL
                    PerfilHeader(
                      perfil: _perfil,
                      esMovil: esMovil,
                      onEditar: _editarPerfil,
                    ),
                    const SizedBox(height: Espaciado.xl),

                    // 2. ESTADÍSTICAS
                    const TituloSeccion(
                      titulo: 'Resumen profesional',
                      icono: Icons.analytics_outlined,
                    ),
                    const SizedBox(height: Espaciado.m),
                    EstadisticasCard(
                      proyectos: _totalProyectos,
                      certificaciones: _totalCertificaciones,
                      promedioHoras: _promedioHoras,
                      esMovil: esMovil,
                      onTapCertificaciones: _verCertificaciones,
                    ),
                    const SizedBox(height: Espaciado.xxl),

                    // 3. HABILIDADES
                    const TituloSeccion(
                      titulo: 'Habilidades técnicas',
                      icono: Icons.code,
                    ),
                    const SizedBox(height: Espaciado.m),
                    const HabilidadesCard(),
                    const SizedBox(height: Espaciado.xxl),

                    // 4. PROYECTOS
                    TituloSeccion(
                      titulo: 'Proyectos destacados',
                      icono: Icons.folder_outlined,
                      accion: TextButton.icon(
                        onPressed: _nuevoProyecto,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ),
                    const SizedBox(height: Espaciado.m),
                    if (_tecnologias.isNotEmpty) ...[
                      FiltroTecnologias(
                        tecnologias: _tecnologias,
                        seleccionada: _filtro,
                        alSeleccionar: _seleccionarFiltro,
                      ),
                      const SizedBox(height: Espaciado.m),
                    ],
                    _construirProyectos(esMovil),
                    const SizedBox(height: Espaciado.xxl),

                    // 5. CONTACTO
                    const TituloSeccion(
                      titulo: 'Contacto',
                      icono: Icons.contact_mail_outlined,
                    ),
                    const SizedBox(height: Espaciado.m),
                    ContactoCard(perfil: _perfil, onEditarPerfil: _editarPerfil),

                    // Espacio para que el botón flotante no tape el contenido
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirProyectos(bool esMovil) {
    if (_proyectos.isEmpty) return _construirVacio();

    if (esMovil) {
      return Column(
        children: _proyectos.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TarjetaProyecto(proyecto: p, onTap: () => _abrirDetalle(p)),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 310,
      ),
      itemCount: _proyectos.length,
      itemBuilder: (context, index) {
        final p = _proyectos[index];
        return TarjetaProyecto(proyecto: p, onTap: () => _abrirDetalle(p));
      },
    );
  }

  Widget _construirVacio() {
    final hayFiltro = _filtro != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              hayFiltro
                  ? 'No hay proyectos con la tecnología "$_filtro".'
                  : 'Aún no registras proyectos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            hayFiltro
                ? OutlinedButton(
                    onPressed: () => _seleccionarFiltro(null),
                    child: const Text('Quitar filtro'),
                  )
                : FilledButton.icon(
                    onPressed: _nuevoProyecto,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar proyecto'),
                  ),
          ],
        ),
      ),
    );
  }
}
