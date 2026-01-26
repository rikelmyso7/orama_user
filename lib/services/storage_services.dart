import 'package:get_storage/get_storage.dart';
import 'package:orama_user/utils/checklist_item_models.dart';

class StorageService {
  final GetStorage box = GetStorage();

  void saveChecklist(List<ChecklistItemModel> checklist) {
    final data = checklist.map((item) => item.toJson()).toList();
    box.write('checklist', data);
  }

  List<ChecklistItemModel> loadChecklist() {
    final data = box.read<List>('checklist');
    if (data != null) {
      return data
          .map((item) =>
              ChecklistItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  void savePix(String pix) {
    box.write('pix', pix);
  }

  String? loadPix() {
    return box.read<String>('pix');
  }

  void saveVenda(double venda) {
    box.write('venda', venda);
  }

  double? loadVenda() {
    return box.read<double>('venda');
  }
}
