import 'dart:async';
import 'package:flutter/services.dart';

typedef OrientationWriter = Future<void> Function(List<DeviceOrientation>);

/// Serializes native requests. A released/older route cannot rotate a newer one.
class AppOrientation {
  AppOrientation(this._write);
  static final instance = AppOrientation(SystemChrome.setPreferredOrientations);
  final OrientationWriter _write;
  Future<void> _tail = Future.value();
  int _revision = 0, _ownerSequence = 0;
  int? _owner;

  OrientationLease acquire() {
    final id = ++_ownerSequence;
    _owner = id;
    return OrientationLease._(this, id);
  }

  Future<bool> portrait() => _request(false);

  Future<bool> _request(bool landscape) {
    final revision = ++_revision;
    final result = Completer<bool>();
    _tail = _tail.then((_) async {
      if (revision != _revision) {
        result.complete(false);
        return;
      }
      try {
        await _write(
          landscape
              ? [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
              : [DeviceOrientation.portraitUp],
        );
        result.complete(revision == _revision);
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  Future<bool> _set(int owner, bool landscape) =>
      _owner == owner ? _request(landscape) : Future.value(false);

  Future<bool> _release(int owner) {
    if (_owner != owner) return Future.value(false);
    _owner = null;
    return _request(false);
  }
}

class OrientationLease {
  OrientationLease._(this._manager, this._id);
  final AppOrientation _manager;
  final int _id;
  bool _closed = false;
  Future<bool> setLandscape(bool landscape) =>
      _closed ? Future.value(false) : _manager._set(_id, landscape);
  Future<bool> close() {
    if (_closed) return Future.value(false);
    _closed = true;
    return _manager._release(_id);
  }
}
