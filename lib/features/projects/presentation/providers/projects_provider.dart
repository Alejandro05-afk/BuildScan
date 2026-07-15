import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/project_entity.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return ProjectRepositoryImpl(client);
});

final myProjectsProvider = FutureProvider<List<ProjectEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value?.session?.user;
  if (user == null) return [];
  
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getMyProjects(user.id);
});

class SaveProjectNotifier extends AsyncNotifier<ProjectEntity?> {
  @override
  Future<ProjectEntity?> build() async => null;

  Future<ProjectEntity?> saveProject(ProjectEntity project) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(projectRepositoryProvider);
      final saved = await repo.createProject(project);
      state = AsyncData(saved);
      return saved;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final saveProjectProvider = AsyncNotifierProvider<SaveProjectNotifier, ProjectEntity?>(SaveProjectNotifier.new);
