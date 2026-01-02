// Archivo: lib/features/estimator/presentation/providers/estimator_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/features/estimator/data/repositories/estimator_repository.dart';
import 'package:apex/features/estimator/domain/models/estimator_item_model.dart';

part 'estimator_provider.g.dart';

// Estado que guarda la selección actual
class EstimatorState {
  final ServiceType selectedType;
  final Set<String> selectedItemIds;
  final double totalEstimate;

  const EstimatorState({
    required this.selectedType,
    required this.selectedItemIds,
    required this.totalEstimate,
  });

  EstimatorState copyWith({
    ServiceType? selectedType,
    Set<String>? selectedItemIds,
    double? totalEstimate,
  }) {
    return EstimatorState(
      selectedType: selectedType ?? this.selectedType,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      totalEstimate: totalEstimate ?? this.totalEstimate,
    );
  }
}

@riverpod
class EstimatorNotifier extends _$EstimatorNotifier {
  @override
  EstimatorState build() {
    // CORRECCIÓN: Leemos el repositorio para obtener el ID real del item Core
    final repo = ref.read(estimatorRepositoryProvider);
    final webItems = repo.getItems(ServiceType.web);
    final coreItem = webItems.firstWhere((i) => i.isCore);

    // Inicializamos con el item Core real seleccionado
    return EstimatorState(
      selectedType: ServiceType.web,
      selectedItemIds: {coreItem.id}, 
      totalEstimate: coreItem.price,
    );
  }

  void setType(ServiceType type) {
    final repo = ref.read(estimatorRepositoryProvider);
    final items = repo.getItems(type);
    
    // Al cambiar de tipo, reseteamos seleccionando solo el item obligatorio (Core)
    final coreItem = items.firstWhere((i) => i.isCore);
    
    state = EstimatorState(
      selectedType: type,
      selectedItemIds: {coreItem.id},
      totalEstimate: coreItem.price,
    );
  }

  void toggleItem(EstimatorItem item) {
    if (item.isCore) return; // No se puede deseleccionar la base

    final currentIds = Set<String>.from(state.selectedItemIds);
    double newTotal = state.totalEstimate;

    if (currentIds.contains(item.id)) {
      currentIds.remove(item.id);
      newTotal -= item.price;
    } else {
      currentIds.add(item.id);
      newTotal += item.price;
    }

    state = state.copyWith(
      selectedItemIds: currentIds,
      totalEstimate: newTotal,
    );
  }
}