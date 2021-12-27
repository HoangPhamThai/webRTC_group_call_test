# webRTC_group_call_test

This repo is based on [Flutter WebRTC demo](https://github.com/flutter-webrtc/flutter-webrtc-demo).

This repo is created to test the performance of the Flutter WebRTC library in case of group call with 3 P2P connections.

For simplicity, the ID of the 2nd peer is fixed.

To see how it works, please prepare 3 devices. They will act as self, peer 1 and peer 2 respectively.

For self and peer 1, set random id to them by uncommenting randomNumeric code in signaling.dart file. For peer 2, set a fixed id to it.

Make self calling peer 1 (or peer 1 calls self), then press the "+" button on the screen of self and peer 1 to let them call peer 2.
