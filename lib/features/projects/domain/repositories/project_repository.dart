import '../entities/project_entity.dart';
import '../entities/building_project.dart';

abstract class ProjectRepository {
  Future<ProjectEntity> createProject(ProjectEntity project);
  Future<List<ProjectEntity>> getMyProjects(String constructoraId);
  Future<ProjectEntity?> getProjectById(String projectId);
  Future<ProjectEntity> updateProject(ProjectEntity project);
  Future<void> deleteProject(String projectId);
  Future<void> updateProjectAiImage({
    required String projectId,
    required String storagePath,
    required String source,
  });

  // New methods for Complete Building Projects
  Future<BuildingProject> createCompleteBuildingProject(BuildingProject project);
  Future<BuildingProject> updateCompleteBuildingProject(BuildingProject project);
  Future<List<BuildingProject>> getProjectsByScope(String scope);
}
