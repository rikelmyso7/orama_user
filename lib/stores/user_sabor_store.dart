// stores/user_sabor_store.dart
import 'package:mobx/mobx.dart';
import '../models/sabor_model.dart';

part 'user_sabor_store.g.dart';

class UserSaborStore = _UserSaborStore with _$UserSaborStore;

abstract class _UserSaborStore with Store {
  @observable
  ObservableList<Sabor> sabores = ObservableList<Sabor>();

  @action
  void addSabor(Sabor sabor) {
    sabores.add(sabor);
  }

  @action
  void removeSabor(Sabor sabor) {
    sabores.remove(sabor);
  }

  @action
  void updateSabor(int index, Sabor sabor) {
    sabores[index] = sabor;
  }

  // TabViewState
  @observable
  int currentIndex = 0;

  @observable
  ObservableMap<String, ObservableMap<String, Map<String, int>>>
      saboresSelecionados = ObservableMap();

  @observable
  ObservableMap<String, ObservableMap<String, bool>> expansionState =
      ObservableMap();

  @action
  void setCurrentIndex(int index) {
    currentIndex = index;
  }

  @action
  void updateSaborTabView(
      String categoria, String sabor, Map<String, int> quantidade) {
    if (!saboresSelecionados.containsKey(categoria)) {
      saboresSelecionados[categoria] = ObservableMap();
    }
    saboresSelecionados[categoria]![sabor] = quantidade;
  }

  @action
  void setExpansionState(String categoria, String sabor, bool isExpanded) {
    if (!expansionState.containsKey(categoria)) {
      expansionState[categoria] = ObservableMap();
    }
    expansionState[categoria]![sabor] = isExpanded;
  }

  @action
  void resetExpansionState() {
    expansionState.clear();
  }

  @action
  void resetSaborTabView() {
    saboresSelecionados.clear();
  }
}