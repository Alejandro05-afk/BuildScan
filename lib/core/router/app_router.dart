import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/projects/presentation/screens/constructor_home_screen.dart';
import '../../features/projects/presentation/screens/project_form_screen.dart';
import '../../features/projects/presentation/screens/calculation_result_screen.dart';
import '../../features/projects/presentation/screens/proforma_preview_screen.dart';
import '../../features/ai/presentation/screens/construction_image_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/constructor/home',
    routes: [
      GoRoute(path: '/constructor/home', builder: (context, state) => const ConstructorHomeScreen()),
      GoRoute(path: '/projects/new', builder: (context, state) => const ProjectFormScreen()),
      GoRoute(path: '/projects/result', builder: (context, state) => const CalculationResultScreen()),
      GoRoute(path: '/projects/image', builder: (context, state) => const ConstructionImageScreen()),
      GoRoute(path: '/proforma', builder: (context, state) => const ProformaPreviewScreen()),
    ],
  );
});
