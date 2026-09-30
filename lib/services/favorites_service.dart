import 'package:flutter/foundation.dart';
import 'api_client.dart';

class FavoritesNotifier extends ChangeNotifier {
  static final FavoritesNotifier instance = FavoritesNotifier._internal();
  FavoritesNotifier._internal();

  final Set<String> _favoritedItemIds = <String>{};
  List<Map<String, dynamic>> _terms = [];
  List<Map<String, dynamic>> _trainings = [];
  List<Map<String, dynamic>> _resins = [];
  bool _isLoading = false;

  Set<String> get favoritedItemIds => Set.unmodifiable(_favoritedItemIds);
  Set<String> get state => Set.unmodifiable(_favoritedItemIds);
  List<Map<String, dynamic>> get terms => List.unmodifiable(_terms);
  List<Map<String, dynamic>> get trainings => List.unmodifiable(_trainings);
  List<Map<String, dynamic>> get resins => List.unmodifiable(_resins);
  bool get isLoading => _isLoading;

  bool isFavorited(String id) => _favoritedItemIds.contains(id);
  bool isFavorite(String id) => _favoritedItemIds.contains(id);

  bool mockNetworkSuccessInTest = false;

  void setFavoritesForTest({
    required Set<String> ids,
    List<Map<String, dynamic>> terms = const [],
    List<Map<String, dynamic>> trainings = const [],
    List<Map<String, dynamic>> resins = const [],
    bool mockNetwork = true,
  }) {
    _favoritedItemIds.clear();
    _favoritedItemIds.addAll(ids);
    _terms = List.from(terms);
    _trainings = List.from(trainings);
    _resins = List.from(resins);
    mockNetworkSuccessInTest = mockNetwork;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.getFavorites();
      _favoritedItemIds.clear();

      final items = data['items'] as List? ?? [];
      for (final it in items) {
        if (it is Map && it['entityId'] != null) {
          _favoritedItemIds.add(it['entityId'].toString());
        }
      }

      final termsList = List<Map<String, dynamic>>.from(
        (data['terms'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      final trainingsList = List<Map<String, dynamic>>.from(
        (data['trainings'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      final resinsList = List<Map<String, dynamic>>.from(
        (data['resins'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      );

      _terms = termsList;
      _trainings = trainingsList;
      _resins = resinsList;

      for (final t in termsList) {
        if (t['id'] != null) _favoritedItemIds.add(t['id'].toString());
      }
      for (final tr in trainingsList) {
        if (tr['id'] != null) _favoritedItemIds.add(tr['id'].toString());
      }
      for (final r in resinsList) {
        if (r['id'] != null) _favoritedItemIds.add(r['id'].toString());
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavoriteEntity(String id, String entityType) async {
    return toggleFavorite(entityType: entityType, entityId: id);
  }

  Future<bool> toggleFavorite({
    required String entityType,
    required String entityId,
    Map<String, dynamic>? itemData,
  }) async {
    final wasFavorited = _favoritedItemIds.contains(entityId);

    // Optimistic update
    if (wasFavorited) {
      _favoritedItemIds.remove(entityId);
      _terms.removeWhere((t) => t['id']?.toString() == entityId);
      _trainings.removeWhere((t) => t['id']?.toString() == entityId);
      _resins.removeWhere((r) => r['id']?.toString() == entityId);
    } else {
      _favoritedItemIds.add(entityId);
      if (itemData != null) {
        if (entityType == 'TERM') _terms.add(itemData);
        if (entityType == 'TRAINING') _trainings.add(itemData);
        if (entityType == 'RESIN') _resins.add(itemData);
      }
    }
    notifyListeners();

    if (mockNetworkSuccessInTest) {
      return !wasFavorited;
    }

    try {
      final res = await ApiClient.instance.toggleFavorite(
        entityType: entityType,
        entityId: entityId,
      );
      final isFav = res['favorite'] == true || res['isFavorited'] == true;

      // Sync with server response
      if (isFav) {
        _favoritedItemIds.add(entityId);
      } else {
        _favoritedItemIds.remove(entityId);
        _terms.removeWhere((t) => t['id']?.toString() == entityId);
        _trainings.removeWhere((t) => t['id']?.toString() == entityId);
        _resins.removeWhere((r) => r['id']?.toString() == entityId);
      }
      notifyListeners();
      return isFav;
    } catch (e) {
      // Revert optimistic update on failure
      if (wasFavorited) {
        _favoritedItemIds.add(entityId);
      } else {
        _favoritedItemIds.remove(entityId);
      }
      notifyListeners();
      debugPrint('Error toggling favorite: $e');
      return wasFavorited;
    }
  }
}

typedef FavoritesService = FavoritesNotifier;
typedef FavoritesProvider = FavoritesNotifier;
