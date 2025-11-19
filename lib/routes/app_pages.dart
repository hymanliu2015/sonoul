import 'package:sonoul/features/dash/dash_binding.dart';
import 'package:sonoul/features/dash/dash_page.dart';
import 'package:sonoul/features/auth/login_page.dart';
import 'package:sonoul/features/auth/register_page.dart';
import 'package:sonoul/features/singer/singer_creation_page.dart';
import 'package:sonoul/features/song/create_single_page.dart';
import 'package:sonoul/features/album/album_page.dart';
import 'package:sonoul/features/song/song_detail_page.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages{

  static const initial = AppRoutes.dash;

  static final routes = [
    GetPage(
        name: AppRoutes.dash,
        page: () => DashPage(),
      binding: DashBinding(),
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
      name: AppRoutes.createSinger,
      page: () => SingerCreationPage(),
    ),
    GetPage(
      name: AppRoutes.createSingle,
      page: () => CreateSinglePage(),
    ),
    GetPage(
      name: AppRoutes.album,
      page: () => AlbumPage(),
    ),
    GetPage(
      name: AppRoutes.songDetail,
      page: () => SongDetailPage(),
    ),
  ];
}