import 'package:flutter/material.dart';

/// Tarjeta con las tres métricas calculadas a partir de los datos almacenados.
class EstadisticasCard extends StatelessWidget {
  const EstadisticasCard({
    super.key,
    required this.proyectos,
    required this.certificaciones,
    required this.promedioHoras,
    required this.esMovil,
    this.onTapCertificaciones,
  });

  final int proyectos;
  final int certificaciones;
  final double promedioHoras;
  final bool esMovil;
  final VoidCallback? onTapCertificaciones;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(esMovil ? 12 : 18),
        child: Row(
          children: [
            Expanded(
              child: _Estadistica(
                titulo: 'Proyectos',
                valor: '$proyectos',
                icono: Icons.folder,
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTapCertificaciones,
                child: _Estadistica(
                  titulo: 'Certificaciones',
                  valor: '$certificaciones',
                  icono: Icons.school,
                ),
              ),
            ),
            Expanded(
              child: _Estadistica(
                titulo: 'Prom. horas por cert.',
                valor: promedioHoras.toStringAsFixed(1),
                icono: Icons.star,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  final String titulo;
  final String valor;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, size: 28),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
