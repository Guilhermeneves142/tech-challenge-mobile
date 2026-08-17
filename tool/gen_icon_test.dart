// Script utilitário (não é um teste real) para gerar o ícone do app a partir
// de um desenho vetorial próprio — uma carteira nas cores da marca — sem
// depender de nenhuma imagem externa nem de fontes de ícone.
//
// Roda via `flutter test tool/gen_icon_test.dart` porque `dart:ui` (Canvas,
// PictureRecorder) só fica disponível com o binding do Flutter inicializado;
// `testWidgets` faz isso por nós. Gera dois PNGs em `assets/icon/`, que o
// `flutter_launcher_icons` usa para criar os ícones reais do Android/iOS.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> _renderWalletMark({
  required double size,
  required Color? background, // null = fundo transparente
}) async {
  const body = Colors.white;
  const flap = Color(0xFFC3DB99); // brand-secondary
  const clasp = Color(0xFF3A5A40); // brand-tertiary

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  if (background != null) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), Paint()..color = background);
  }

  // Corpo da carteira: retângulo arredondado branco, centralizado.
  final bodyRect = Rect.fromCenter(
    center: Offset(size / 2, size / 2),
    width: size * 0.56,
    height: size * 0.40,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(size * 0.08)),
    Paint()..color = body,
  );

  // Aba superior (flap) verde-claro, só com os cantos de cima arredondados.
  final flapRect = Rect.fromLTWH(
    bodyRect.left,
    bodyRect.top + size * 0.06,
    bodyRect.width,
    size * 0.16,
  );
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      flapRect,
      topLeft: Radius.circular(size * 0.08),
      topRight: Radius.circular(size * 0.08),
    ),
    Paint()..color = flap,
  );

  // Fecho (clasp): círculo verde-escuro na borda direita da aba.
  canvas.drawCircle(
    Offset(bodyRect.right - size * 0.02, flapRect.top + flapRect.height / 2),
    size * 0.045,
    Paint()..color = clasp,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

void main() {
  testWidgets('gera assets/icon/app_icon*.png', (tester) async {
    await tester.runAsync(() async {
      Directory('assets/icon').createSync(recursive: true);

      // Ícone principal: fundo verde sólido (brand-primary) + marca branca.
      final main = await _renderWalletMark(
        size: 1024,
        background: const Color(0xFF3B783A),
      );
      File('assets/icon/app_icon.png').writeAsBytesSync(main);

      // Foreground do ícone adaptativo Android: mesma marca, fundo transparente.
      final foreground = await _renderWalletMark(size: 1024, background: null);
      File('assets/icon/app_icon_foreground.png').writeAsBytesSync(foreground);
    });
  });
}
