// bk_tree.dart
class BKTree {
  _BKNode? _root;
  final int Function(int, int) _distance;

  BKTree(this._distance);

  void add(int hash, String id) {
    if (_root == null) {
      _root = _BKNode(hash, id);
      return;
    }
    _root!.add(hash, id, _distance);
  }

  /// Tìm tất cả node có distance <= threshold
  List<({String id, int distance})> search(
    int hash,
    int threshold,
  ) {
    final results = <({String id, int distance})>[];
    _root?.search(hash, threshold, _distance, results);
    return results;
  }
}

class _BKNode {
  final int hash;
  final String id;
  final Map<int, _BKNode> children = {};

  _BKNode(this.hash, this.id);

  void add(
    int newHash,
    String newId,
    int Function(int, int) distance,
  ) {
    final d = distance(hash, newHash);
    if (d == 0) return; // exact duplicate — bỏ qua, xử lý riêng
    if (children.containsKey(d)) {
      children[d]!.add(newHash, newId, distance);
    } else {
      children[d] = _BKNode(newHash, newId);
    }
  }

  void search(
    int queryHash,
    int threshold,
    int Function(int, int) distance,
    List<({String id, int distance})> results,
  ) {
    final d = distance(hash, queryHash);
    if (d <= threshold) {
      results.add((id: id, distance: d));
    }
    // BK-Tree pruning: chỉ duyệt branch nằm trong [d-threshold, d+threshold]
    for (int k = (d - threshold).clamp(0, 999);
        k <= d + threshold;
        k++) {
      children[k]?.search(queryHash, threshold, distance, results);
    }
  }
}