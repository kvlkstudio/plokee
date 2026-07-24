// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => '接続済み';

  @override
  String get statusConnecting => '接続中…';

  @override
  String get statusIdle => '待機中';

  @override
  String get statusOffline => 'オフライン';

  @override
  String get statusPaired => 'ペアリング済み';

  @override
  String connectedDevices(int count) {
    return '$count 台接続中';
  }

  @override
  String get sync => '同期';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get devices => 'デバイス';

  @override
  String get history => '履歴';

  @override
  String get cancel => 'キャンセル';

  @override
  String get clear => '消去';

  @override
  String get done => '完了';

  @override
  String get pair => 'ペアリング';

  @override
  String get unpair => 'ペアリング解除';

  @override
  String get decline => '拒否';

  @override
  String get save => '保存';

  @override
  String get share => '共有';

  @override
  String get copy => 'コピー';

  @override
  String get copied => 'コピーしました';

  @override
  String get lookingForDevices => 'デバイスを探しています…';

  @override
  String get openPlokeeOnAnotherDevice => '同じネットワーク上の別のデバイスで\nPlokee を開いてください。';

  @override
  String newDeviceAt(String address) {
    return '新規 · $address';
  }

  @override
  String pairingWith(String name) {
    return '「$name」とペアリング中';
  }

  @override
  String get pairingRequest => 'ペアリング要求';

  @override
  String get pairingFailed => 'ペアリングに失敗しました';

  @override
  String get confirmOnOtherDevice => 'もう一方のデバイスで確認してください。両方に同じコードが表示されます：';

  @override
  String wantsToPair(String name, String platform) {
    return '「$name」（$platform）がペアリングを求めています。';
  }

  @override
  String nowConnected(String name) {
    return '「$name」が接続されました。クリップボードは自動的に同期されます。';
  }

  @override
  String get makeSureSameCode => '両方のデバイスに同じコードが表示されていることを確認してください：';

  @override
  String get requestDeclinedOrTimedOut => '要求が拒否されたか、タイムアウトしました。';

  @override
  String get nothingCopiedYet => 'まだ何もコピーしていません';

  @override
  String get copiesShowUpHere => 'コピーした内容はここに表示され、\nペアリング済みのデバイスと同期されます。';

  @override
  String get clearHistory => '履歴を消去';

  @override
  String get clearHistoryQuestion => '履歴を消去しますか？';

  @override
  String get clearHistoryExplanation =>
      'このデバイスに保存されたすべての項目が削除されます。ペアリング済みのデバイスは各自の履歴を保持します。';

  @override
  String fromDeviceAtTime(String name, String time) {
    return '$name から · $time';
  }

  @override
  String imageWithSize(String size) {
    return '画像（$size）';
  }

  @override
  String get openInBrowser => 'ブラウザで開く';

  @override
  String get writeEmail => 'メールを作成';

  @override
  String get saveImage => '画像を保存';

  @override
  String get showInFolder => 'フォルダに表示';

  @override
  String get imageSaved => '画像を保存しました';

  @override
  String get couldNotSaveImage => '画像を保存できませんでした';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした';

  @override
  String get couldNotOpenFolder => 'フォルダを開けませんでした';

  @override
  String get imageNoLongerAvailable => 'この画像は利用できなくなりました';

  @override
  String get filesNoLongerAvailable => 'これらのファイルは利用できなくなりました';

  @override
  String get sendClipboard => 'クリップボードを送信';

  @override
  String get clipboardSent => 'クリップボードを送信しました';

  @override
  String get nothingNewToSend => '送信する新しい内容はありません';

  @override
  String get deviceName => 'デバイス名';

  @override
  String get deviceNameExplanation => '他のデバイスから見えるこの端末の名前です。';

  @override
  String get syncClipboard => 'クリップボードを同期';

  @override
  String get syncClipboardExplanation => 'ペアリング済みのデバイスと項目を送受信します。';

  @override
  String get readClipboardOnOpen => '起動時にクリップボードを読み取る';

  @override
  String get readClipboardOnOpenExplanation => 'アプリが前面に来たときにクリップボードを自動で確認します。';

  @override
  String get keepSyncingInBackground => 'バックグラウンドで同期を継続';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Plokee を最小化しても接続を維持します。常駐通知が表示されます。';

  @override
  String get couldNotStart => '起動できませんでした';

  @override
  String get trayOpenPlokee => 'Plokee を開く';

  @override
  String get trayCheckClipboardNow => '今すぐクリップボードを確認';

  @override
  String get trayRecentClipboard => '最近のクリップボード';

  @override
  String get traySyncClipboard => 'クリップボードを同期';

  @override
  String get trayQuit => '終了';

  @override
  String get traySyncIsOn => '同期オン';

  @override
  String get traySyncIsPaused => '同期を一時停止中';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $total 台中 $online 台がオンライン';
  }

  @override
  String get notificationChannelName => 'クリップボード同期';

  @override
  String get notificationChannelDescription => 'Plokee とペアリング済みデバイスの接続を維持します。';

  @override
  String get notificationTitle => 'Plokee は同期中です';

  @override
  String get notificationText => 'ペアリング済みのデバイスに接続中';
}
