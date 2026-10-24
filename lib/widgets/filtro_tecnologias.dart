import 'package:flutter/material.dart';

/// Fila desplazable de ChoiceChip para filtrar proyectos por tecnología.
class FiltroTecnologias extends StatelessWidget {
  const FiltroTecnologias({
    super.key,
    required this.tecnologias,
    required this.seleccionada,
    required this.alSeleccionar,
  });

  final List<String> tecnologias;
  final String? seleccionada;
  final ValueChanged<String?> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todas'),
            selected: seleccionada == null,
            onSelected: (_) => alSeleccionar(null),
          ),
          for (final t in tecnologias)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(t),
                selected: seleccionada?.toLowerCase() == t.toLowerCase(),
                onSelected: (_) => alSeleccionar(t),
              ),
            ),
        ],
      ),
    );
  }
}
