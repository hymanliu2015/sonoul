import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/config/config.dart';

class AnalyticsService extends GetxService {
  late Amplitude _amplitude;

  Future<AnalyticsService> init() async {
    // Create and initailize the instance
    _amplitude = Amplitude(Configuration(
      apiKey: AppConfig.amplitudeKey,
    ));

    // Wait until the SDK is initialized
    await _amplitude.isBuilt;

    // Track an event
    trackEvent('APP_INIT', {'打开app': 'init'});

    return this;
  }

  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    _amplitude.track(BaseEvent(
      eventName,
      eventProperties: properties,
    ));
    // Send events to the server
    _amplitude.flush();
  }

  /// 登录
  void trackLogin({String method = 'email'}) {
    trackEvent('LOGIN', {'method': method});
  }

  /// 注册
  void trackRegister({String method = 'email'}) {
    trackEvent('REGISTER', {'method': method});
  }

  /// 创建歌手
  void trackCreateSinger(String singerName) {
    trackEvent('CREATE_SINGER', {'singer_name': singerName});
  }

  /// 创建歌曲
  void trackCreateSong(String songTitle, {String? style}) {
    trackEvent('CREATE_SONG', {
      'song_title': songTitle,
      if (style != null) 'style': style,
    });
  }

  /// 订阅
  void trackSubscribe(String productId, {String? price}) {
    trackEvent('SUBSCRIBE', {
      'product_id': productId,
      if (price != null) 'price': price,
    });
  }
}
