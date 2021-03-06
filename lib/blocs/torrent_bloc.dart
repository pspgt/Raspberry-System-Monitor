import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:raspberry_system_monitor/models/torrentstat.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc.dart';

class TorrentBloc {
  BehaviorSubject<TorrentStats> _torrentSubject;
  BehaviorSubject<bool> _torrentToggleSubject;

  Sink _torrentSink;
  Sink _torrentToggleSink;

  Stream _torrentStream;
  Stream _address;

  String _addressString;

  Stream get stream => _torrentStream;

  Sink get sink => _torrentToggleSink;

  TorrentBloc(Stream address) {
    _torrentSubject = BehaviorSubject.seeded(TorrentStats((t) => t
      ..running = false
      ..torrentStatus = ''));
    _torrentToggleSubject = new BehaviorSubject();
    _torrentToggleSink = _torrentToggleSubject.sink;
    _torrentStream = _torrentSubject.stream;
    _torrentSink = _torrentSubject.sink;
    _torrentToggleSubject.listen(_torrentToggleListener);
    _address = address;
    _address.listen((address) {
      if (address != null) _update(address.address);
    });
  }

  void _update(String address) async {
    _addressString = address;
    try {
      final res = await http.get('http://$_addressString:8888/torrentstatus/1');
      _torrentSink.add(TorrentStats.fromJson(res.body));
    }catch(e){
      Bloc.instance.scaffold.showSnackBar(
          SnackBar(content: Text('${e.toString()}'),));
    }
  }

  void _torrentToggleListener(toggle) async {
    try{
      await http.post('http://$_addressString:8888/torrentstatus/$toggle');
    }catch(e){
      Bloc.instance.scaffold.showSnackBar(
          SnackBar(content: Text('${e.toString()}'),));
    }
  }

  void close() {
    _torrentSubject.close();
    _torrentSink.close();
    _torrentToggleSink.close();
  }
}
