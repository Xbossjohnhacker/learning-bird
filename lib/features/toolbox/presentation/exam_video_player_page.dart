import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../data/exam_materials_repository.dart';

class ExamVideoPlayerPage extends StatefulWidget {
  const ExamVideoPlayerPage({required this.material, super.key});
  final ExamMaterial material;

  @override
  State<ExamVideoPlayerPage> createState() => _ExamVideoPlayerPageState();
}

class _ExamVideoPlayerPageState extends State<ExamVideoPlayerPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialize;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.material.path));
    _initialize = _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  String _time(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.material.name)),
      body: FutureBuilder<void>(
        future: _initialize,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !_controller.value.isInitialized) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '视频无法播放。请确认文件未损坏，并优先使用 H.264 编码的 MP4 视频。',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final value = _controller.value;
          final maxMs = value.duration.inMilliseconds
              .toDouble()
              .clamp(1.0, double.infinity)
              .toDouble();
          final currentMs = value.position.inMilliseconds
              .toDouble()
              .clamp(0.0, maxMs)
              .toDouble();
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: value.aspectRatio == 0
                            ? 16 / 9
                            : value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Column(
                    children: [
                      Slider(
                        value: currentMs,
                        max: maxMs,
                        onChanged: (milliseconds) => _controller.seekTo(
                          Duration(milliseconds: milliseconds.round()),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton.filled(
                            key: const ValueKey('video-play-pause'),
                            tooltip: value.isPlaying ? '暂停' : '播放',
                            onPressed: () => value.isPlaying
                                ? _controller.pause()
                                : _controller.play(),
                            icon: Icon(
                              value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_time(value.position)} / ${_time(value.duration)}',
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: '后退 10 秒',
                            onPressed: () => _controller.seekTo(
                              Duration(
                                milliseconds:
                                    (value.position.inMilliseconds - 10000)
                                        .clamp(
                                          0,
                                          value.duration.inMilliseconds,
                                        ),
                              ),
                            ),
                            icon: const Icon(Icons.replay_10_rounded),
                          ),
                          IconButton(
                            tooltip: '前进 10 秒',
                            onPressed: () => _controller.seekTo(
                              Duration(
                                milliseconds:
                                    (value.position.inMilliseconds + 10000)
                                        .clamp(
                                          0,
                                          value.duration.inMilliseconds,
                                        ),
                              ),
                            ),
                            icon: const Icon(Icons.forward_10_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
