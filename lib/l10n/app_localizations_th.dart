// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'เชื่อมต่อแล้ว';

  @override
  String get statusConnecting => 'กำลังเชื่อมต่อ…';

  @override
  String get statusIdle => 'ว่าง';

  @override
  String get statusOffline => 'ออฟไลน์';

  @override
  String get statusPaired => 'จับคู่แล้ว';

  @override
  String connectedDevices(int count) {
    return 'เชื่อมต่อ $count เครื่อง';
  }

  @override
  String get sync => 'ซิงค์';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get languageSystem => 'ระบบ';

  @override
  String get devices => 'อุปกรณ์';

  @override
  String get history => 'ประวัติ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get clear => 'ล้าง';

  @override
  String get done => 'เสร็จสิ้น';

  @override
  String get pair => 'จับคู่';

  @override
  String get unpair => 'ยกเลิกการจับคู่';

  @override
  String get decline => 'ปฏิเสธ';

  @override
  String get save => 'บันทึก';

  @override
  String get share => 'แชร์';

  @override
  String get copy => 'คัดลอก';

  @override
  String get copied => 'คัดลอกแล้ว';

  @override
  String get lookingForDevices => 'กำลังค้นหาอุปกรณ์…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'เปิด Plokee บนอุปกรณ์อื่น\nในเครือข่ายเดียวกัน';

  @override
  String newDeviceAt(String address) {
    return 'ใหม่ · $address';
  }

  @override
  String pairingWith(String name) {
    return 'กำลังจับคู่กับ “$name”';
  }

  @override
  String get pairingRequest => 'คำขอจับคู่';

  @override
  String get pairingFailed => 'จับคู่ไม่สำเร็จ';

  @override
  String get confirmOnOtherDevice =>
      'ยืนยันบนอุปกรณ์อีกเครื่อง ทั้งสองเครื่องควรแสดงรหัสนี้:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) ต้องการจับคู่';
  }

  @override
  String nowConnected(String name) {
    return '“$name” เชื่อมต่อแล้ว คลิปบอร์ดของคุณจะซิงค์โดยอัตโนมัติ';
  }

  @override
  String get makeSureSameCode => 'ตรวจสอบว่าทั้งสองอุปกรณ์แสดงรหัสเดียวกัน:';

  @override
  String get requestDeclinedOrTimedOut => 'คำขอถูกปฏิเสธหรือหมดเวลา';

  @override
  String get nothingCopiedYet => 'ยังไม่ได้คัดลอกอะไร';

  @override
  String get copiesShowUpHere =>
      'สิ่งที่คุณคัดลอกจะแสดงที่นี่และซิงค์\nไปยังอุปกรณ์ที่จับคู่ไว้';

  @override
  String get clearHistory => 'ล้างประวัติ';

  @override
  String get clearHistoryQuestion => 'ล้างประวัติหรือไม่?';

  @override
  String get clearHistoryExplanation =>
      'การทำเช่นนี้จะลบรายการที่บันทึกไว้ทั้งหมดบนอุปกรณ์นี้ อุปกรณ์ที่จับคู่จะเก็บประวัติของตนเอง';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'จาก $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'รูปภาพ ($size)';
  }

  @override
  String get openInBrowser => 'เปิดในเบราว์เซอร์';

  @override
  String get writeEmail => 'เขียนอีเมล';

  @override
  String get saveImage => 'บันทึกรูปภาพ';

  @override
  String get showInFolder => 'แสดงในโฟลเดอร์';

  @override
  String get imageSaved => 'บันทึกรูปภาพแล้ว';

  @override
  String get couldNotSaveImage => 'ไม่สามารถบันทึกรูปภาพได้';

  @override
  String get couldNotOpenLink => 'ไม่สามารถเปิดลิงก์ได้';

  @override
  String get couldNotOpenFolder => 'ไม่สามารถเปิดโฟลเดอร์ได้';

  @override
  String get imageNoLongerAvailable => 'รูปภาพนี้ไม่พร้อมใช้งานแล้ว';

  @override
  String get filesNoLongerAvailable => 'ไฟล์เหล่านี้ไม่พร้อมใช้งานแล้ว';

  @override
  String get sendClipboard => 'ส่งคลิปบอร์ด';

  @override
  String get clipboardSent => 'ส่งคลิปบอร์ดแล้ว';

  @override
  String get nothingNewToSend => 'ไม่มีอะไรใหม่ให้ส่ง';

  @override
  String get deviceName => 'ชื่ออุปกรณ์';

  @override
  String get deviceNameExplanation => 'ชื่อที่อุปกรณ์อื่นเห็น';

  @override
  String get syncClipboard => 'ซิงค์คลิปบอร์ด';

  @override
  String get syncClipboardExplanation =>
      'ส่งและรับรายการกับอุปกรณ์ที่จับคู่ไว้';

  @override
  String get readClipboardOnOpen => 'อ่านคลิปบอร์ดเมื่อเปิด';

  @override
  String get readClipboardOnOpenExplanation =>
      'ตรวจสอบคลิปบอร์ดโดยอัตโนมัติเมื่อแอปกลับมาทำงานเบื้องหน้า';

  @override
  String get keepSyncingInBackground => 'ซิงค์ต่อในเบื้องหลัง';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'เชื่อมต่ออยู่เสมอเมื่อย่อ Plokee ไว้ จะแสดงการแจ้งเตือนถาวร';

  @override
  String get couldNotStart => 'เริ่มทำงานไม่ได้';

  @override
  String get trayOpenPlokee => 'เปิด Plokee';

  @override
  String get trayCheckClipboardNow => 'ตรวจสอบคลิปบอร์ดตอนนี้';

  @override
  String get trayRecentClipboard => 'คลิปบอร์ดล่าสุด';

  @override
  String get traySyncClipboard => 'ซิงค์คลิปบอร์ด';

  @override
  String get trayQuit => 'ออก';

  @override
  String get traySyncIsOn => 'เปิดการซิงค์';

  @override
  String get traySyncIsPaused => 'หยุดการซิงค์ชั่วคราว';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · ออนไลน์ $online จาก $total เครื่อง';
  }

  @override
  String get notificationChannelName => 'การซิงค์คลิปบอร์ด';

  @override
  String get notificationChannelDescription =>
      'ทำให้ Plokee เชื่อมต่อกับอุปกรณ์ที่จับคู่ไว้';

  @override
  String get notificationTitle => 'Plokee กำลังซิงค์';

  @override
  String get notificationText => 'เชื่อมต่อกับอุปกรณ์ที่จับคู่ไว้';
}
