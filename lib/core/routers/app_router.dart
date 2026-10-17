import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product_entity.dart';
import 'package:go_router/go_router.dart';

import '../../features/details/screens/product_details_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

final appRouting = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const SplashScreen();
      },
    ), // GoRoute
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final product = state.extra as ProductEntity;
        return ProductDetailsScreen(product: product);
      },
    ), // GoRoute
  ],
); // GoRouter
