import 'package:flutter/material.dart';

import '../models/proyecto.dart';

/// Tarjeta visual de un proyecto (se usa en lista móvil y en cuadrícula).
class TarjetaProyecto extends StatelessWidget {
  const TarjetaProyecto({super.key, required this.proyecto, required this.onTap});

  final Proyecto proyecto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono superior con año y marca de destacado
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.indigo.withValues(alpha: 0.1),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        proyecto.destacado ? Icons.folder_special : Icons.folder_outlined,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (proyecto.destacado)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.star, size: 14, color: Colors.amber),
                            ),
                          Text(
                            '${proyecto.anio}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proyecto.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proyecto.descripcion,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: proyecto.tecnologias
                    .take(3)
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
