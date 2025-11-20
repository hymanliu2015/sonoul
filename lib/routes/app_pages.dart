import 'package:flutter/material.dart';
import 'package:sonoul/features/dash/dash_binding.dart';
import 'package:sonoul/features/dash/dash_page.dart';
import 'package:sonoul/features/auth/login_page.dart';
import 'package:sonoul/features/auth/register_page.dart';
import 'package:sonoul/features/guide/guide_page.dart';
import 'package:sonoul/features/singer/singer_page.dart';
import 'package:sonoul/features/song/create_single_page.dart';
import 'package:sonoul/features/album/album_page.dart';
import 'package:sonoul/features/song/song_detail_page.dart';
import 'package:sonoul/features/member/member_page.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:sonoul/utils/sp_util.dart';

class AppPages{

  static const initial = AppRoutes.dash;

  static final routes = [
    GetPage(
        name: AppRoutes.dash,
        page: () => DashPage(),
        binding: DashBinding(),
        middlewares: [RouteAuthMiddleware()],
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
    GetPage(
      name: AppRoutes.member,
      page: () => MemberPage(),
    ),
  ];
}

class RouteAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final hasSeenGuide = SpUtil.getBool('has_seen_guide', defValue: false) ?? false;
    if (!hasSeenGuide) {
      return const RouteSettings(name: AppRoutes.guide);
    }
    return null;
  }
}