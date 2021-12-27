import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:core';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_demo/src/call_sample/signaling.dart';
import 'package:flutter_webrtc_demo/src/call_sample_new/bloc/call_sample_v2_bloc.dart';
import 'package:flutter_webrtc_demo/src/utils/call_manager.dart';

class CallSampleV2 extends StatefulWidget {
  static String tag = 'call_sample';
  final String host;
  CallSampleV2({required this.host});

  @override
  _CallSampleV2State createState() => _CallSampleV2State();
}

class _CallSampleV2State extends State<CallSampleV2> {

  /// A discovery and negotiation process used to establish a connection
  /// connect self to server
  Signaling? _signaling;

  /// list of peers displayed on the screens
  List<dynamic> _peers = [];


  /// List of peers selected for room call
  List<dynamic> _groupedPeers = [];

  /// List of peer id to which self has connection
  List<String> _peerIdsInvited = [];


  late CallSampleV2Bloc _callBloc;

  String? _selfId;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final String _inviteMedia = 'video';

  List<RTCVideoRenderer> _remoteRenderers = [];

  bool _inCalling = false;
  bool _shouldShareScreen = false;

  /// List of sessions attached to the signaling
  List<Session?> _sessions = [];


  @override
  initState() {
    super.initState();
    _callBloc = CallSampleV2Bloc();
    initRenderers();
    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();

    await _remoteRenderer.initialize();
  }

  @override
  dispose() {
    super.dispose();
    _signaling?.close();
    _localRenderer.dispose();
  }

  void _connect() async {
    _signaling ??= Signaling(widget.host)..connect();
    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.ConnectionClosed:
        case SignalingState.ConnectionError:
        case SignalingState.ConnectionOpen:
          break;
      }
    };

    _signaling?.onCallStateChange = (Session session, CallState state) {
      switch (state) {

        case CallState.CallStateNew:
          _peerIdsInvited.add(session.pid);

          _callBloc.add(CallSampleCallStateNew(session: session));

          break;
        case CallState.CallStateBye:
          _callBloc.add(CallSampleRemoveRemoteRenderer(
              id: _peerIdsInvited.indexWhere((element) => session.pid == element),
              videoRenderers: _remoteRenderers
          ));

          break;
        case CallState.CallStateInvite:
        case CallState.CallStateConnected:
        case CallState.CallStateRinging:
      }
    };

    _signaling?.onPeersUpdate = ((event) {
      _callBloc.add(CallSampleUpdatePeers(peers: event['peers'], selfId: event['self']));
    });

    _signaling?.onLocalStream = ((stream) {
      if (!_inCalling){
        _localRenderer.srcObject = stream;
      }

    });

    _signaling?.onAddRemoteStream = ((_, stream) {

      _remoteRenderer.srcObject = stream;

      _callBloc.add(CallSampleAddRemoteRenderer(
        stream: stream,
      ));
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {

      _remoteRenderer.srcObject = null;

      _callBloc.add(CallSampleRemoveRemoteRenderer(
        id: _peerIdsInvited.indexWhere((element) => stream.id == element),
        videoRenderers: _remoteRenderers
      ));
    });
  }

  /// invite a different peer
  _invitePeer(BuildContext context, String peerId, bool useScreen) async {
    if (_signaling != null && peerId != _selfId) {
      print("callSample invite peerId = $peerId");
      _signaling?.invite(peerId, _inviteMedia, useScreen);
    }
  }


  _hangUp() {

    CallManager.isEndCallPressed = true;

    if (_sessions.isNotEmpty) {
      // _signaling?.bye(_session!.sid);
      int _sessionsLength = _sessions.length;
      for (int i = 0; i < _sessionsLength; i++){
        _signaling?.bye(_sessions[i]!.sid);
      }
    }
  }

  _switchCamera() {
    _signaling?.switchCamera();
  }

  _muteMic() {
    _signaling?.muteMic();
  }

  _buildRow(context, peer) {
    var self = (peer['id'] == _selfId);

    return ListBody(children: <Widget>[
      ListTile(
        title: Text(self
          ? peer['name'] + ', ID: ${peer['id']} ' + ' [Your self]'
          : peer['name'] + ', ID: ${peer['id']} '),
        subtitle: Text('[' + peer['user_agent'] + ']'),
        trailing: SizedBox(
            width: 100.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.videocam,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () {
                      _shouldShareScreen = false;
                      _invitePeer(context, peer['id'], _shouldShareScreen);
                    },
                    tooltip: 'Video calling',
                  ),
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.screen_share,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () {
                      _shouldShareScreen = true;
                      _invitePeer(context, peer['id'], true);
                    },
                    tooltip: 'Screen sharing',
                  )
                ])),
      ),
      Divider()
    ]);
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallSampleV2Bloc, CallSampleV2State>(
      bloc: _callBloc,
      listener: (context, state) {
        print('listener state = $state');
        if (state is CallSampleAddRemoteRendererSuccess){
          _remoteRenderers.add(state.videoRenderer);
        }else if (state is CallSampleRemoveRemoteRendererSuccess){
          _remoteRenderers = state.videoRenderers;
          _sessions.removeAt(state.id);
          _peerIdsInvited.removeAt(state.id);
          if (_remoteRenderers.isEmpty){
            _callBloc.add(CallSampleRemoveLocalRenderer());
          }
        }else if (state is CallSampleUpdatePeersSuccess) {
          _selfId = state.selfId;
          _peers = state.peers;
        }else if (state is CallSampleChangeCallSuccess){
          _inCalling = state.inCall;
        }else if (state is CallSampleRemoveLocalRendererSuccess){
          _localRenderer.srcObject = null;
          _inCalling = false;
          _peerIdsInvited.clear();
          _sessions.clear();

        }
        else if (state is CallSampleCallStateNewSuccess){
          _inCalling = true;
          _sessions.add(state.session);
        }
      },
      builder: (context, state) {
        print('builder state = $state');
        if (_peers.isNotEmpty){
          return Scaffold(
            appBar: AppBar(
              title: Text('P2P Call Sample' +
                  (_selfId != null ? ' [Your ID ($_selfId)] ' : '')),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: null,
                  tooltip: 'setup',
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: _inCalling
              ? SizedBox(
              width: 300.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(Icons.add),
                      onPressed: (){
                        _invitePeer(context, '123458', _shouldShareScreen);
                      },
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.switch_camera),
                      onPressed: _switchCamera,
                    ),
                    FloatingActionButton(
                      onPressed: _hangUp,
                      tooltip: 'Hangup',
                      child: Icon(Icons.call_end),
                      backgroundColor: Colors.pink,
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.mic_off),
                      onPressed: _muteMic,
                    )
                  ]))
              : null,
            body: _inCalling
              ? OrientationBuilder(builder: (context, orientation) {
              return Container(
                child: Stack(children: <Widget>[
                  Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 0.0,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(color: Colors.black54),
                          child: Column(
                            children: _remoteRenderers.map((e) => Expanded(
                              flex: 1,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  RTCVideoView(e),
                                  Container(child: Text(e.srcObject!.ownerTag), color: Colors.white,)
                                ],
                              ),
                            )).toList(),
                          ),
                        )),
                    Positioned(
                      left: 20.0,
                      top: 20.0,
                      child: Container(
                        width: orientation == Orientation.portrait ? 90.0 : 120.0,
                        height:
                        orientation == Orientation.portrait ? 120.0 : 90.0,
                        child: RTCVideoView(_localRenderer, mirror: true),
                        decoration: BoxDecoration(color: Colors.black54),
                      ),
                    ),
                  ]),
                );
              })
            : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: (_peers != null ? _peers.length : 0),
              itemBuilder: (context, i) {
                return _buildRow(context, _peers[i]);
              }),
          );
        }else{
          return Scaffold(
            body: const Center(child: CircularProgressIndicator(),),
          );
        }
      },
    );
  }
}