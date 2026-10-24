import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Captura o selecciona una imagen y la copia al directorio de la aplicación.
class CamaraService {
  final ImagePicker _picker = ImagePicker();

  /// Devuelve la ruta de la copia guardada o `null` si se canceló.
  /// Si se indica [anterior], esa foto se elimina cuando está en la carpeta de la app.
  Future<String?> obtenerImagen(ImageSource origen, {String? anterior}) async {
    final archivo = await _picker.pickImage(
      source: origen,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (archivo == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final destino = p.join(
      dir.path,
      'foto_perfil_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(archivo.path).copy(destino);

    if (anterior != null && p.dirname(anterior) == dir.path) {
      final viejo = File(anterior);
      if (await viejo.exists()) await viejo.delete();
    }
    return destino;
  }
}
