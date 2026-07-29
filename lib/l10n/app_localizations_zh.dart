// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => '已连接';

  @override
  String get statusConnecting => '连接中…';

  @override
  String get statusIdle => '空闲';

  @override
  String get statusOffline => '离线';

  @override
  String get statusPaired => '已配对';

  @override
  String connectedDevices(int count) {
    return '$count 台已连接';
  }

  @override
  String get sync => '同步';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get devices => '设备';

  @override
  String get history => '历史';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String get done => '完成';

  @override
  String get pair => '配对';

  @override
  String get unpair => '取消配对';

  @override
  String get decline => '拒绝';

  @override
  String get save => '保存';

  @override
  String get share => '分享';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get lookingForDevices => '正在查找设备…';

  @override
  String get openPlokeeOnAnotherDevice => '请在同一网络的另一台设备上\n打开 Plokee。';

  @override
  String newDeviceAt(String address) {
    return '新设备 · $address';
  }

  @override
  String pairingWith(String name) {
    return '正在与“$name”配对';
  }

  @override
  String get pairingRequest => '配对请求';

  @override
  String get pairingFailed => '配对失败';

  @override
  String get confirmOnOtherDevice => '请在另一台设备上确认。两台设备应显示相同的代码：';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name”（$platform）请求配对。';
  }

  @override
  String nowConnected(String name) {
    return '“$name”已连接。你的剪贴板将自动同步。';
  }

  @override
  String get makeSureSameCode => '请确认两台设备显示相同的代码：';

  @override
  String get requestDeclinedOrTimedOut => '请求被拒绝或已超时。';

  @override
  String get addByIp => '找不到设备？通过 IP 添加';

  @override
  String get addByIpTitle => '通过 IP 添加设备';

  @override
  String get addByIpExplanation => '某些网络会让设备之间互相不可见。输入另一台设备的 IP 地址即可直接配对。';

  @override
  String get ipAddress => 'IP 地址';

  @override
  String get add => '添加';

  @override
  String get searching => '正在搜索…';

  @override
  String thisDeviceAddress(String address) {
    return '本设备：$address';
  }

  @override
  String noDeviceAtIp(String address) {
    return '在 $address 未找到 Plokee 设备';
  }

  @override
  String get nothingCopiedYet => '还没有复制任何内容';

  @override
  String get copiesShowUpHere => '复制的内容会显示在这里，并同步到\n你已配对的设备。';

  @override
  String get clearHistory => '清除历史';

  @override
  String get clearHistoryQuestion => '清除历史记录？';

  @override
  String get clearHistoryExplanation => '这将删除此设备上所有已保存的内容。已配对的设备会保留各自的历史记录。';

  @override
  String fromDeviceAtTime(String name, String time) {
    return '来自 $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return '图片（$size）';
  }

  @override
  String get openInBrowser => '在浏览器中打开';

  @override
  String get writeEmail => '写邮件';

  @override
  String get saveImage => '保存图片';

  @override
  String get showInFolder => '在文件夹中显示';

  @override
  String get imageSaved => '图片已保存';

  @override
  String get couldNotSaveImage => '无法保存图片';

  @override
  String get couldNotOpenLink => '无法打开链接';

  @override
  String get couldNotOpenFolder => '无法打开文件夹';

  @override
  String get imageNoLongerAvailable => '该图片已不可用';

  @override
  String get filesNoLongerAvailable => '这些文件已不可用';

  @override
  String get sendClipboard => '发送剪贴板';

  @override
  String get clipboardSent => '剪贴板已发送';

  @override
  String get nothingNewToSend => '没有新内容可发送';

  @override
  String get deviceName => '设备名称';

  @override
  String get deviceNameExplanation => '其他设备看到的名称。';

  @override
  String get syncClipboard => '同步剪贴板';

  @override
  String get syncClipboardExplanation => '与已配对的设备互相收发内容。';

  @override
  String get readClipboardOnOpen => '打开时读取剪贴板';

  @override
  String get readClipboardOnOpenExplanation => '当应用回到前台时自动检查剪贴板。';

  @override
  String get keepSyncingInBackground => '后台持续同步';

  @override
  String get keepSyncingInBackgroundExplanation => 'Plokee 最小化时保持连接。会显示常驻通知。';

  @override
  String get couldNotStart => '无法启动';

  @override
  String get trayOpenPlokee => '打开 Plokee';

  @override
  String get trayCheckClipboardNow => '立即检查剪贴板';

  @override
  String get trayRecentClipboard => '最近的剪贴板';

  @override
  String get traySyncClipboard => '同步剪贴板';

  @override
  String get trayQuit => '退出';

  @override
  String get traySyncIsOn => '同步已开启';

  @override
  String get traySyncIsPaused => '同步已暂停';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $total 台设备中 $online 台在线';
  }

  @override
  String get notificationChannelName => '剪贴板同步';

  @override
  String get notificationChannelDescription => '保持 Plokee 与已配对设备的连接。';

  @override
  String get notificationTitle => 'Plokee 正在同步';

  @override
  String get notificationText => '已连接到你配对的设备';

  @override
  String notificationConnected(int count, int total) {
    return '已连接 $total 台设备中的 $count 台';
  }

  @override
  String get notificationPaused => '同步已暂停';

  @override
  String get notificationPause => '暂停';

  @override
  String get notificationResume => '继续';

  @override
  String get syncRules => '同步规则';

  @override
  String syncRulesFor(String name) {
    return '本设备与“$name”同步的内容';
  }

  @override
  String get ruleSendTo => '向其发送';

  @override
  String get ruleSendToExplanation => '把在这里复制的内容发送到该设备。';

  @override
  String get ruleReceiveFrom => '从其接收';

  @override
  String get ruleReceiveFromExplanation => '把在该设备复制的内容应用到此剪贴板。';

  @override
  String get ruleKinds => '类型';

  @override
  String get ruleText => '文本';

  @override
  String get ruleImages => '图片';

  @override
  String get ruleFiles => '文件';

  @override
  String get ruleSummaryNothing => '全部关闭';

  @override
  String get ruleSummaryReceiveOnly => '仅接收';

  @override
  String get ruleSummarySendOnly => '仅发送';

  @override
  String get ruleSummaryCustom => '自定义';

  @override
  String get transfers => '传输';

  @override
  String transferSendingTo(String name) {
    return '正在发送到 $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return '正在接收来自 $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get transferText => '文本';

  @override
  String get transferImage => '图片';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => '已連線';

  @override
  String get statusConnecting => '連線中…';

  @override
  String get statusIdle => '閒置';

  @override
  String get statusOffline => '離線';

  @override
  String get statusPaired => '已配對';

  @override
  String connectedDevices(int count) {
    return '$count 台已連線';
  }

  @override
  String get sync => '同步';

  @override
  String get settings => '設定';

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get devices => '裝置';

  @override
  String get history => '歷史';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String get done => '完成';

  @override
  String get pair => '配對';

  @override
  String get unpair => '取消配對';

  @override
  String get decline => '拒絕';

  @override
  String get save => '儲存';

  @override
  String get share => '分享';

  @override
  String get copy => '複製';

  @override
  String get copied => '已複製';

  @override
  String get lookingForDevices => '正在尋找裝置…';

  @override
  String get openPlokeeOnAnotherDevice => '請在同一網路的另一台裝置上\n開啟 Plokee。';

  @override
  String newDeviceAt(String address) {
    return '新裝置 · $address';
  }

  @override
  String pairingWith(String name) {
    return '正在與「$name」配對';
  }

  @override
  String get pairingRequest => '配對要求';

  @override
  String get pairingFailed => '配對失敗';

  @override
  String get confirmOnOtherDevice => '請在另一台裝置上確認。兩台裝置應顯示相同的代碼：';

  @override
  String wantsToPair(String name, String platform) {
    return '「$name」（$platform）要求配對。';
  }

  @override
  String nowConnected(String name) {
    return '「$name」已連線。你的剪貼簿將自動同步。';
  }

  @override
  String get makeSureSameCode => '請確認兩台裝置顯示相同的代碼：';

  @override
  String get requestDeclinedOrTimedOut => '要求已被拒絕或逾時。';

  @override
  String get addByIp => '找不到裝置？透過 IP 新增';

  @override
  String get addByIpTitle => '透過 IP 新增裝置';

  @override
  String get addByIpExplanation => '某些網路會讓裝置之間互相看不見。輸入另一台裝置的 IP 位址即可直接配對。';

  @override
  String get ipAddress => 'IP 位址';

  @override
  String get add => '新增';

  @override
  String get searching => '正在搜尋…';

  @override
  String thisDeviceAddress(String address) {
    return '本裝置：$address';
  }

  @override
  String noDeviceAtIp(String address) {
    return '在 $address 找不到 Plokee 裝置';
  }

  @override
  String get nothingCopiedYet => '尚未複製任何內容';

  @override
  String get copiesShowUpHere => '複製的內容會顯示在這裡，並同步至\n你已配對的裝置。';

  @override
  String get clearHistory => '清除歷史';

  @override
  String get clearHistoryQuestion => '清除歷史記錄？';

  @override
  String get clearHistoryExplanation => '這會刪除此裝置上所有已儲存的內容。已配對的裝置會保留各自的歷史記錄。';

  @override
  String fromDeviceAtTime(String name, String time) {
    return '來自 $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return '圖片（$size）';
  }

  @override
  String get openInBrowser => '在瀏覽器中開啟';

  @override
  String get writeEmail => '撰寫郵件';

  @override
  String get saveImage => '儲存圖片';

  @override
  String get showInFolder => '在資料夾中顯示';

  @override
  String get imageSaved => '圖片已儲存';

  @override
  String get couldNotSaveImage => '無法儲存圖片';

  @override
  String get couldNotOpenLink => '無法開啟連結';

  @override
  String get couldNotOpenFolder => '無法開啟資料夾';

  @override
  String get imageNoLongerAvailable => '此圖片已無法使用';

  @override
  String get filesNoLongerAvailable => '這些檔案已無法使用';

  @override
  String get sendClipboard => '傳送剪貼簿';

  @override
  String get clipboardSent => '剪貼簿已傳送';

  @override
  String get nothingNewToSend => '沒有新內容可傳送';

  @override
  String get deviceName => '裝置名稱';

  @override
  String get deviceNameExplanation => '其他裝置看到的名稱。';

  @override
  String get syncClipboard => '同步剪貼簿';

  @override
  String get syncClipboardExplanation => '與已配對的裝置互相收發內容。';

  @override
  String get readClipboardOnOpen => '開啟時讀取剪貼簿';

  @override
  String get readClipboardOnOpenExplanation => '當應用程式回到前景時自動檢查剪貼簿。';

  @override
  String get keepSyncingInBackground => '背景持續同步';

  @override
  String get keepSyncingInBackgroundExplanation => 'Plokee 最小化時保持連線。會顯示常駐通知。';

  @override
  String get couldNotStart => '無法啟動';

  @override
  String get trayOpenPlokee => '開啟 Plokee';

  @override
  String get trayCheckClipboardNow => '立即檢查剪貼簿';

  @override
  String get trayRecentClipboard => '最近的剪貼簿';

  @override
  String get traySyncClipboard => '同步剪貼簿';

  @override
  String get trayQuit => '結束';

  @override
  String get traySyncIsOn => '同步已開啟';

  @override
  String get traySyncIsPaused => '同步已暫停';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $total 台裝置中 $online 台上線';
  }

  @override
  String get notificationChannelName => '剪貼簿同步';

  @override
  String get notificationChannelDescription => '保持 Plokee 與已配對裝置的連線。';

  @override
  String get notificationTitle => 'Plokee 正在同步';

  @override
  String get notificationText => '已連線至你配對的裝置';

  @override
  String notificationConnected(int count, int total) {
    return '已連線 $total 台裝置中的 $count 台';
  }

  @override
  String get notificationPaused => '同步已暫停';

  @override
  String get notificationPause => '暫停';

  @override
  String get notificationResume => '繼續';

  @override
  String get syncRules => '同步規則';

  @override
  String syncRulesFor(String name) {
    return '本裝置與「$name」同步的內容';
  }

  @override
  String get ruleSendTo => '向其傳送';

  @override
  String get ruleSendToExplanation => '把在這裡複製的內容傳送到該裝置。';

  @override
  String get ruleReceiveFrom => '從其接收';

  @override
  String get ruleReceiveFromExplanation => '把在該裝置複製的內容套用到此剪貼簿。';

  @override
  String get ruleKinds => '類型';

  @override
  String get ruleText => '文字';

  @override
  String get ruleImages => '圖片';

  @override
  String get ruleFiles => '檔案';

  @override
  String get ruleSummaryNothing => '全部關閉';

  @override
  String get ruleSummaryReceiveOnly => '僅接收';

  @override
  String get ruleSummarySendOnly => '僅傳送';

  @override
  String get ruleSummaryCustom => '自訂';

  @override
  String get transfers => '傳輸';

  @override
  String transferSendingTo(String name) {
    return '正在傳送至 $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return '正在接收來自 $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get transferText => '文字';

  @override
  String get transferImage => '圖片';
}
