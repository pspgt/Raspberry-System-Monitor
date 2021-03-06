import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'bloc.dart';

class PoweroffBloc {
  BehaviorSubject _powerOffSubject;
  Sink _powerOffSink;
  Stream _address;

  Sink get sink => _powerOffSink;

  String _addressString;

  PoweroffBloc(Stream address) {
    _powerOffSubject = new BehaviorSubject();
    _powerOffSink = _powerOffSubject.sink;
    _powerOffSubject.listen(_powerOffListener);
    _address = address;
    _address.listen((address) {
      if (address != null) _update(address.address);
    });
  }

  void _powerOffListener(onValue) async {
    try {
      final res = await http.get('http://$_addressString:8888/poweroff');
      Bloc.instance.scaffold.showSnackBar(
          SnackBar(content: Text(res.body.toString())));
    } catch (e) {
      Bloc.instance.scaffold.showSnackBar(
          SnackBar(content: Text('${e.toString()}'),));
    }
  }

  void _update(String address) {
    _addressString = address;
  }

  void close() {
    _powerOffSubject.close();
    _powerOffSink.close();
  }
}
