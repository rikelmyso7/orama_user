import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobx/mobx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/models/comanda_model.dart';
import 'package:intl/intl.dart';

part 'user_comanda_store.g.dart';

enum ComandaStatus {
  pendente,
  entregue,
}

class UserComandaStore = _UserComandaStoreBase with _$UserComandaStore;

abstract class _UserComandaStoreBase with Store {
  static const String _comandasKey = 'comandas_cache';
  static const String _pendentesKey = 'comandas_pendentes';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance();

  final Set<String> _loadedKeys = {};

  _UserComandaStoreBase() {
    _init();
    _startConnectionListener();
  }

  @observable
  ObservableList<Comanda2> comandas = ObservableList<Comanda2>();

  @observable
  ObservableList<Comanda2> pendingComandas = ObservableList<Comanda2>();

  @observable
  DateTime selectedDate = DateTime.now();

  @observable
  bool isLoading = false;

  @computed
  List<Comanda2> get comandasForSelectedDate =>
      _filterComandasByDate(selectedDate);

  Future<void> _init() async {
    await _loadPendingComandasFromCache();
    await _loadComandasFromCache();
    if (await _hasConnection()) {
      await _loadComandasForDate(DateTime.now());
      await _syncPendingComandas();
    }
  }

  @action
  List<Comanda2> getComandasForSelectedDay2(DateTime date) {
    return comandas
        .where((comanda) =>
            comanda.data.year == date.year &&
            comanda.data.month == date.month &&
            comanda.data.day == date.day)
        .toList();
  }

  @action
  Future<void> deleteComanda(String comandaId) async {
    comandas.removeWhere((c) => c.id == comandaId);
    pendingComandas.removeWhere((c) => c.id == comandaId);

    await _saveComandasToCache();
    await _savePendingComandasToCache();

    if (await _hasConnection()) {
      await _deleteFromFirestore(comandaId);
    }
  }

  @action
  Future<void> addOrUpdateCard(Comanda2 comanda) async {
    final online = await _hasConnection();

    if (online) {
      try {
        await _sendToFirestore(comanda);
        comanda.status = ComandaStatus.entregue;
        _upsertComanda(comanda);
        _removePendingComanda(comanda);
        await _saveComandasToCache();
      } catch (_) {
        comanda.status = ComandaStatus.pendente;
        await _savePendingComanda(comanda);
      }
    } else {
      comanda.status = ComandaStatus.pendente;
      await _savePendingComanda(comanda);
    }
  }

  void _startConnectionListener() {
    _connectionChecker.onStatusChange.listen((InternetConnectionStatus status) {
      if (status == InternetConnectionStatus.connected) {
        syncPendingComandas();
      }
    });
  }

  @action
  Future<void> syncPendingComandas() async {
    if (!await _hasConnection()) return;

    final successfulSyncs = <String>[];

    for (final comanda in pendingComandas.toList()) {
      try {
        await _sendToFirestore(comanda);
        comanda.status = ComandaStatus.entregue;
        _upsertComanda(comanda);
        successfulSyncs.add(comanda.id);
      } catch (e) {
        print('Falha ao sincronizar comanda ${comanda.id}: $e');
      }
    }

    pendingComandas.removeWhere((c) => successfulSyncs.contains(c.id));
    await _savePendingComandasToCache();
    await _saveComandasToCache();
  }

  @action
  Future<void> setSelectedDate(DateTime date) async {
    selectedDate = date;
    final key = _key(date);
    if (!_loadedKeys.contains(key) && await _hasConnection()) {
      await _loadComandasForDate(date);
    }
  }

  Future<void> _loadComandasForDate(DateTime date) async {
    final key = _key(date);
    _loadedKeys.add(key);

    final userId = _storage.read<String>('userId');
    if (userId == null) return;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    try {
      isLoading = true;
      final snap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('comandas')
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('data', isLessThan: Timestamp.fromDate(end))
          .get();

      for (final d in snap.docs) {
        final c = Comanda2.fromDoc(d)..status = ComandaStatus.entregue;
        _upsertComanda(c);
      }
      await _saveComandasToCache();
    } catch (e) {
      print('❌ Erro ao carregar $key: $e');
    } finally {
      isLoading = false;
    }
  }

  // ---------- 5. helper ----------
  String _key(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  List<Comanda2> getComandasForSelectedDay(DateTime date) {
    return _filterComandasByDate(date);
  }

  List<Comanda2> getComandasByPeriodo(DateTime date, String periodo) {
    final comandasDay = _filterComandasByDate(date);
    final filtered = comandasDay
        .where((c) => c.periodo?.toUpperCase() == periodo.toUpperCase())
        .toList();

    print(
        '🔍 ${filtered.length} comandas encontradas no período "$periodo" na data $date');
    return filtered;
  }

  List<Comanda2> _filterComandasByDate(DateTime date) {
    final allComandas = [...comandas, ...pendingComandas];
    print('📅 Filtrando comandas para a data: ${date.toIso8601String()}');

    return allComandas.where((comanda) {
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

  Future<void> _loadComandasFromCache() async {
    final raw = _storage.read<List<dynamic>>(_comandasKey) ?? [];
    comandas.clear();
    comandas.addAll(
      raw.map((json) {
        final comanda = Comanda2.fromJson(Map<String, dynamic>.from(json));
        comanda.status = ComandaStatus.entregue;
        return comanda;
      }),
    );
    print('💾 ${comandas.length} comandas carregadas do cache');
  }

  Future<void> _loadPendingComandasFromCache() async {
    final raw = _storage.read<List<dynamic>>(_pendentesKey) ?? [];
    pendingComandas.clear();
    pendingComandas.addAll(
      raw.map((json) {
        final comanda = Comanda2.fromJson(Map<String, dynamic>.from(json));
        comanda.status = ComandaStatus.pendente;
        return comanda;
      }),
    );
    print(
        '💾 ${pendingComandas.length} comandas pendentes carregadas do cache');
  }

  Future<void> _saveComandasToCache() async {
    await _storage.write(
        _comandasKey, comandas.map((c) => c.toJson()).toList());
  }

  Future<void> _savePendingComandasToCache() async {
    await _storage.write(
        _pendentesKey, pendingComandas.map((c) => c.toJson()).toList());
  }

  Future<void> _loadComandasFromFirestore() async {
    if (!await _hasConnection()) return;

    final userId = _storage.read<String>('userId');
    if (userId == null) {
      print('❌ userId não encontrado no GetStorage');
      return;
    }

    print(userId);

    try {
      isLoading = true;
      print('🔄 Carregando comandas do Firestore para userId: $userId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('comandas')
          .get();

      print('📦 ${snapshot.docs.length} documentos encontrados no Firestore');

      for (final doc in snapshot.docs) {
        final comanda = Comanda2.fromDoc(doc);
        comanda.status = ComandaStatus.entregue;
        print(
            '✅ Comanda carregada: ID=${comanda.id}, período=${comanda.periodo}, data=${comanda.data}');
        _upsertComanda(comanda);
      }

      await _saveComandasToCache();
    } catch (e) {
      print('❌ Erro ao carregar comandas do Firestore: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> _sendToFirestore(Comanda2 comanda) async {
    final userId = _storage.read<String>('userId');
    if (userId == null) throw Exception('Usuário não autenticado');

    comanda.userId = userId;
    print('⬆️ Enviando comanda para Firestore: ${comanda.toJson()}');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('comandas')
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
          .collection('comandas')
          .doc(comandaId)
          .delete();
    } catch (e) {
      print('Erro ao deletar comanda do Firestore: $e');
    }
  }

  Future<void> _savePendingComanda(Comanda2 comanda) async {
    final existingIndex = pendingComandas.indexWhere((c) => c.id == comanda.id);
    if (existingIndex == -1) {
      pendingComandas.add(comanda);
    } else {
      pendingComandas[existingIndex] = comanda;
    }

    await _savePendingComandasToCache();
  }

  void _removePendingComanda(Comanda2 comanda) {
    pendingComandas.removeWhere((c) => c.id == comanda.id);
  }

  void _upsertComanda(Comanda2 comanda) {
    final index = comandas.indexWhere((c) => c.id == comanda.id);
    if (index == -1) {
      comandas.add(comanda);
    } else {
      comandas[index] = comanda;
    }
  }

  Future<bool> _hasConnection() async {
    return await _connectionChecker.hasConnection;
  }

  @action
  Future<void> _syncPendingComandas() async => await syncPendingComandas();
}
