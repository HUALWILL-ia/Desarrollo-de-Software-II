import 'package:flutter/material.dart';

import '../models/perfil.dart';
import '../utils/constantes.dart';
import 'avatar_perfil.dart';

/// Tarjeta superior: portada con degradado, avatar superpuesto y datos del perfil.
class PerfilHeader extends StatelessWidget {
  const PerfilHeader({
    super.key,
    required this.perfil,
    required this.esMovil,
    required this.onEditar,
  });

  final Perfil perfil;
  final bool esMovil;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Banner superior con degradado
              Container(
                height: esMovil ? 130 : 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colores.bannerInicio, Colores.bannerFin],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar perfil',
                          onPressed: onEditar,
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.laptop_mac,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar con indicador de disponibilidad
              Positioned(
                left: esMovil ? 20 : 32,
                bottom: -50,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AvatarPerfil(rutaFoto: perfil.rutaFoto, radius: 50),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 4,
                      child: _badgeDisponibilidad(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Espacio para compensar el avatar superpuesto
          const SizedBox(height: 65),

          Padding(
            padding: EdgeInsets.all(esMovil ? 18 : 28),
            child: esMovil ? _datosMovil() : _datosEscritorio(),
          ),
        ],
      ),
    );
  }

  Widget _badgeDisponibilidad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: perfil.disponible ? Colors.green.shade600 : Colors.blueGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            perfil.disponible ? 'Disponible' : 'Ocupado',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _datosMovil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          perfil.nombres,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          perfil.carrera,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'UNSAAC • ${perfil.ciclo} Ciclo',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          perfil.biografia,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _datosEscritorio() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                perfil.nombres,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                perfil.carrera,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'UNSAAC • ${perfil.ciclo} Ciclo',
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 3,
          child: Text(
            perfil.biografia,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ],
    );
  }
}
