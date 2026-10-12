import 'dart:js_interop';

@JS('window.oneVOneAudio.playMove')
external void _jsPlayMove();

@JS('window.oneVOneAudio.playCapture')
external void _jsPlayCapture();

@JS('window.oneVOneAudio.playVictory')
external void _jsPlayVictory();

@JS('window.oneVOneAudio.playDefeat')
external void _jsPlayDefeat();

@JS('window.oneVOneAudio.playTick')
external void _jsPlayTick();

void playMove() {
  try {
    _jsPlayMove();
  } catch (_) {}
}

void playCapture() {
  try {
    _jsPlayCapture();
  } catch (_) {}
}

void playVictory() {
  try {
    _jsPlayVictory();
  } catch (_) {}
}

void playDefeat() {
  try {
    _jsPlayDefeat();
  } catch (_) {}
}

void playTick() {
  try {
    _jsPlayTick();
  } catch (_) {}
}
