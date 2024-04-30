import 'package:pitch_detector_dart/algorithm/pitch_algorithm.dart';
import 'package:pitch_detector_dart/algorithm/yin.dart';
import 'package:pitch_detector_dart/exceptions/invalid_audio_buffer_exception.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:pitch_detector_dart/util/pcm_util_extensions.dart';
import 'package:flutter/material.dart';

class PitchDetector extends StatefulWidget {
  const PitchDetector({super.key});

  @override
  State<PitchDetector> createState() => _PitchDetectorState();
}

class _PitchDetectorState extends State<PitchDetector> {

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
