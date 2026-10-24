import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/perfil.dart';
import '../services/camara_service.dart';
import '../services/preferencias_service.dart';
import '../utils/constantes.dart';
import '../utils/validadores.dart';
import '../widgets/avatar_perfil.dart';

/// Edición del perfil. Resultado: `bool` (si hubo cambios).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prefs = PreferenciasService.instancia;
  final _camara = CamaraService();

  late final TextEditingController _nombresCtrl;
  late final TextEditingController _carreraCtrl;
  late final TextEditingController _biografiaCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _ubicacionCtrl;

  late String _ciclo;
  late bool _disponible;
  String? _rutaFoto;
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    final p = _prefs.leerPerfil();
    _nombresCtrl = TextEditingController(text: p.nombres);
    _carreraCtrl = TextEditingController(text: p.carrera);
    _biografiaCtrl = TextEditingController(text: p.biografia);
    _correoCtrl = TextEditingController(text: p.correo);
    _telefonoCtrl = TextEditingController(text: p.telefono);
    _ubicacionCtrl = TextEditingController(text: p.ubicacion);
    _ciclo = Textos.ciclos.contains(p.ciclo) ? p.ciclo : 'VII';
    _disponible = p.disponible;
    _rutaFoto = p.rutaFoto;
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _carreraCtrl.dispose();
    _biografiaCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  /// Abre cámara o galería, copia la imagen y guarda la ruta (RF-1.8).
  Future<void> _cambiarFoto() async {
    final opcion = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar fotografía'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (opcion == null) return;

    try {
      final ruta = await _camara.obtenerImagen(opcion, anterior: _rutaFoto);
      if (!mounted || ruta == null) return;
      await _prefs.setRutaFotoPerfil(ruta);
      setState(() {
        _rutaFoto = ruta;
        _huboCambios = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la imagen: $e')),
      );
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final perfil = Perfil(
      nombres: _nombresCtrl.text.trim(),
      carrera: _carreraCtrl.text.trim(),
      ciclo: _ciclo,
      biografia: _biografiaCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      ubicacion: _ubicacionCtrl.text.trim(),
      disponible: _disponible,
      rutaFoto: _rutaFoto,
    );

    try {
      await _prefs.guardarPerfil(perfil);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _huboCambios);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar perfil')),
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
                      // Fotografía
                      Center(child: AvatarPerfil(rutaFoto: _rutaFoto, radius: 56)),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _cambiarFoto,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Cambiar fotografía'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _nombresCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombres y apellidos',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validadores.nombres,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _carreraCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Carrera',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validadores.carrera,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _ciclo,
                        decoration: const InputDecoration(
                          labelText: 'Ciclo',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final c in Textos.ciclos)
                            DropdownMenuItem(value: c, child: Text('$c Ciclo')),
                        ],
                        onChanged: (v) => setState(() => _ciclo = v ?? _ciclo),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _biografiaCtrl,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Biografía',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: Validadores.biografia,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validadores.correo,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validadores.telefono,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _ubicacionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validadores.ubicacion,
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Disponible para nuevos proyectos'),
                        value: _disponible,
                        onChanged: (v) => setState(() => _disponible = v),
                      ),
                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar perfil'),
                      ),
                    ],
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
