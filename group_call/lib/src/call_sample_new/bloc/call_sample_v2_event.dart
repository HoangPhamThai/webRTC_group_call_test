part of 'call_sample_v2_bloc.dart';

abstract class CallSampleV2Event extends Equatable {
  const CallSampleV2Event();
}


class CallSampleRemoveLocalRenderer extends CallSampleV2Event {
  @override
  List<Object?> get props => [];

}

class CallSampleRemoveRemoteRenderer extends CallSampleV2Event {
  final List<RTCVideoRenderer> videoRenderers;
  final int id;
  CallSampleRemoveRemoteRenderer({required this.id, required this.videoRenderers});
  @override
  List<Object?> get props => [videoRenderers, id];
}

class CallSampleAddRemoteRenderer extends CallSampleV2Event {
  final MediaStream stream;
  CallSampleAddRemoteRenderer({required this.stream});
  @override
  List<Object?> get props => [stream];
}


class CallSampleUpdatePeers extends CallSampleV2Event {
  final String selfId;
  final dynamic peers;
  CallSampleUpdatePeers({required this.peers, required this.selfId});
  @override
  List<Object?> get props => [peers, selfId];
}


class CallSampleCallStateNew extends CallSampleV2Event{
  final Session session;
  CallSampleCallStateNew({required this.session});
  @override
  List<Object?> get props => [session];

}

