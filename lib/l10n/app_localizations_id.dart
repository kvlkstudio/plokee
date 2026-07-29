// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Terhubung';

  @override
  String get statusConnecting => 'Menghubungkan…';

  @override
  String get statusIdle => 'Siaga';

  @override
  String get statusOffline => 'Luring';

  @override
  String get statusPaired => 'Terpasangkan';

  @override
  String connectedDevices(int count) {
    return '$count terhubung';
  }

  @override
  String get sync => 'Sinkron';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get devices => 'Perangkat';

  @override
  String get history => 'Riwayat';

  @override
  String get cancel => 'Batal';

  @override
  String get clear => 'Hapus';

  @override
  String get done => 'Selesai';

  @override
  String get pair => 'Pasangkan';

  @override
  String get unpair => 'Lepas pasangan';

  @override
  String get decline => 'Tolak';

  @override
  String get save => 'Simpan';

  @override
  String get share => 'Bagikan';

  @override
  String get copy => 'Salin';

  @override
  String get copied => 'Disalin';

  @override
  String get lookingForDevices => 'Mencari perangkat…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Buka Plokee di perangkat lain\ndi jaringan yang sama.';

  @override
  String newDeviceAt(String address) {
    return 'Baru · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Memasangkan dengan “$name”';
  }

  @override
  String get pairingRequest => 'Permintaan pemasangan';

  @override
  String get pairingFailed => 'Pemasangan gagal';

  @override
  String get confirmOnOtherDevice =>
      'Konfirmasi di perangkat lain. Keduanya harus menampilkan kode ini:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) ingin dipasangkan.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” kini terhubung. Papan klip Anda akan tersinkron otomatis.';
  }

  @override
  String get makeSureSameCode =>
      'Pastikan kedua perangkat menampilkan kode yang sama:';

  @override
  String get requestDeclinedOrTimedOut =>
      'Permintaan ditolak atau kedaluwarsa.';

  @override
  String get addByIp => 'Perangkat tidak muncul? Tambahkan via IP';

  @override
  String get addByIpTitle => 'Tambahkan perangkat via IP';

  @override
  String get addByIpExplanation =>
      'Beberapa jaringan menyembunyikan perangkat satu sama lain. Masukkan alamat IP perangkat lain untuk memasangkan langsung.';

  @override
  String get ipAddress => 'Alamat IP';

  @override
  String get add => 'Tambah';

  @override
  String get searching => 'Mencari…';

  @override
  String thisDeviceAddress(String address) {
    return 'Perangkat ini: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'Tidak ada perangkat Plokee di $address';
  }

  @override
  String get nothingCopiedYet => 'Belum ada yang disalin';

  @override
  String get copiesShowUpHere =>
      'Salinan Anda muncul di sini dan tersinkron\nke perangkat yang dipasangkan.';

  @override
  String get clearHistory => 'Hapus riwayat';

  @override
  String get clearHistoryQuestion => 'Hapus riwayat?';

  @override
  String get clearHistoryExplanation =>
      'Ini menghapus semua item tersimpan di perangkat ini. Perangkat terpasangkan menyimpan riwayatnya sendiri.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Dari $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Gambar ($size)';
  }

  @override
  String get openInBrowser => 'Buka di peramban';

  @override
  String get writeEmail => 'Tulis email';

  @override
  String get saveImage => 'Simpan gambar';

  @override
  String get showInFolder => 'Tampilkan di folder';

  @override
  String get imageSaved => 'Gambar disimpan';

  @override
  String get couldNotSaveImage => 'Tidak dapat menyimpan gambar';

  @override
  String get couldNotOpenLink => 'Tidak dapat membuka tautan';

  @override
  String get couldNotOpenFolder => 'Tidak dapat membuka folder';

  @override
  String get imageNoLongerAvailable => 'Gambar ini tidak lagi tersedia';

  @override
  String get filesNoLongerAvailable => 'Berkas ini tidak lagi tersedia';

  @override
  String get sendClipboard => 'Kirim papan klip';

  @override
  String get clipboardSent => 'Papan klip terkirim';

  @override
  String get nothingNewToSend => 'Tidak ada yang baru untuk dikirim';

  @override
  String get deviceName => 'Nama perangkat';

  @override
  String get deviceNameExplanation => 'Tampilan perangkat ini bagi yang lain.';

  @override
  String get syncClipboard => 'Sinkronkan papan klip';

  @override
  String get syncClipboardExplanation =>
      'Kirim dan terima item dengan perangkat terpasangkan.';

  @override
  String get readClipboardOnOpen => 'Baca papan klip saat dibuka';

  @override
  String get readClipboardOnOpenExplanation =>
      'Periksa papan klip otomatis saat aplikasi kembali ke depan.';

  @override
  String get keepSyncingInBackground => 'Terus sinkron di latar belakang';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Tetap terhubung saat Plokee diperkecil. Menampilkan notifikasi permanen.';

  @override
  String get couldNotStart => 'Tidak dapat memulai';

  @override
  String get trayOpenPlokee => 'Buka Plokee';

  @override
  String get trayCheckClipboardNow => 'Periksa papan klip sekarang';

  @override
  String get trayRecentClipboard => 'Papan klip terbaru';

  @override
  String get traySyncClipboard => 'Sinkronkan papan klip';

  @override
  String get trayQuit => 'Keluar';

  @override
  String get traySyncIsOn => 'Sinkron aktif';

  @override
  String get traySyncIsPaused => 'Sinkron dijeda';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online dari $total perangkat daring';
  }

  @override
  String get notificationChannelName => 'Sinkronisasi papan klip';

  @override
  String get notificationChannelDescription =>
      'Menjaga Plokee tetap terhubung ke perangkat terpasangkan.';

  @override
  String get notificationTitle => 'Plokee sedang menyinkronkan';

  @override
  String get notificationText => 'Terhubung ke perangkat terpasangkan';

  @override
  String notificationConnected(int count, int total) {
    return '$count dari $total perangkat terhubung';
  }

  @override
  String get notificationPaused => 'Sinkron dijeda';

  @override
  String get notificationPause => 'Jeda';

  @override
  String get notificationResume => 'Lanjutkan';

  @override
  String get syncRules => 'Aturan sinkronisasi';

  @override
  String syncRulesFor(String name) {
    return 'Yang disinkronkan perangkat ini dengan “$name”';
  }

  @override
  String get ruleSendTo => 'Kirim ke sana';

  @override
  String get ruleSendToExplanation =>
      'Kirim yang Anda salin di sini ke perangkat itu.';

  @override
  String get ruleReceiveFrom => 'Terima dari sana';

  @override
  String get ruleReceiveFromExplanation =>
      'Terapkan yang disalin di sana ke papan klip ini.';

  @override
  String get ruleKinds => 'Jenis';

  @override
  String get ruleText => 'Teks';

  @override
  String get ruleImages => 'Gambar';

  @override
  String get ruleFiles => 'Berkas';

  @override
  String get ruleSummaryNothing => 'Tidak ada';

  @override
  String get ruleSummaryReceiveOnly => 'Hanya terima';

  @override
  String get ruleSummarySendOnly => 'Hanya kirim';

  @override
  String get ruleSummaryCustom => 'Kustom';

  @override
  String get transfers => 'Transfer';

  @override
  String transferSendingTo(String name) {
    return 'Mengirim ke $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'Menerima dari $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done dari $total';
  }

  @override
  String get transferText => 'Teks';

  @override
  String get transferImage => 'Gambar';
}
