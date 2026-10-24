import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/perfil.dart';

/// Tarjeta de contacto: datos del perfil + acciones rápidas.
class ContactoCard extends StatelessWidget {
  const ContactoCard({
    super.key,
    required this.perfil,
    required this.onEditarPerfil,
  });

  final Perfil perfil;
  final VoidCallback onEditarPerfil;

  Future<void> _copiar(BuildContext context, String etiqueta, String valor) async {
    await Clipboard.setData(ClipboardData(text: valor));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$etiqueta copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _item(context, Icons.email_outlined, 'Correo', perfil.correo),
            const Divider(),
            _item(context, Icons.phone_outlined, 'Teléfono', perfil.telefono),
            const Divider(),
            _item(context, Icons.location_on_outlined, 'Ubicación', perfil.ubicacion),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _accion(
                    Icons.email,
                    'Correo',
                    () => _copiar(context, 'Correo', perfil.correo),
                  ),
                ),
                Expanded(
                  child: _accion(
                    Icons.phone,
                    'Llamar',
                    () => _copiar(context, 'Teléfono', perfil.telefono),
                  ),
                ),
                Expanded(
                  child: _accion(Icons.link, 'Perfil', onEditarPerfil),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icono, String titulo, String valor) {
    return InkWell(
      onTap: () => _copiar(context, titulo, valor),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
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
      ),
    );
  }

  Widget _accion(IconData icono, String texto, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono),
            const SizedBox(height: 4),
            Text(texto, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
