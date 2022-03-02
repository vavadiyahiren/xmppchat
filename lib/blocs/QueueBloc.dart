import 'package:chatsample/db/api/MessageApi.dart';
import 'package:chatsample/db/api/QueueApi.dart';
import 'package:chatsample/enums/connectivity_status.dart';
import 'package:chatsample/models/Message.dart';
import 'package:chatsample/models/Queue.dart';
import 'package:chatsample/services/connectivity_service.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class QueueBloc {
  final _queueListSink = PublishSubject<List<Queue>>();

  Observable<List<Queue>> get queueListObserver => _queueListSink.stream;

  static final _queueLink = PublishSubject<Queue>();

  Observable<Queue> get queueObserver => _queueLink.stream;

  static bool _isNetworkConnected = false;

  static ConnectivityStatus _connectivityStatus = ConnectivityStatus.Offline;

  static List<Queue> _queueList;

  static QueueBloc _instance = QueueBloc.internal();

  factory QueueBloc() => _instance;

  static QueueBloc get instance => _instance;

  QueueBloc.internal() {
    queueListObserver.listen((queueList) => _processQueue(queueList));
    queueObserver.listen((data) => _processSingleQueue(data));
    XmppService.instance.xmppStatusObserver
        .listen((status) => _listenXmppStatus(status));
    XmppService.instance.getXmppStatus();
    ConnectivityService.instance.connectivityObserver
        .listen(_connectivityListner);
    ConnectivityService.instance.checkCurrentConnectivity();
  }

  getQueue() async {
    _queueList = await QueueApi.getQueue();
    _queueListSink.add(_queueList);
  }

  addQueue(Queue queue) async {
    await QueueApi.saveQueue(queue);
    _queueLink.add(queue);
  }

  deleteQueue(Queue queue) async {
    await QueueApi.deleteQueue(queue);
    _queueList.remove(queue);
  }

  deleteQueueWithMsgId(String messageId) async {
    await QueueApi.deleteQueueWithMsgId(messageId);
  }

  updateQueue(Queue queue) async {
    await QueueApi.updateQueue(queue);
  }

  destroy() {
    _queueListSink.close();
    _queueLink.close();
  }

  _listenXmppStatus(String xmppStatus) {
    Utils.write("xmppStatus :  $xmppStatus ");
    if (xmppStatus == Utils.authenticated) {
      _isNetworkConnected = true;
      getQueue();
    } else {
      _isNetworkConnected = false;
    }
  }

  _processQueue(List<Queue> queueList) {
    if (!_isNetworkConnected) {
      return;
    }

    for (int i = 0; i < queueList.length; i++) {
      _processSingleQueue(queueList[i]);
    }
  }

  _processSingleQueue(Queue queue) async {
    Utils.write(
        "_processSingleQueue :  $queue , connectivity : ${_connectivityStatus.index}");
    if (!_isNetworkConnected) {
      return;
    } else if (_connectivityStatus.index < ConnectivityStatus.Offline.index) {
      XmppService.instance.connect();
    }

    Message message = await MessageApi.getMessage(queue.messageId);
    if (message != null) {
      XmppService.instance.sendMessage(message);
    }
  }

  static _connectivityListner(ConnectivityStatus connectivityStatus) {
    _connectivityStatus = connectivityStatus;
  }
}
