import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/ferreterias/presentation/screens/ferreteria_home_screen.dart';
import '../../features/ferreterias/presentation/screens/ferreteria_profile_form_screen.dart';
import '../../features/cotizaciones/presentation/screens/responder_cotizacion_screen.dart';
import '../../features/cotizaciones/presentation/screens/quotes_list_screen.dart';

import '../../features/mapas/presentation/mapa_ferreterias_screen.dart';
import '../../features/projects/presentation/screens/constructor_home_screen.dart';
import '../../features/projects/presentation/screens/project_form_screen.dart';
import '../../features/projects/presentation/screens/calculation_result_screen.dart';
import '../../features/projects/presentation/screens/proforma_preview_screen.dart';
import '../../features/projects/presentation/screens/my_projects_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/ai/presentation/screens/construction_image_screen.dart';
import '../../features/projects/domain/entities/project_entity.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (authState.isLoading || profileAsync.isLoading) return null;

      final isAuth = authState.value?.session != null;
      final isLoginRoute = state.uri.path == '/login' || state.uri.path == '/register';

      if (!isAuth) {
        return isLoginRoute ? null : '/login';
      }

      final profile = profileAsync.value;
      if (profile == null) return null;

      final isConstructorRoute = state.uri.path.startsWith('/constructor');
      final isFerreteriaRoute = state.uri.path.startsWith('/ferreteria') || state.uri.path == '/responder-cotizacion';
      
      // Bloquear manual navigation
      if (profile.isConstructora && isFerreteriaRoute) {
        return '/constructor/home';
      }
      
      if (profile.isFerreteria && isConstructorRoute) {
        // Podríamos redirigir a /ferreteria/profile si no han completado el perfil,
        // pero por ahora redirigimos al home.
        return '/ferreteria/home';
      }

      if (isLoginRoute) {
        if (profile.isConstructora) return '/constructor/home';
        if (profile.isFerreteria) return '/ferreteria/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/constructor/home', builder: (context, state) => const ConstructorHomeScreen()),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapaFerreteriasScreen(),
      ),
      GoRoute(
        path: '/map/:proformaId',
        builder: (context, state) => MapaFerreteriasScreen(proformaId: state.pathParameters['proformaId']),
      ),
      GoRoute(
        path: '/ferreteria/home',
        builder: (context, state) => const FerreteriaHomeScreen(),
      ),
      GoRoute(
        path: '/ferreteria/profile',
        builder: (context, state) => const FerreteriaProfileFormScreen(),
      ),
      GoRoute(
        path: '/responder-cotizacion',
        builder: (context, state) {
          final solicitud = state.extra as Map<String, dynamic>;
          return ResponderCotizacionScreen(solicitud: solicitud);
        },
      ),
      GoRoute(
        path: '/quotes',
        builder: (context, state) => const QuotesListScreen(),
      ),
      GoRoute(path: '/projects/new', builder: (context, state) => const ProjectFormScreen()),
      GoRoute(path: '/projects/result', builder: (context, state) => const CalculationResultScreen()),
      GoRoute(path: '/projects/image', builder: (context, state) => const ConstructionImageScreen()),
      GoRoute(path: '/projects/my_projects', builder: (context, state) => const MyProjectsScreen()),
      GoRoute(
        path: '/projects/detail/:id',
        builder: (context, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/proforma',
        builder: (context, state) {
          final project = state.extra as ProjectEntity?;
          return ProformaPreviewScreen(savedProject: project);
        },
      ),
    ],
  );
});
