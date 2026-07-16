import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/building_project_form_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/clay_submit_button.dart';
import '../providers/projects_provider.dart';
import 'package:go_router/go_router.dart';

class BuildingCalculationResultScreen extends ConsumerWidget {
  const BuildingCalculationResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buildingProjectFormProvider);
    final calc = state.calculation;

    if (calc == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF00897B), // Teal app bar from design
          title: const Text('Resultados'),
        ),
        body: const Center(child: Text('No hay cálculos disponibles.')),
      );
    }

    // Group materials by category
    final Map<String, List<dynamic>> groupedMaterials = {};
    for (var mat in calc.materials) {
      if (!groupedMaterials.containsKey(mat.category)) {
        groupedMaterials[mat.category] = [];
      }
      groupedMaterials[mat.category]!.add(mat);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3), // Off-white/clay
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B), // Teal app bar from design
        title: const Text('Estimación Referencial', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(state.form.name, state.form.totalArea, state.form.buildingType.toString().split('.').last),
            const SizedBox(height: 16),
            ...groupedMaterials.entries.map((entry) {
              return _buildCategoryPanel(entry.key, entry.value);
            }).toList(),
            const SizedBox(height: 16),
            _buildWarningsCard(calc.warnings),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ClaySubmitButton(
                    text: 'Guardar Proyecto',
                    onPressed: () => _guardarYNavegarAProforma(context, ref, state),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String name, double area, String type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
          const SizedBox(height: 8),
          Text('Tipo: $type', style: const TextStyle(fontSize: 16)),
          Text('Área: $area m²', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCategoryPanel(String title, List<dynamic> materials) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))), // Orange text
        children: materials.map((mat) {
          return ListTile(
            title: Text(mat.materialName),
            subtitle: Text(mat.criteria),
            trailing: Text(
              '${mat.quantity.toStringAsFixed(1)} ${mat.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00897B)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWarningsCard(List<String> warnings) {
    if (warnings.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Advertencias', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map((w) => Text('• $w', style: const TextStyle(color: Colors.black87))).toList(),
        ],
      ),
    );
  }

  Future<void> _guardarYNavegarAProforma(BuildContext context, WidgetRef ref, dynamic state) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardando proyecto...')),
      );
      final user = ref.read(authStateProvider).value?.session?.user;
      if (user == null) throw Exception("Usuario no autenticado");

      // 1. Guardar Proyecto en DB
      final projectToSave = state.form.copyWith(constructoraId: user.id);
      final repo = ref.read(projectRepositoryProvider);
      final savedProject = await repo.createCompleteBuildingProject(projectToSave);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto guardado correctamente'), backgroundColor: Colors.green),
        );
        // Navegar a la pantalla de previsualización de la proforma
        context.push('/proforma_building', extra: savedProject);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
