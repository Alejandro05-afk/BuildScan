import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/building_project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final SupabaseClient _client;

  ProjectRepositoryImpl(this._client);

  @override
  Future<ProjectEntity> createProject(ProjectEntity project) async {
    final map = {
      'constructora_id': project.constructoraId,
      'nombre': project.nombre,
      'tipo_construccion': project.tipoConstruccion.name,
      'largo': project.largo,
      'ancho': project.ancho,
      'alto': project.alto,
      'area': project.area,
      'area_m2': project.area, // Compatibilidad con schema anterior/manual
      'porcentaje_desperdicio': project.porcentajeDesperdicio,
      'sugerencia': project.sugerencia,
      'ai_image_path': project.aiImagePath,
      'ai_image_source': project.aiImageSource,
    };

    final response = await _client.from('proyectos').insert(map).select().single();
    return ProjectModel.fromMap(response);
  }

  @override
  Future<List<ProjectEntity>> getMyProjects(String constructoraId) async {
    final response = await _client
        .from('proyectos')
        .select()
        .eq('constructora_id', constructoraId)
        .order('created_at', ascending: false);
    
    return response.map((e) => ProjectModel.fromMap(e)).toList();
  }

  @override
  Future<ProjectEntity?> getProjectById(String projectId) async {
    final response = await _client
        .from('proyectos')
        .select()
        .eq('id', projectId)
        .maybeSingle();
    
    if (response == null) return null;
    return ProjectModel.fromMap(response);
  }

  @override
  Future<ProjectEntity> updateProject(ProjectEntity project) async {
    final map = {
      if (project.id.isNotEmpty) 'id': project.id,
      'constructora_id': project.constructoraId,
      'nombre': project.nombre,
      'tipo_construccion': project.tipoConstruccion.name,
      'largo': project.largo,
      'ancho': project.ancho,
      'alto': project.alto,
      'area': project.area,
      'area_m2': project.area, // Compatibilidad con schema anterior/manual
      'porcentaje_desperdicio': project.porcentajeDesperdicio,
      'sugerencia': project.sugerencia,
      'ai_image_path': project.aiImagePath,
      'ai_image_source': project.aiImageSource,
    };

    final response = await _client
        .from('proyectos')
        .update(map)
        .eq('id', project.id)
        .select()
        .single();
    
    return ProjectModel.fromMap(response);
  }

  @override
  Future<void> updateProjectAiImage({
    required String projectId,
    required String storagePath,
    required String source,
  }) async {
    await _client.from('proyectos').update({
      'ai_image_path': storagePath,
      'ai_image_source': source,
    }).eq('id', projectId);
  }

  @override
  Future<BuildingProject> createCompleteBuildingProject(BuildingProject project) async {
    final map = project.toMap();
    final response = await _client.from('proyectos').insert(map).select().single();
    return BuildingProject.fromMap(response);
  }

  @override
  Future<BuildingProject> updateCompleteBuildingProject(BuildingProject project) async {
    final map = project.toMap();
    map.remove('id'); // Avoid updating ID
    
    final response = await _client
        .from('proyectos')
        .update(map)
        .eq('id', project.id as Object)
        .select()
        .single();
    
    return BuildingProject.fromMap(response);
  }

  @override
  Future<List<BuildingProject>> getProjectsByScope(String scope) async {
    final response = await _client
        .from('proyectos')
        .select()
        .eq('project_scope', scope)
        .order('created_at', ascending: false);
    
    return response.map((e) => BuildingProject.fromMap(e)).toList();
  }
}
