import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../utils/theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  final Doctor doctor;

  const VideoCallScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isCallControlsVisible = true;
  Timer? _controlsVisibilityTimer;
  Duration _callDuration = Duration.zero;
  late Timer _callDurationTimer;

  @override
  void initState() {
    super.initState();
    _setupCallDurationTimer();
    _resetControlsVisibilityTimer();
  }

  @override
  void dispose() {
    _controlsVisibilityTimer?.cancel();
    _callDurationTimer.cancel();
    super.dispose();
  }

  void _setupCallDurationTimer() {
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _resetControlsVisibilityTimer() {
    _controlsVisibilityTimer?.cancel();
    setState(() {
      _isCallControlsVisible = true;
    });
    _controlsVisibilityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isCallControlsVisible = false;
        });
      }
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
    _resetControlsVisibilityTimer();
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
    _resetControlsVisibilityTimer();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _resetControlsVisibilityTimer();
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetControlsVisibilityTimer,
        child: Stack(
          children: [
            // Remote video (doctor)
            _buildRemoteVideo(),
            
            // Local video (patient)
            _buildLocalVideo(),
            
            // Call controls and info
            AnimatedOpacity(
              opacity: _isCallControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  _buildCallInfo(),
                  const Spacer(),
                  _buildCallControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1E2E4D),
      child: Stack(
        children: [
          // Doctor image or video placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: AppTheme.lightBlueBackground,
                  backgroundImage: NetworkImage(widget.doctor.imageUrl),
                  onBackgroundImageError: (_, __) {},
                  child: widget.doctor.imageUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 70,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.doctor.specialty,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Connecting...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalVideo() {
    return Positioned(
      top: 100,
      right: 20,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        // Placeholder for local camera feed
        child: const Center(
          child: Icon(
            Icons.person,
            color: Colors.white54,
            size: 60,
          ),
        ),
      ),
    );
  }

  Widget _buildCallInfo() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_enhance,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: _isMicMuted ? Colors.red : Colors.white,
                  backgroundColor: Colors.black54,
                  onPressed: _toggleMic,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.call_end_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.red,
                  size: 32,
                  padding: 16,
                  onPressed: _endCall,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                  color: _isCameraOff ? Colors.red : Colors.white,
                  backgroundColor: Colors.black54,
                  onPressed: _toggleCamera,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.autorenew_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  onPressed: () {},
                  size: 20,
                  padding: 12,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  onPressed: _toggleSpeaker,
                  size: 20,
                  padding: 12,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.chat_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  onPressed: () {},
                  size: 20,
                  padding: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    double size = 24,
    double padding = 14,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Icon(
              icon,
              color: color,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
} 