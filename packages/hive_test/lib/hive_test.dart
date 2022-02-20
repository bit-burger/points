import 'package:hive/hive.dart';

/// A fake hive box for testing
class FakeHiveBox<E> extends Box<E> {
  Map data = Map<dynamic, E>();

  @override
  Future<int> add(E value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<Iterable<int>> addAll(Iterable<E> values) {
    // TODO: implement addAll
    throw UnimplementedError();
  }

  @override
  Future<int> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> compact() {
    // TODO: implement compact
    throw UnimplementedError();
  }

  @override
  bool containsKey(key) {
    // TODO: implement containsKey
    throw UnimplementedError();
  }

  @override
  Future<void> delete(key) async {
    data.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable keys) {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAt(int index) {
    // TODO: implement deleteAt
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFromDisk() {
    // TODO: implement deleteFromDisk
    throw UnimplementedError();
  }

  @override
  E? get(key, {E? defaultValue}) {
    return data[key];
  }

  @override
  E? getAt(int index) {
    // TODO: implement getAt
    throw UnimplementedError();
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  // TODO: implement isOpen
  bool get isOpen => throw UnimplementedError();

  @override
  keyAt(int index) {
    // TODO: implement keyAt
    throw UnimplementedError();
  }

  @override
  // TODO: implement keys
  Iterable get keys => throw UnimplementedError();

  @override
  // TODO: implement lazy
  bool get lazy => throw UnimplementedError();

  @override
  // TODO: implement length
  int get length => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement path
  String? get path => throw UnimplementedError();

  @override
  Future<void> put(key, E value) async {
    data[key] = value;
  }

  @override
  Future<void> putAll(Map<dynamic, E> entries) {
    // TODO: implement putAll
    throw UnimplementedError();
  }

  @override
  Future<void> putAt(int index, E value) {
    // TODO: implement putAt
    throw UnimplementedError();
  }

  @override
  Map<dynamic, E> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  @override
  // TODO: implement values
  Iterable<E> get values => throw UnimplementedError();

  @override
  Iterable<E> valuesBetween({startKey, endKey}) {
    // TODO: implement valuesBetween
    throw UnimplementedError();
  }

  @override
  Stream<BoxEvent> watch({key}) {
    // TODO: implement watch
    throw UnimplementedError();
  }

  @override
  Future<void> flush() {
    // TODO: implement flush
    throw UnimplementedError();
  }
}
