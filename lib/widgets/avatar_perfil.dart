import 'dart:io';

import 'package:flutter/material.dart';

/// Avatar circular: muestra la foto guardada o la imagen por defecto de assets.
class AvatarPerfil extends StatelessWidget {
  const AvatarPerfil({super.key, this.rutaFoto, this.radius = 50});

  final String? rutaFoto;
  final double radius;

  ImageProvider _imagen() {
    final ruta = rutaFoto;
    if (ruta != null && File(ruta).existsSync()) {
      return FileImage(File(ruta));
    }
    return const AssetImage('assets/eddy.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.indigo.withValues(alpha: 0.1),
      backgroundImage: _imagen(),
      onBackgroundImageError: (error, stackTrace) {},
    );
  }
}
