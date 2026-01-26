import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobx/mobx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/models/descartaveis_model.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:uuid/uuid.dart';

part 'descartaveis_store.g.dart';

class DescartaveisStore = _DescartaveisStoreBase with _$DescartaveisStore;

enum DescartaveisStatus { entregue, pendente }

abstract class _DescartaveisStoreBase with Store {
  static const String _descartaveisKey = 'descartaveis_cache';
  static const String _pendentesKey = 'descartaveis_pendentes';

  _DescartaveisStoreBase() {
    _init(); // ← carrega cache + Firestore
    _startConnectionListener(); // ← sincroniza quando voltar a internet
  }

  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  @observable
  ObservableList<Descartaveis> descartaveis = ObservableList<Descartaveis>();

  @observable
  DateTime selectedDate = DateTime.now();

  @observable
  ObservableList<Descartaveis> pendingDescartaveis =
      ObservableList<Descartaveis>();

  @observable
  bool isLoading = false;

  @computed
  List<Descartaveis> get DescartaveisForSelectedDate =>
      _filterDescartaveisByDate(selectedDate);

  Future<void> _init() async {
    await _loadPendingDescartaveisFromCache();
    await _loadDescartaveisFromCache();
    if (await _hasConnection()) {
      await _loadDescartaveisFromFirestore();
      await _syncPendingDescartaveis();
    }
  }

  @action
  List<Descartaveis> getDescartaveisForSelectedDay2(DateTime date) {
    return descartaveis
        .where((comanda) =>
            comanda.data.year == date.year &&
            comanda.data.month == date.month &&
            comanda.data.day == date.day)
        .toList();
  }

  @action
  Future<void> deleteComanda(String comandaId) async {
    descartaveis.removeWhere((c) => c.id == comandaId);
    pendingDescartaveis.removeWhere((c) => c.id == comandaId);

    await _saveDescartaveisToCache();
    await _savePendingDescartaveisToCache();

    if (await _hasConnection()) {
      await _deleteFromFirestore(comandaId);
    }
  }

  @action
  Future<void> addOrUpdateCard(Descartaveis comanda) async {
    final online = await _hasConnection();

    if (online) {
      try {
        await _sendToFirestore(comanda);
        comanda.status = DescartaveisStatus.entregue;
        _upsertDescartaveis(comanda);
        _removePendingComanda(comanda);
        await _saveDescartaveisToCache();
      } catch (_) {
        comanda.status = DescartaveisStatus.pendente;
        await _savePendingComanda(comanda);
      }
    } else {
      comanda.status = DescartaveisStatus.pendente;
      await _savePendingComanda(comanda);
    }
  }

  void _startConnectionListener() {
    _connectionChecker.onStatusChange.listen((InternetConnectionStatus status) {
      if (status == InternetConnectionStatus.connected) {
        syncPendingDescartaveis();
      }
    });
  }

  @action
  Future<void> syncPendingDescartaveis() async {
    if (!await _hasConnection()) return;

    final successfulSyncs = <String>[];

    for (final comanda in pendingDescartaveis.toList()) {
      try {
        await _sendToFirestore(comanda);
        comanda.status = DescartaveisStatus.entregue;
        _upsertDescartaveis(comanda);
        successfulSyncs.add(comanda.id);
      } catch (e) {
        print('Falha ao sincronizar comanda ${comanda.id}: $e');
      }
    }

    pendingDescartaveis.removeWhere((c) => successfulSyncs.contains(c.id));
    await _savePendingDescartaveisToCache();
    await _saveDescartaveisToCache();
  }

  @action
  void setSelectedDate(DateTime date) {
    selectedDate = date;
  }

  List<Descartaveis> getDescartaveisForSelectedDay(DateTime date) {
    return _filterDescartaveisByDate(date);
  }

  List<Descartaveis> getDescartaveisByPeriodo(DateTime date, String periodo) {
    final DescartaveisDay = _filterDescartaveisByDate(date);
    final filtered = DescartaveisDay.where(
        (c) => c.periodo?.toUpperCase() == periodo.toUpperCase()).toList();

    print(
        '🔍 ${filtered.length} Descartaveis encontradas no período "$periodo" na data $date');
    return filtered;
  }

  List<Descartaveis> _filterDescartaveisByDate(DateTime date) {
    final allDescartaveis = [...descartaveis, ...pendingDescartaveis];
    print('📅 Filtrando Descartaveis para a data: ${date.toIso8601String()}');

    return allDescartaveis.where((comanda) {
      final DateTime comandaDate;

      if (comanda.data is DateTime) {
        comandaDate = comanda.data as DateTime;
      } else if (comanda.data is Timestamp) {
        comandaDate = (comanda.data as Timestamp).toDate();
      } else {
        comandaDate =
            DateTime.tryParse(comanda.data.toString()) ?? DateTime.now();
      }

      final match = comandaDate.year == date.year &&
          comandaDate.month == date.month &&
          comandaDate.day == date.day;

      print(
          '📝 Comanda ${comanda.id} => ${comandaDate.toIso8601String()} => match: $match');

      return match;
    }).toList();
  }

  Future<void> _loadDescartaveisFromCache() async {
    final raw = _storage.read<List<dynamic>>(_descartaveisKey) ?? [];
    descartaveis.clear();
    descartaveis.addAll(
      raw.map((json) {
        final comanda = Descartaveis.fromJson(Map<String, dynamic>.from(json));
        comanda.status = DescartaveisStatus.entregue;
        return comanda;
      }),
    );
    print('💾 ${descartaveis.length} Descartaveis carregadas do cache');
  }

  Future<void> _loadPendingDescartaveisFromCache() async {
    final raw = _storage.read<List<dynamic>>(_pendentesKey) ?? [];
    pendingDescartaveis.clear();
    pendingDescartaveis.addAll(
      raw.map((json) {
        final comanda = Descartaveis.fromJson(Map<String, dynamic>.from(json));
        comanda.status = DescartaveisStatus.pendente;
        return comanda;
      }),
    );
    print(
        '💾 ${pendingDescartaveis.length} Descartaveis pendentes carregadas do cache');
  }

  Future<void> _saveDescartaveisToCache() async {
    await _storage.write(
        _descartaveisKey, descartaveis.map((c) => c.toJson()).toList());
  }

  Future<void> _savePendingDescartaveisToCache() async {
    await _storage.write(
        _pendentesKey, pendingDescartaveis.map((c) => c.toJson()).toList());
  }

  Future<void> _loadDescartaveisFromFirestore() async {
    if (!await _hasConnection()) return;

    final userId = _storage.read<String>('userId');
    if (userId == null) {
      print('❌ userId não encontrado no GetStorage');
      return;
    }

    print(userId);

    try {
      isLoading = true;
      print('🔄 Carregando Descartaveis do Firestore para userId: $userId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('descartaveis')
          .get();

      print('📦 ${snapshot.docs.length} documentos encontrados no Firestore');

      for (final doc in snapshot.docs) {
        final comanda = Descartaveis.fromDoc(doc);
        comanda.status = DescartaveisStatus.entregue;
        print(
            '✅ Comanda carregada: ID=${comanda.id}, período=${comanda.periodo}, data=${comanda.data}');
        _upsertDescartaveis(comanda);
      }

      await _saveDescartaveisToCache();
    } catch (e) {
      print('❌ Erro ao carregar Descartaveis do Firestore: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> _sendToFirestore(Descartaveis comanda) async {
    final userId = _storage.read<String>('userId');
    if (userId == null) throw Exception('Usuário não autenticado');

    comanda.userId = userId;
    print('⬆️ Enviando comanda para Firestore: ${comanda.toJson()}');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('descartaveis')
        .doc(comanda.id)
        .set(comanda.toJson());
  }

  Future<void> _deleteFromFirestore(String comandaId) async {
    try {
      final userId = _storage.read<String>('userId');
      if (userId == null) throw Exception('Usuário não autenticado');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('descartaveis')
          .doc(comandaId)
          .delete();
    } catch (e) {
      print('Erro ao deletar comanda do Firestore: $e');
    }
  }

  Future<void> _savePendingComanda(Descartaveis comanda) async {
    final existingIndex =
        pendingDescartaveis.indexWhere((c) => c.id == comanda.id);
    if (existingIndex == -1) {
      pendingDescartaveis.add(comanda);
    } else {
      pendingDescartaveis[existingIndex] = comanda;
    }

    await _savePendingDescartaveisToCache();
  }

  void _removePendingComanda(Descartaveis comanda) {
    pendingDescartaveis.removeWhere((c) => c.id == comanda.id);
  }

  void _upsertDescartaveis(Descartaveis d) {
    final index = descartaveis.indexWhere((c) => c.id == d.id); // lista correta
    if (index == -1) {
      descartaveis.add(d);
    } else {
      descartaveis[index] = d;
    }
  }

  Future<bool> _hasConnection() async {
    return await _connectionChecker.hasConnection;
  }

  @action
  Future<void> _syncPendingDescartaveis() async =>
      await syncPendingDescartaveis();
}
