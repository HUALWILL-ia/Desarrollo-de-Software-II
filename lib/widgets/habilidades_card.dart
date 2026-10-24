import 'package:flutter/material.dart';

import '../utils/constantes.dart';

/// Nube de habilidades técnicas con Wrap + Chip.
class HabilidadesCard extends StatelessWidget {
  const HabilidadesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 8,
          runSpacing: 10,
          children: Textos.habilidades.map((habilidad) {
            return Chip(
              avatar: const Icon(Icons.code, size: 17),
              label: Text(habilidad),
            );
          }).toList(),
        ),
      ),
    );
  }
}
