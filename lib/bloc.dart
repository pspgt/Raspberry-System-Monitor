import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'models/uptime.dart';
import 'models/torrentstat.dart';
import 'models/teledart.dart';

class Bloc {
  BehaviorSubject<Uptime> _uptimeSubject;
  BehaviorSubject<InternetAddress> _indirizzoRaspberrySubject;
  BehaviorSubject<TorrentStats> _torrentSubject;
  BehaviorSubject _powerOffSubject;
  BehaviorSubject _rebootSubject;
  BehaviorSubject _torrentToggleSubject;
  BehaviorSubject _teledartSubject;
  BehaviorSubject _teledartToggleSubject;

  Sink<InternetAddress> _sinkAddress;
  Sink _sinkUptime;
  Sink _powerOffSink;
  Sink _rebootSink;
  Sink _torrentSink;
  Sink _torrentToggleSink;
  Sink _teledartToggleSink;
  Sink _teledartSink;

  Stream _uptimeStream;
  Stream _torrentStream;
  Stream _teledartStream;

  Stream get uptime => _uptimeStream;
  Stream get torrent => _torrentStream;
  Sink get powerOff => _powerOffSink;
  Sink get reboot => _rebootSink;
  Sink get torrentToggleSink => _torrentToggleSink;
  Stream get teledart => _teledartStream;
  Sink get teledartToggleSink => _teledartToggleSink;

  Bloc() {
    _uptimeSubject = new BehaviorSubject();
    _indirizzoRaspberrySubject = new BehaviorSubject();
    _powerOffSubject = new BehaviorSubject();
    _rebootSubject = new BehaviorSubject();
    _torrentSubject = new BehaviorSubject();
    _torrentToggleSubject = new BehaviorSubject();
    _teledartSubject = new BehaviorSubject();
    _teledartToggleSubject = new BehaviorSubject();
    _torrentToggleSink = _torrentToggleSubject.sink;
    _torrentStream = _torrentSubject.stream;
    _torrentSink = _torrentSubject.sink;
    _rebootSink = _rebootSubject.sink;
    _powerOffSink = _powerOffSubject.sink;
    _sinkAddress = _indirizzoRaspberrySubject.sink;
    _sinkUptime = _uptimeSubject.sink;
    _uptimeStream = _uptimeSubject.stream;
    _teledartToggleSink = _teledartToggleSubject.sink;
    _teledartStream = _teledartSubject.stream;
    _teledartSink = _teledartSubject.sink;
    _teledartToggleSubject.listen(_teledartToggleListener);
    _socketListen();
    _indirizzoRaspberrySubject.listen(_addressListener);
    _powerOffSubject.listen(_powerOffListener);
    _rebootSubject.listen(_rebootListener);
    _torrentToggleSubject.listen(_torrentToggleListener);
  }

  void _addressListener(address) async {
    dynamic res = await http.get('http://${address.address}:8888/uptime');
    _sinkUptime.add(Uptime.fromJson(res.body));
    res = await http.get('http://${address.address}:8888/torrentstatus');
    _torrentSink.add(TorrentStats.fromJson(res.body));
    res = await http.get('http://${address.address}:8888/teledart/1');
    _teledartSink.add(Teledart.fromJson(res.body));
  }

  void _powerOffListener(onValue) async {
    dynamic res = await http.get(
        'http://${_indirizzoRaspberrySubject.stream.value.address}:8888/poweroff');
    print(res.body);
  }

  void _rebootListener(onValue) async {
    dynamic res = await http.get(
        'http://${_indirizzoRaspberrySubject.stream.value.address}:8888/reboot');
    print(res.body);
  }

  void _torrentToggleListener(toggle) async {
    await http.post(
        'http://${_indirizzoRaspberrySubject.stream.value.address}:8888/torrentToggle/$toggle');
  }

  void _teledartToggleListener(toggle) async {
    await http.post(
        'http://${_indirizzoRaspberrySubject.stream.value.address}:8888/teledart/$toggle');
  }

  void close() {
    _uptimeSubject.close();
    _indirizzoRaspberrySubject.close();
    _powerOffSubject.close();
    _torrentSubject.close();
    _torrentSink.close();
    _torrentToggleSink.close();
    _powerOffSink.close();
    _rebootSubject.close();
    _rebootSink.close();
    _sinkAddress.close();
    _sinkUptime.close();
    _teledartSubject.close();
    _teledartToggleSink.close();
  }

  void _socketListen() {
    //InternetAddress address = InternetAddress('192.168.1.59');
    //_sinkAddress.add(address);
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889).then((socket) {
      socket.listen((e) {
        Datagram dg = socket.receive();
        _sinkAddress.add(dg?.address);
      });
    });
  }
}
