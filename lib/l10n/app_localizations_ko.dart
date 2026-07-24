// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => '연결됨';

  @override
  String get statusConnecting => '연결 중…';

  @override
  String get statusIdle => '대기 중';

  @override
  String get statusOffline => '오프라인';

  @override
  String get statusPaired => '페어링됨';

  @override
  String connectedDevices(int count) {
    return '$count대 연결됨';
  }

  @override
  String get sync => '동기화';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템';

  @override
  String get devices => '기기';

  @override
  String get history => '기록';

  @override
  String get cancel => '취소';

  @override
  String get clear => '지우기';

  @override
  String get done => '완료';

  @override
  String get pair => '페어링';

  @override
  String get unpair => '페어링 해제';

  @override
  String get decline => '거절';

  @override
  String get save => '저장';

  @override
  String get share => '공유';

  @override
  String get copy => '복사';

  @override
  String get copied => '복사됨';

  @override
  String get lookingForDevices => '기기 검색 중…';

  @override
  String get openPlokeeOnAnotherDevice => '같은 네트워크의 다른 기기에서\nPlokee를 열어 주세요.';

  @override
  String newDeviceAt(String address) {
    return '새 기기 · $address';
  }

  @override
  String pairingWith(String name) {
    return '“$name”와(과) 페어링 중';
  }

  @override
  String get pairingRequest => '페어링 요청';

  @override
  String get pairingFailed => '페어링 실패';

  @override
  String get confirmOnOtherDevice => '다른 기기에서 확인하세요. 두 기기에 같은 코드가 표시되어야 합니다:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name”($platform)이(가) 페어링을 요청합니다.';
  }

  @override
  String nowConnected(String name) {
    return '“$name”이(가) 연결되었습니다. 클립보드가 자동으로 동기화됩니다.';
  }

  @override
  String get makeSureSameCode => '두 기기에 같은 코드가 표시되는지 확인하세요:';

  @override
  String get requestDeclinedOrTimedOut => '요청이 거절되었거나 시간이 초과되었습니다.';

  @override
  String get nothingCopiedYet => '아직 복사한 항목이 없습니다';

  @override
  String get copiesShowUpHere => '복사한 내용이 여기에 표시되고\n페어링된 기기와 동기화됩니다.';

  @override
  String get clearHistory => '기록 지우기';

  @override
  String get clearHistoryQuestion => '기록을 지울까요?';

  @override
  String get clearHistoryExplanation =>
      '이 기기에 저장된 모든 항목이 삭제됩니다. 페어링된 기기는 각자의 기록을 유지합니다.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return '$name에서 · $time';
  }

  @override
  String imageWithSize(String size) {
    return '이미지($size)';
  }

  @override
  String get openInBrowser => '브라우저에서 열기';

  @override
  String get writeEmail => '메일 작성';

  @override
  String get saveImage => '이미지 저장';

  @override
  String get showInFolder => '폴더에서 보기';

  @override
  String get imageSaved => '이미지 저장됨';

  @override
  String get couldNotSaveImage => '이미지를 저장할 수 없습니다';

  @override
  String get couldNotOpenLink => '링크를 열 수 없습니다';

  @override
  String get couldNotOpenFolder => '폴더를 열 수 없습니다';

  @override
  String get imageNoLongerAvailable => '이 이미지는 더 이상 사용할 수 없습니다';

  @override
  String get filesNoLongerAvailable => '이 파일들은 더 이상 사용할 수 없습니다';

  @override
  String get sendClipboard => '클립보드 보내기';

  @override
  String get clipboardSent => '클립보드를 보냈습니다';

  @override
  String get nothingNewToSend => '보낼 새 항목이 없습니다';

  @override
  String get deviceName => '기기 이름';

  @override
  String get deviceNameExplanation => '다른 기기에 표시되는 이름입니다.';

  @override
  String get syncClipboard => '클립보드 동기화';

  @override
  String get syncClipboardExplanation => '페어링된 기기와 항목을 주고받습니다.';

  @override
  String get readClipboardOnOpen => '열 때 클립보드 읽기';

  @override
  String get readClipboardOnOpenExplanation => '앱이 앞으로 나올 때 클립보드를 자동으로 확인합니다.';

  @override
  String get keepSyncingInBackground => '백그라운드에서 계속 동기화';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Plokee가 최소화되어도 연결을 유지합니다. 상시 알림이 표시됩니다.';

  @override
  String get couldNotStart => '시작할 수 없습니다';

  @override
  String get trayOpenPlokee => 'Plokee 열기';

  @override
  String get trayCheckClipboardNow => '지금 클립보드 확인';

  @override
  String get trayRecentClipboard => '최근 클립보드';

  @override
  String get traySyncClipboard => '클립보드 동기화';

  @override
  String get trayQuit => '종료';

  @override
  String get traySyncIsOn => '동기화 켜짐';

  @override
  String get traySyncIsPaused => '동기화 일시중지됨';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $total대 중 $online대 온라인';
  }

  @override
  String get notificationChannelName => '클립보드 동기화';

  @override
  String get notificationChannelDescription =>
      'Plokee를 페어링된 기기와 연결된 상태로 유지합니다.';

  @override
  String get notificationTitle => 'Plokee 동기화 중';

  @override
  String get notificationText => '페어링된 기기에 연결됨';
}
