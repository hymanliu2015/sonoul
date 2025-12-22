
import 'package:sonoul/features/dash/dash_binding.dart';
import 'package:sonoul/features/dash/dash_page.dart';
import 'package:sonoul/features/auth/login_page.dart';
import 'package:sonoul/features/auth/register_page.dart';
import 'package:sonoul/features/guide/guide_page.dart';
import 'package:sonoul/features/singer/singer_page.dart';
import 'package:sonoul/features/song/create_song_page.dart';
import 'package:sonoul/features/album/album_page.dart';
import 'package:sonoul/features/song/song_detail_page.dart';
import 'package:sonoul/features/member/member_page.dart';
import 'package:sonoul/features/settings/settings_page.dart';
import 'package:sonoul/features/profile/profile_page.dart';
import 'package:sonoul/middleware/auth_middleware.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages{

  static const initial = AppRoutes.dash;

  static final routes = [
    GetPage(
        name: AppRoutes.dash,
        page: () => DashPage(),
        binding: DashBinding(),
        middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.guide,
      page: () => GuidePage(),
    ),
    GetPage(
      name: AppRoutes.singer,
      page: () => SingerPage(),
    ),
    GetPage(
      name: AppRoutes.createSingle,
      page: () => CreateSongPage(),
    ),
    GetPage(
      name: AppRoutes.album,
      page: () => AlbumPage(),
    ),
    GetPage(
      name: AppRoutes.songDetail,
      page: () => SongDetailPage(),
    ),
    GetPage(
      name: AppRoutes.member,
      page: () => MemberPage(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingsPage(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
