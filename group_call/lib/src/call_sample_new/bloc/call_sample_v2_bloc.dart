import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:group_call/src/call_sample/signaling.dart';

part 'call_sample_v2_event.dart';
part 'call_sample_v2_state.dart';

class CallSampleV2Bloc extends Bloc<CallSampleV2Event, CallSampleV2State> {
  CallSampleV2Bloc() : super(CallSampleV2Initial()) {
    on<CallSampleRemoveRemoteRenderer>(_removeRemoteRenderer);
    on<CallSampleRemoveLocalRenderer>(_removeLocalRenderer);
    on<CallSampleAddRemoteRenderer>(_addRemoteRenderer);
    on<CallSampleUpdatePeers>(_updatePeers);
    on<CallSampleCallStateNew>(_callStateNew);
  }

  Future _removeRemoteRenderer(CallSampleRemoveRemoteRenderer event, Emitter<CallSampleV2State> emit) async {
    emit(CallSampleV2Initial());
    List<RTCVideoRenderer> videoRenderer = event.videoRenderers;
    videoRenderer.removeAt(event.id);
    emit(CallSampleRemoveRemoteRendererSuccess(videoRenderers: videoRenderer, id: event.id));
  }

  Future _removeLocalRenderer(CallSampleRemoveLocalRenderer event, Emitter<CallSampleV2State> emit) async {
    emit(CallSampleV2Initial());
    emit(CallSampleRemoveLocalRendererSuccess());
  }

  Future _addRemoteRenderer(CallSampleAddRemoteRenderer event, Emitter<CallSampleV2State> emit) async {
    emit(CallSampleV2Initial());
    RTCVideoRenderer _newRemoteRenderer = RTCVideoRenderer();
    await _newRemoteRenderer.initialize();
    _newRemoteRenderer.srcObject = event.stream;
    emit(CallSampleAddRemoteRendererSuccess(videoRenderer: _newRemoteRenderer));
  }

  Future _updatePeers(CallSampleUpdatePeers event, Emitter<CallSampleV2State> emit) async {
    emit(CallSampleV2Initial());
    emit(CallSampleUpdatePeersSuccess(selfId: event.selfId, peers: event.peers));
  }

  Future _callStateNew(CallSampleCallStateNew event, Emitter<CallSampleV2State> emit) async {
    emit(CallSampleV2Initial());
    emit(CallSampleCallStateNewSuccess(session: event.session));
  }
}
