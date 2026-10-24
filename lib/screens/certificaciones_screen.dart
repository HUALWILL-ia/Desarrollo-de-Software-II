import 'package:flutter/material.dart';

import '../data/certificacion_repository.dart';
import '../models/certificacion.dart';
import '../utils/constantes.dart';
import '../utils/validadores.dart';

/// Lista de certificaciones con alta, edición y eliminación.
class CertificacionesScreen extends StatefulWidget {
  const CertificacionesScreen({super.key});

  @override
  State<CertificacionesScreen> createState() => _CertificacionesScreenState();
}

class _CertificacionesScreenState extends State<CertificacionesScreen> {
  final _repo = CertificacionRepository();

  EstadoCarga _estado = EstadoCarga.cargando;
  String? _mensajeError;
  List<Certificacion> _lista = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final lista = await _repo.listar();
      if (!mounted) return;
      setState(() {
        _lista = lista;
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

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirFormulario([Certificacion? existente]) async {
    final resultado = await showDialog<Certificacion>(
      context: context,
      builder: (_) => _CertificacionDialog(certificacion: existente),
    );
    if (resultado == null) return;

    try {
      if (resultado.id == null) {
        await _repo.insertar(resultado);
        _mensaje('Certificación registrada');
      } else {
        await _repo.actualizar(resultado);
        _mensaje('Certificación actualizada');
      }
      await _cargar();
    } catch (e) {
      _mensaje('No se pudo guardar: $e');
    }
  }

  Future<void> _eliminar(Certificacion c) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar certificación'),
        content: Text('¿Desea eliminar "${c.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await _repo.eliminar(c.id!);
      _mensaje('Certificación eliminada');
      await _cargar();
    } catch (e) {
      _mensaje('No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificaciones')),
      body: _cuerpo(),
      floatingActionButton: _estado == EstadoCarga.listo
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
    );
  }

  Widget _cuerpo() {
    switch (_estado) {
      case EstadoCarga.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoCarga.error:
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
                const SizedBox(height: 12),
                Text(_mensajeError ?? 'Error desconocido', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _estado = EstadoCarga.cargando);
                    _cargar();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      case EstadoCarga.listo:
        return _lista.isEmpty ? _vacio() : _listado();
    }
  }

  Widget _vacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aún no registras certificaciones.\nUsa el botón "Nueva" para agregar una.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _listado() {
    final totalHoras = _lista.fold<int>(0, (suma, c) => suma + (c.horas ?? 0));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text('${_lista.length} certificaciones'),
                subtitle: Text('$totalHoras horas acumuladas'),
              ),
            ),
            const SizedBox(height: 8),
            for (final c in _lista)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(c.nombre),
                  subtitle: Text(
                    [
                      c.entidad,
                      '${c.anio}',
                      if (c.horas != null) '${c.horas} h',
                    ].join(' • '),
                  ),
                  onTap: () => _abrirFormulario(c),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _eliminar(c),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo con formulario validado para crear o editar una certificación.
class _CertificacionDialog extends StatefulWidget {
  const _CertificacionDialog({this.certificacion});

  final Certificacion? certificacion;

  @override
  State<_CertificacionDialog> createState() => _CertificacionDialogState();
}

class _CertificacionDialogState extends State<_CertificacionDialog> {
  static const int _anioMinimoCert = 2010;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _entidadCtrl;
  late final TextEditingController _horasCtrl;
  late final TextEditingController _urlCtrl;
  int? _anio;

  @override
  void initState() {
    super.initState();
    final c = widget.certificacion;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _entidadCtrl = TextEditingController(text: c?.entidad ?? '');
    _horasCtrl = TextEditingController(text: c?.horas?.toString() ?? '');
    _urlCtrl = TextEditingController(text: c?.url ?? '');
    final anio = c?.anio ?? Limites.anioActual;
    _anio = (anio >= _anioMinimoCert && anio <= Limites.anioActual) ? anio : null;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _entidadCtrl.dispose();
    _horasCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final horas = _horasCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    Navigator.pop(
      context,
      Certificacion(
        id: widget.certificacion?.id,
        nombre: _nombreCtrl.text.trim(),
        entidad: _entidadCtrl.text.trim(),
        anio: _anio!,
        horas: horas.isEmpty ? null : int.parse(horas),
        url: url.isEmpty ? null : url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anios = [
      for (var a = Limites.anioActual; a >= _anioMinimoCert; a--) a,
    ];

    return AlertDialog(
      title: Text(
        widget.certificacion == null ? 'Nueva certificación' : 'Editar certificación',
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: Validadores.nombreCertificacion,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _entidadCtrl,
                  decoration: const InputDecoration(labelText: 'Entidad'),
                  validator: Validadores.entidad,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _anio,
                  decoration: const InputDecoration(labelText: 'Año'),
                  items: [
                    for (final a in anios)
                      DropdownMenuItem(value: a, child: Text('$a')),
                  ],
                  onChanged: (v) => setState(() => _anio = v),
                  validator: (v) => Validadores.anio(v, minimo: _anioMinimoCert),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _horasCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Horas (opcional)'),
                  validator: Validadores.horas,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'URL del certificado (opcional)',
                    hintText: 'https://...',
                  ),
                  validator: Validadores.urlHttps,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
