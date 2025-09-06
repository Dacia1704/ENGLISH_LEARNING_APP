import 'package:english_learning_app/app/presentation/screens/home_screen.dart';
import 'package:english_learning_app/app/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Cấu hình GoRouter
final GoRouter router = GoRouter(
  initialLocation: '/login', // Route ban đầu khi mở app
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    // GoRoute(
    //   path: '/add',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const AddScreen();
    //   },
    // ),
  ],
);
