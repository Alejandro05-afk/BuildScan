import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<ProjectEntity> createProject(ProjectEntity project);
  Future<List<ProjectEntity>> getMyProjects(String constructoraId);
  Future<ProjectEntity?> getProjectById(String projectId);
  Future<ProjectEntity> updateProject(ProjectEntity project);
  Future<void> updateProjectAiImage({
    required String projectId,
    required String storagePath,
    required String source,
  });
}
