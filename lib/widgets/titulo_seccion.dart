import 'package:flutter/material.dart';

/// Encabezado estándar de sección: ícono + texto (+ acción opcional a la derecha).
class TituloSeccion extends StatelessWidget {
  const TituloSeccion({
    super.key,
    required this.titulo,
    required this.icono,
    this.accion,
  });

  final String titulo;
  final IconData icono;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 25),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?accion,
      ],
    );
  }
}
