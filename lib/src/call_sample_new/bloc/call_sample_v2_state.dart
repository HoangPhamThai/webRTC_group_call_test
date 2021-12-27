part of 'call_sample_v2_bloc.dart';

abstract class CallSampleV2State extends Equatable {
  const CallSampleV2State();
}

class CallSampleV2Initial extends CallSampleV2State {
  @override
  List<Object> get props => [];
}

class CallSampleRemoveLocalRendererSuccess extends CallSampleV2State {
  @override
  List<Object?> get props => [];
}

class CallSampleRemoveRemoteRendererSuccess extends CallSampleV2State {
  final List<RTCVideoRenderer> videoRenderers;
  final int id;
  CallSampleRemoveRemoteRendererSuccess({required this.videoRenderers, required this.id});
  @override
  List<Object?> get props => [videoRenderers, id];
}

class CallSampleAddRemoteRendererSuccess extends CallSampleV2State {
  final RTCVideoRenderer videoRenderer;
  CallSampleAddRemoteRendererSuccess({required this.videoRenderer});
  @override
  List<Object?> get props => [videoRenderer];

}

class CallSampleUpdatePeersSuccess extends CallSampleV2State{
  final String selfId;
  final dynamic peers;
  CallSampleUpdatePeersSuccess({required this.selfId, required this.peers});
  @override
  List<Object?> get props => [selfId, peers];
}

class CallSampleChangeCallSuccess extends CallSampleV2State{
  final bool inCall;
  CallSampleChangeCallSuccess({required this.inCall});
  @override
  List<Object?> get props => [inCall];
}

class CallSampleByeSuccess extends CallSampleV2State {
  @override
  List<Object?> get props => [];

}

class CallSampleCallStateNewSuccess extends CallSampleV2State {
  final Session session;
  CallSampleCallStateNewSuccess({required this.session});
  @override
  List<Object?> get props => [session];
}