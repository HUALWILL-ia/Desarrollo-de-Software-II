import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/proyecto_repository.dart';
import '../models/proyecto.dart';
import '../utils/constantes.dart';

/// Detalle de un proyecto. Argumento: `Proyecto`. Resultado: `bool` (si hubo cambios).
class ProyectoDetalleScreen extends StatefulWidget {
  const ProyectoDetalleScreen({super.key, required this.proyecto});

  final Proyecto proyecto;

  @override
  State<ProyectoDetalleScreen> createState() => _ProyectoDetalleScreenState();
}

class _ProyectoDetalleScreenState extends State<ProyectoDetalleScreen> {
  final _repo = ProyectoRepository();

  late Proyecto _proyecto;
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    _proyecto = widget.proyecto;
  }

  Future<void> _editar() async {
    final guardado = await Navigator.pushNamed<Proyecto>(
      context,
      Rutas.proyectoForm,
      arguments: _proyecto,
    );
    if (guardado == null || !mounted) return;
    setState(() {
      _proyecto = guardado;
      _huboCambios = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proyecto actualizado')),
    );
  }

  Future<void> _eliminar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: Text(
          '¿Desea eliminar "${_proyecto.titulo}"? Esta acción no se puede deshacer.',
        ),
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
      await _repo.eliminar(_proyecto.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  Future<void> _copiarRepositorio(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace copiado al portapapeles')),
    );
  }

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = _proyecto;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _huboCambios);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del proyecto'),
          actions: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: _editar,
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: _eliminar,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.indigo.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                p.destacado ? Icons.folder_special : Icons.folder_outlined,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                p.titulo,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Chip(
                              avatar: const Icon(Icons.event, size: 16),
                              label: Text('${p.anio}'),
                            ),
                            if (p.destacado)
                              const Chip(
                                avatar: Icon(Icons.star, size: 16, color: Colors.amber),
                                label: Text('Destacado'),
                              ),
                          ],
                        ),
                        const Divider(height: 28),
                        const Text(
                          'Descripción',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(p.descripcion, style: const TextStyle(height: 1.5)),
                        const SizedBox(height: 18),
                        const Text(
                          'Tecnologías',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final t in p.tecnologias) Chip(label: Text(t)),
                          ],
                        ),
                        if (p.repositorio != null) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Repositorio',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.link, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: SelectableText(p.repositorio!)),
                              IconButton(
                                tooltip: 'Copiar enlace',
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () => _copiarRepositorio(p.repositorio!),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          'Registrado el ${_fecha(p.creadoEn)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _editar,
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _eliminar,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
