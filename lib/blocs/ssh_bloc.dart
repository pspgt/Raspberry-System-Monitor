import 'package:raspberry_system_monitor/models/ssh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class SSHBloc {
  BehaviorSubject<SSH> _subject;
  BehaviorSubject<bool> _toggleSubject;

  Stream _stream;
  String _addressString;

  Sink _tSink;
  Sink _sshSink;

  Stream _address;

  Stream get stream => _stream;
  Sink get sink => _tSink;

  SSHBloc(Stream address) {
    _subject = new BehaviorSubject.seeded(SSH((ssh) => ssh..running = false));
    _toggleSubject = new BehaviorSubject();
    _tSink = _toggleSubject.sink;
    _stream = _subject.stream;
    _sshSink = _subject.sink;
    _toggleSubject.listen(_sambaToggleListener);
    _address = address;
    _address.listen((address) => _update(address.address));
  }

  void _sambaToggleListener(toggle) async {
    await http.post('http://$_addressString:8888/ssh/$toggle');
  }

  void _update(String address) async {
    _addressString = address;
    final res = await http.get('http://$_addressString:8888/ssh/1');
    _sshSink.add(SSH.fromJson(res.body));
  }

  void close() {
    _tSink.close();
    _sshSink.close();
    _subject.close();
    _toggleSubject.close();
  }
}