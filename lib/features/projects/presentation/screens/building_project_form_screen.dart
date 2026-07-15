import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/clay_container_alias.dart';
import '../../domain/entities/building_project.dart';
import '../../../../core/widgets/clay_input_field.dart';
import '../../../../core/widgets/clay_submit_button.dart';
import '../providers/building_project_form_provider.dart';

class BuildingProjectFormScreen extends ConsumerWidget {
  const BuildingProjectFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(buildingProjectFormProvider, (previous, next) {
      if (previous?.isCalculating == true && next.isCalculating == false && next.calculation != null) {
        context.pushReplacement('/projects/building/result');
      }
    });

    final state = ref.watch(buildingProjectFormProvider);
    final notifier = ref.read(buildingProjectFormProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3), // Soft clay background
      appBar: AppBar(
        title: const Text('Nueva Edificación Completa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepper(state.currentStep),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildStepContent(context, state, notifier),
              ),
            ),
            _buildBottomControls(state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final step = index + 1;
          final isActive = step <= currentStep;
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blueAccent : const Color(0xFFE0E5EC),
              boxShadow: isActive
                  ? []
                  : [
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 10,
                      ),
                      const BoxShadow(
                        color: Color(0xFFA3B1C6),
                        offset: Offset(4, 4),
                        blurRadius: 10,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, state, BuildingProjectFormNotifier notifier) {
    if (state.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
        ),
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    switch (state.currentStep) {
      case 1:
        return _buildGeneralDataStep(state, notifier);
      case 2:
        return _buildSuggestionStep(state, notifier);
      case 3:
        return _buildSpacesStep(state, notifier);
      case 4:
        return _buildSystemAndFinishesStep(state, notifier);
      case 5:
        return _buildDistributionStep(state, notifier);
      case 6:
        return _buildSummaryStep(state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildGeneralDataStep(state, BuildingProjectFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos Generales',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ClayInputField(
          labelText: 'Nombre del Proyecto',
          initialValue: state.form.name,
          onChanged: (val) {
            notifier.updateForm(state.form.copyWith(name: val));
          },
        ),
        const SizedBox(height: 20),
        ClayInputField(
          labelText: 'Área Total (m²)',
          initialValue: state.form.totalArea > 0 ? state.form.totalArea.toString() : '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (val) {
            notifier.updateForm(state.form.copyWith(totalArea: double.tryParse(val) ?? 0));
          },
        ),
        const SizedBox(height: 20),
        ClayInputField(
          labelText: 'Número de Plantas',
          initialValue: state.form.floors.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            notifier.updateForm(state.form.copyWith(floors: int.tryParse(val) ?? 1));
          },
        ),
      ],
    );
  }

  Widget _buildSuggestionStep(state, BuildingProjectFormNotifier notifier) {
    if (state.suggestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona una Sugerencia',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...state.suggestions.asMap().entries.map((entry) {
          final idx = entry.key;
          final sug = entry.value;
          final isSelected = state.selectedSuggestion == sug;
          return GestureDetector(
            onTap: () => notifier.selectSuggestion(idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : const Color(0xFFF0F0F3),
                border: isSelected ? Border.all(color: Colors.blueAccent, width: 2) : null,
                boxShadow: isSelected
                    ? []
                    : const [
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
                  Text(sug.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(sug.description),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSpacesStep(state, BuildingProjectFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text(
          'Espacios',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ClayInputField(
          labelText: 'Dormitorios',
          initialValue: state.form.bedrooms.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            notifier.updateForm(state.form.copyWith(bedrooms: int.tryParse(val) ?? 0));
          },
        ),
        const SizedBox(height: 20),
        ClayInputField(
          labelText: 'Baños',
          initialValue: state.form.bathrooms.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            notifier.updateForm(state.form.copyWith(bathrooms: int.tryParse(val) ?? 0));
          },
        ),
      ],
    );
  }

  Widget _buildSystemAndFinishesStep(state, BuildingProjectFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sistema y Acabados',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text('Sistema Constructivo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(elevation: 1, margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Container(
          color: const Color(0xFFF0F0F3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ConstructionSystem>(
                isExpanded: true,
                value: state.form.constructionSystem,
                items: ConstructionSystem.values.map((sys) {
                  return DropdownMenuItem(
                    value: sys,
                    child: Text(_translateSystem(sys)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    notifier.updateForm(state.form.copyWith(constructionSystem: val));
                  }
                },
              ),
            ),
          ),
        )),
        const SizedBox(height: 24),
        const Text('Nivel de Acabados', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(elevation: 1, margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Container(
          color: const Color(0xFFF0F0F3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<FinishLevel>(
                isExpanded: true,
                value: state.form.finishLevel,
                items: FinishLevel.values.map((lvl) {
                  return DropdownMenuItem(
                    value: lvl,
                    child: Text(_translateFinish(lvl)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    notifier.updateForm(state.form.copyWith(finishLevel: val));
                  }
                },
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDistributionStep(state, BuildingProjectFormNotifier notifier) {
    if (state.distribution == null) return const Text('Sin distribución estimada.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text(
          'Distribución Estimada',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...state.distribution!.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.spaceName, style: const TextStyle(fontSize: 16)),
                Text('${item.estimatedArea.toStringAsFixed(1)} m² (${item.percentage.toStringAsFixed(0)}%)', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSummaryStep(state) {
    final form = state.form;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del Proyecto',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        const SizedBox(height: 16),
        Card(elevation: 1, margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Container(
          color: const Color(0xFFF0F0F3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Nombre:', form.name),
                _buildSummaryRow('Tipo Sugerido:', form.buildingType.toString().split('.').last.toUpperCase()),
                _buildSummaryRow('Área Total:', '${form.totalArea} m²'),
                _buildSummaryRow('Plantas:', '${form.floors}'),
                _buildSummaryRow('Sistema:', _translateSystem(form.constructionSystem)),
                _buildSummaryRow('Acabados:', _translateFinish(form.finishLevel)),
                _buildSummaryRow('Dormitorios:', '${form.bedrooms}'),
                _buildSummaryRow('Baños:', '${form.bathrooms}'),
              ],
            ),
          ),
        )),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Revisa que los datos sean correctos antes de proceder al cálculo de materiales. ¡Se generará un presupuesto detallado!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomControls(state, BuildingProjectFormNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F3),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (state.currentStep > 1)
            TextButton(
              onPressed: () => notifier.previousStep(),
              child: const Text('Atrás', style: TextStyle(fontSize: 16)),
            )
          else
            const SizedBox(width: 60), // Spacer
            
          if (state.currentStep == 1)
            Expanded(
              child: ClaySubmitButton(
                text: state.isCalculating ? 'Procesando...' : 'Obtener Sugerencias',
                isLoading: state.isCalculating,
                onPressed: () {
                   if (!state.isCalculating) notifier.generateSuggestions();
                },
              ),
            )
          else if (state.currentStep == 6)
            Expanded(
              child: ClaySubmitButton(
                text: state.isCalculating ? 'Calculando...' : 'Calcular Materiales',
                isLoading: state.isCalculating,
                onPressed: () {
                   if (!state.isCalculating) notifier.calculateMaterials();
                },
              ),
            )
          else if (state.currentStep > 1 && state.currentStep < 6)
            Expanded(
              child: ClaySubmitButton(
                text: 'Siguiente',
                onPressed: () => notifier.nextStep(),
              ),
            ),
        ],
      ),
    );
  }

  String _translateSystem(ConstructionSystem sys) {
    switch (sys) {
      case ConstructionSystem.reinforcedConcrete: return 'Hormigón Armado';
      case ConstructionSystem.steelStructure: return 'Estructura Metálica';
      case ConstructionSystem.mixed: return 'Mixto (Hormigón/Metal)';
      case ConstructionSystem.masonry: return 'Mampostería Portante';
      default: return sys.toString().split('.').last;
    }
  }

  String _translateFinish(FinishLevel lvl) {
    switch (lvl) {
      case FinishLevel.basic: return 'Básico';
      case FinishLevel.standard: return 'Estándar';
      case FinishLevel.premium: return 'Premium (Lujo)';
      default: return lvl.toString().split('.').last;
    }
  }
}
