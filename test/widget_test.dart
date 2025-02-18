import 'package:DetectFakeLocation/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Menampilkan elemen utama pada layar utama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp());

    // Periksa apakah AppBar ditampilkan
    expect(find.text('Deteksi Root & Lokasi Palsu'), findsOneWidget);

    // Periksa apakah tombol "Cek Ulang" ada
    expect(find.text('🔄 Cek Ulang'), findsOneWidget);

    // Periksa apakah tombol "Lihat Peta" ada
    expect(find.text('🗺 Lihat Peta'), findsOneWidget);
  });

  testWidgets('Tombol Cek Ulang dapat ditekan', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Temukan tombol "Cek Ulang" dan tekan
    final cekUlangButton = find.text('🔄 Cek Ulang');
    expect(cekUlangButton, findsOneWidget);
    await tester.tap(cekUlangButton);
    await tester.pump();

    // Tidak ada perubahan tampilan spesifik yang diuji setelah ditekan,
    // tetapi kita bisa memastikan tombol dapat ditekan tanpa error.
  });
}
