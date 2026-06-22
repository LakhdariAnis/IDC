import 'package:flutter/foundation.dart';
import 'storage/clipboard_store.dart';

class ClipboardHistory extends ChangeNotifier {
  static final ClipboardHistory instance = ClipboardHistory._();
  ClipboardHistory._();

  List<ClipboardEntry> _entries = [];
  List<ClipboardEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    _entries = await ClipboardStore.getAll();
    notifyListeners();
  }

  Future<void> add(String text, ClipDirection direction) async {
    final entry = ClipboardEntry(
      text: text,
      direction: direction,
      timestamp: DateTime.now(),
    );
    await ClipboardStore.insert(entry);
    _entries.insert(0, entry);
    if (_entries.length > 100) _entries = _entries.sublist(0, 100);
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await ClipboardStore.delete(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> clear() async {
    await ClipboardStore.clear();
    _entries = [];
    notifyListeners();
  }
}
