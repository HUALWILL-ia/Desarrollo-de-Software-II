import 'package:flutter/material.dart';

import '../data/proyecto_repository.dart';
import '../models/proyecto.dart';
import '../utils/constantes.dart';
import '../utils/validadores.dart';

/// Formulario de alta / edición de un proyecto destacado.
/// Argumento: `Proyecto?` (nulo = alta). Resultado: el `Proyecto` guardado.
class ProyectoFormScreen extends StatefulWidget {
  const ProyectoFormScreen({super.key, this.proyecto});

  final Proyecto? proyecto;

  @override
  State<ProyectoFormScreen> createState() => _ProyectoFormScreenState();
}

class _ProyectoFormScreenState extends State<ProyectoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = ProyectoRepository();

  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _repositorioCtrl;
  final TextEditingController _tecCtrl = TextEditingController();

  late final List<String> _tecnologias;
  int? _anio;
  bool _destacado = false;
  bool _guardando = false;

  /// Resultado de la validación asíncrona del título único.
  String? _errorTituloDuplicado;

  bool get _esEdicion => widget.proyecto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.proyecto;
    _tituloCtrl = TextEditingController(text: p?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _repositorioCtrl = TextEditingController(text: p?.repositorio ?? '');
    _tecnologias = List<String>.of(p?.tecnologias ?? const []);
    _destacado = p?.destacado ?? false;

    final anio = p?.anio ?? Limites.anioActual;
    _anio = (anio >= Limites.anioMinimo && anio <= Limites.anioActual) ? anio : null;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _repositorioCtrl.dispose();
    _tecCtrl.dispose();
    super.dispose();
  }

  // ---------------- Tecnologías ----------------

  int _indiceTec(String t) =>
      _tecnologias.indexWhere((e) => e.toLowerCase() == t.toLowerCase());

  void _alternarTec(String t) {
    setState(() {
      final i = _indiceTec(t);
      if (i >= 0) {
        _tecnologias.removeAt(i);
      } else {
        _tecnologias.add(t);
      }
    });
  }

  void _agregarTec() {
    final t = _tecCtrl.text.trim().replaceAll(',', '');
    if (t.isEmpty || t.length > 25) return;
    if (_indiceTec(t) < 0) setState(() => _tecnologias.add(t));
    _tecCtrl.clear();
  }

  // ---------------- Guardado ----------------

  Future<void> _guardar() async {
    if (_guardando) return;
    FocusScope.of(context).unfocus();
    _agregarTec(); // por si quedó una tecnología escrita sin confirmar

    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final titulo = _tituloCtrl.text.trim();

      // Validación asíncrona: título único
      final duplicado = await _repo.existeTitulo(
        titulo,
        excluirId: widget.proyecto?.id,
      );
      if (!mounted) return;
      if (duplicado) {
        setState(() {
          _errorTituloDuplicado = 'Ya registró un proyecto con ese título.';
          _guardando = false;
        });
        _formKey.currentState!.validate();
        return;
      }

      final repo = _repositorioCtrl.text.trim();
      final proyecto = Proyecto(
        id: widget.proyecto?.id,
        titulo: titulo,
        descripcion: _descripcionCtrl.text.trim(),
        tecnologias: List<String>.of(_tecnologias),
        repositorio: repo.isEmpty ? null : repo,
        anio: _anio!,
        destacado: _destacado,
        creadoEn: widget.proyecto?.creadoEn ?? DateTime.now(),
      );

      final Proyecto guardado;
      if (proyecto.id == null) {
        guardado = proyecto.conId(await _repo.insertar(proyecto));
      } else {
        await _repo.actualizar(proyecto);
        guardado = proyecto;
      }

      if (!mounted) return;
      Navigator.pop(context, guardado);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el proyecto: $e')),
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final anios = [
      for (var a = Limites.anioActual; a >= Limites.anioMinimo; a--) a,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar proyecto' : 'Nuevo proyecto'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    TextFormField(
                      controller: _tituloCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (_errorTituloDuplicado != null) {
                          setState(() => _errorTituloDuplicado = null);
                        }
                      },
                      validator: (v) =>
                          Validadores.titulo(v) ?? _errorTituloDuplicado,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descripcionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.descripcion,
                    ),
                    const SizedBox(height: 16),

                    // Tecnologías
                    _campoTecnologias(),
                    const SizedBox(height: 16),

                    // Repositorio
                    TextFormField(
                      controller: _repositorioCtrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Repositorio (opcional)',
                        hintText: 'https://github.com/usuario/proyecto',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.urlHttps,
                    ),
                    const SizedBox(height: 16),

                    // Año
                    DropdownButtonFormField<int>(
                      initialValue: _anio,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final a in anios)
                          DropdownMenuItem(value: a, child: Text('$a')),
                      ],
                      onChanged: (v) => setState(() => _anio = v),
                      validator: Validadores.anio,
                    ),
                    const SizedBox(height: 8),

                    // Destacado
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Proyecto destacado'),
                      value: _destacado,
                      onChanged: (v) => setState(() => _destacado = v),
                    ),
                    const SizedBox(height: 16),

                    FilledButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_esEdicion ? 'Guardar cambios' : 'Registrar proyecto'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTecnologias() {
    return FormField<List<String>>(
      initialValue: _tecnologias,
      validator: (_) => Validadores.tecnologias(_tecnologias),
      builder: (campo) {
        final sugeridas = Textos.tecnologiasSugeridas;
        final personalizadas = _tecnologias.where(
          (t) => !sugeridas.any((s) => s.toLowerCase() == t.toLowerCase()),
        );
        final opciones = [...sugeridas, ...personalizadas];

        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tecnologías (mínimo 3)',
            border: const OutlineInputBorder(),
            errorText: campo.errorText,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final t in opciones)
                    FilterChip(
                      label: Text(t),
                      selected: _indiceTec(t) >= 0,
                      onSelected: (_) {
                        _alternarTec(t);
                        campo.didChange(List<String>.of(_tecnologias));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tecCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Escribir otra tecnología',
                        isDense: true,
                      ),
                      onSubmitted: (_) {
                        _agregarTec();
                        campo.didChange(List<String>.of(_tecnologias));
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Agregar tecnología',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      _agregarTec();
                      campo.didChange(List<String>.of(_tecnologias));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
