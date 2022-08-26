import 'package:hydrated_bloc/hydrated_bloc.dart';

class MockStorage implements Storage {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String key) async {}

  @override
  dynamic read(String key) {
    return null;
  }

  @override
  Future<void> write(String key, value) async {}
}
