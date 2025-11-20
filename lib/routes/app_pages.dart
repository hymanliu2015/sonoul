import 'package:flutter/material.dart';
import 'package:sonoul/features/dash/dash_binding.dart';
import 'package:sonoul/features/dash/dash_page.dart';
import 'package:sonoul/features/auth/login_page.dart';
import 'package:sonoul/features/auth/register_page.dart';
import 'package:sonoul/features/guide/guide_page.dart';
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
    final hasCreatedSinger = SpUtil.getBool('has_created_singer', defValue: false) ?? false;
    // If user hasn't created a singer, redirect to creation page
    // But we must allow access to login/register if we had those, but here the requirement is "First install -> Create Singer".
    // Assuming user is logged in? The prompt says "First install app, enter, guide page... create virtual singer".
    // If we have login flow, we might need to check login status too.
    // But let's stick to the specific request: "First time install... create singer... then dash".
    
    if (!hasCreatedSinger) {
      return const RouteSettings(name: AppRoutes.guide);
    }
    return null;
  }
}