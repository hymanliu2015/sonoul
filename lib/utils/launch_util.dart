
import 'package:url_launcher/url_launcher.dart';

class LaunchUtil{

  void launchURL(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  void launchPhoneURL(String urlStr) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: urlStr,
    );
    if (!await launchUrl(phoneLaunchUri)) throw 'Could not launch $urlStr';
  }

  void launchSmsURL(String urlStr,String body) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: urlStr,
      queryParameters: <String, String>{
        'body': Uri.encodeComponent(body),
      },
    );
    if (!await launchUrl(smsLaunchUri)) throw 'Could not launch $urlStr';
  }

  void launchEmailURL(String urlStr,String body) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: urlStr,
      queryParameters: <String, String>{
        'body': Uri.encodeComponent(body),
      },
    );
    if (!await launchUrl(emailLaunchUri)) throw 'Could not launch $urlStr';
  }

}