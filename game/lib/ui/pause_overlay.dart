import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MGColors.backgroundDarkDark.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: MGColors.textHighEmphasis,
                shadows: [
                  Shadow(
                    offset: Offset(4, 4),
                    blurRadius: 8,
                    color: MGColors.backgroundDarkDark.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            _PauseButton(
              icon: Icons.play_arrow,
              label: 'RESUME',
              color: MGColors.success,
              onPressed: onResume,
            ),
            const SizedBox(height: 20),
            _PauseButton(
              icon: Icons.refresh,
              label: 'RESTART',
              color: MGColors.warning,
              onPressed: onRestart,
            ),
            const SizedBox(height: 20),
            _PauseButton(
              icon: Icons.home,
              label: 'MAIN MENU',
              color: MGColors.info,
              onPressed: onMainMenu,
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PauseButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: MGColors.textHighEmphasis,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게임 화면 우상단의 일시정지 버튼
class PauseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PauseButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: MGColors.backgroundDarkDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: MGColors.textHighEmphasis, width: 2),
            ),
            child: const Icon(
              Icons.pause,
              color: MGColors.textHighEmphasis,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
