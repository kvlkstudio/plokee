// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Đã kết nối';

  @override
  String get statusConnecting => 'Đang kết nối…';

  @override
  String get statusIdle => 'Chờ';

  @override
  String get statusOffline => 'Ngoại tuyến';

  @override
  String get statusPaired => 'Đã ghép nối';

  @override
  String connectedDevices(int count) {
    return '$count đã kết nối';
  }

  @override
  String get sync => 'Đồng bộ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Hệ thống';

  @override
  String get devices => 'Thiết bị';

  @override
  String get history => 'Lịch sử';

  @override
  String get cancel => 'Hủy';

  @override
  String get clear => 'Xóa';

  @override
  String get done => 'Xong';

  @override
  String get pair => 'Ghép nối';

  @override
  String get unpair => 'Hủy ghép nối';

  @override
  String get decline => 'Từ chối';

  @override
  String get save => 'Lưu';

  @override
  String get share => 'Chia sẻ';

  @override
  String get copy => 'Sao chép';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get lookingForDevices => 'Đang tìm thiết bị…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Mở Plokee trên thiết bị khác\ntrong cùng mạng.';

  @override
  String newDeviceAt(String address) {
    return 'Mới · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Đang ghép nối với “$name”';
  }

  @override
  String get pairingRequest => 'Yêu cầu ghép nối';

  @override
  String get pairingFailed => 'Ghép nối thất bại';

  @override
  String get confirmOnOtherDevice =>
      'Xác nhận trên thiết bị kia. Cả hai phải hiển thị mã này:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) muốn ghép nối.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” đã kết nối. Bảng nhớ tạm của bạn sẽ tự động đồng bộ.';
  }

  @override
  String get makeSureSameCode =>
      'Đảm bảo cả hai thiết bị hiển thị cùng một mã:';

  @override
  String get requestDeclinedOrTimedOut => 'Yêu cầu đã bị từ chối hoặc hết hạn.';

  @override
  String get addByIp => 'Không thấy thiết bị? Thêm bằng IP';

  @override
  String get addByIpTitle => 'Thêm thiết bị bằng IP';

  @override
  String get addByIpExplanation =>
      'Một số mạng ẩn các thiết bị với nhau. Nhập địa chỉ IP của thiết bị kia để ghép nối trực tiếp.';

  @override
  String get ipAddress => 'Địa chỉ IP';

  @override
  String get add => 'Thêm';

  @override
  String get searching => 'Đang tìm…';

  @override
  String thisDeviceAddress(String address) {
    return 'Thiết bị này: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'Không tìm thấy thiết bị Plokee tại $address';
  }

  @override
  String get nothingCopiedYet => 'Chưa sao chép gì';

  @override
  String get copiesShowUpHere =>
      'Nội dung bạn sao chép sẽ hiện ở đây và đồng bộ\nvới các thiết bị đã ghép nối.';

  @override
  String get clearHistory => 'Xóa lịch sử';

  @override
  String get clearHistoryQuestion => 'Xóa lịch sử?';

  @override
  String get clearHistoryExplanation =>
      'Thao tác này xóa mọi mục đã lưu trên thiết bị này. Thiết bị đã ghép nối vẫn giữ lịch sử riêng.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Từ $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Hình ảnh ($size)';
  }

  @override
  String get openInBrowser => 'Mở trong trình duyệt';

  @override
  String get writeEmail => 'Soạn email';

  @override
  String get saveImage => 'Lưu hình ảnh';

  @override
  String get showInFolder => 'Hiện trong thư mục';

  @override
  String get imageSaved => 'Đã lưu hình ảnh';

  @override
  String get couldNotSaveImage => 'Không thể lưu hình ảnh';

  @override
  String get couldNotOpenLink => 'Không thể mở liên kết';

  @override
  String get couldNotOpenFolder => 'Không thể mở thư mục';

  @override
  String get imageNoLongerAvailable => 'Hình ảnh này không còn khả dụng';

  @override
  String get filesNoLongerAvailable => 'Các tệp này không còn khả dụng';

  @override
  String get sendClipboard => 'Gửi bảng nhớ tạm';

  @override
  String get clipboardSent => 'Đã gửi bảng nhớ tạm';

  @override
  String get nothingNewToSend => 'Không có gì mới để gửi';

  @override
  String get deviceName => 'Tên thiết bị';

  @override
  String get deviceNameExplanation =>
      'Cách thiết bị này hiển thị với người khác.';

  @override
  String get syncClipboard => 'Đồng bộ bảng nhớ tạm';

  @override
  String get syncClipboardExplanation =>
      'Gửi và nhận nội dung với các thiết bị đã ghép nối.';

  @override
  String get readClipboardOnOpen => 'Đọc bảng nhớ tạm khi mở';

  @override
  String get readClipboardOnOpenExplanation =>
      'Tự động kiểm tra bảng nhớ tạm khi ứng dụng trở lại phía trước.';

  @override
  String get keepSyncingInBackground => 'Tiếp tục đồng bộ ở nền';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Giữ kết nối khi Plokee được thu nhỏ. Hiển thị thông báo thường trực.';

  @override
  String get couldNotStart => 'Không thể khởi động';

  @override
  String get trayOpenPlokee => 'Mở Plokee';

  @override
  String get trayCheckClipboardNow => 'Kiểm tra bảng nhớ tạm ngay';

  @override
  String get trayRecentClipboard => 'Bảng nhớ tạm gần đây';

  @override
  String get traySyncClipboard => 'Đồng bộ bảng nhớ tạm';

  @override
  String get trayQuit => 'Thoát';

  @override
  String get traySyncIsOn => 'Đồng bộ đang bật';

  @override
  String get traySyncIsPaused => 'Đồng bộ tạm dừng';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online/$total thiết bị trực tuyến';
  }

  @override
  String get notificationChannelName => 'Đồng bộ bảng nhớ tạm';

  @override
  String get notificationChannelDescription =>
      'Giữ Plokee kết nối với các thiết bị đã ghép nối.';

  @override
  String get notificationTitle => 'Plokee đang đồng bộ';

  @override
  String get notificationText => 'Đã kết nối với thiết bị đã ghép nối';

  @override
  String notificationConnected(int count, int total) {
    return 'Đã kết nối $count/$total thiết bị';
  }

  @override
  String get notificationPaused => 'Đồng bộ tạm dừng';

  @override
  String get notificationPause => 'Tạm dừng';

  @override
  String get notificationResume => 'Tiếp tục';

  @override
  String get syncRules => 'Quy tắc đồng bộ';

  @override
  String syncRulesFor(String name) {
    return 'Nội dung thiết bị này đồng bộ với “$name”';
  }

  @override
  String get ruleSendTo => 'Gửi tới thiết bị đó';

  @override
  String get ruleSendToExplanation =>
      'Gửi những gì bạn sao chép ở đây tới thiết bị đó.';

  @override
  String get ruleReceiveFrom => 'Nhận từ thiết bị đó';

  @override
  String get ruleReceiveFromExplanation =>
      'Áp dụng những gì được sao chép ở đó vào bảng nhớ tạm này.';

  @override
  String get ruleKinds => 'Loại';

  @override
  String get ruleText => 'Văn bản';

  @override
  String get ruleImages => 'Hình ảnh';

  @override
  String get ruleFiles => 'Tệp';

  @override
  String get ruleSummaryNothing => 'Không gì';

  @override
  String get ruleSummaryReceiveOnly => 'Chỉ nhận';

  @override
  String get ruleSummarySendOnly => 'Chỉ gửi';

  @override
  String get ruleSummaryCustom => 'Tùy chỉnh';

  @override
  String get transfers => 'Truyền tệp';

  @override
  String transferSendingTo(String name) {
    return 'Đang gửi tới $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'Đang nhận từ $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done/$total';
  }

  @override
  String get transferText => 'Văn bản';

  @override
  String get transferImage => 'Hình ảnh';
}
