import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI 기반 스네이크 게임 HUD
/// mg_common_game의 공통 UI 컴포넌트 활용
class MGSnakeHud extends StatelessWidget {
  final int score;
  final int highScore;
  final int length;
  final int coins;
  final int? timeRemaining; // 타임어택 모드용
  final bool isPaused;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const MGSnakeHud({
    super.key,
    required this.score,
    this.highScore = 0,
    this.length = 3,
    this.coins = 0,
    this.timeRemaining,
    this.isPaused = false,
    this.onPause,
    this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Positioned.fill(
      child: Column(
        children: [
          // 상단 HUD: 일시정지 + 점수 + 코인
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 일시정지 버튼
                MGIconButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  onPressed: isPaused ? onResume : onPause,
                  size: 44,
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                ),

                // 점수 표시
                _buildScoreDisplay(),

                // 코인 표시
                MGResourceBar(
                  icon: Icons.monetization_on,
                  value: _formatNumber(coins),
                  iconColor: MGColors.gold,
                  onTap: null,
                ),
              ],
            ),
          ),

          MGSpacing.vSm,

          // 뱀 길이 + 타이머 표시
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: safeArea.left + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLengthDisplay(),
                if (timeRemaining != null) ...[
                  MGSpacing.hMd,
                  _buildTimerDisplay(),
                ],
              ],
            ),
          ),

          // 중앙 영역 확장 (게임 영역)
          const Expanded(child: SizedBox()),

          // 하단: 최고 점수 (필요시)
          if (highScore > 0)
            Container(
              padding: EdgeInsets.only(
                bottom: safeArea.bottom + MGSpacing.hudMargin,
                left: safeArea.left + MGSpacing.hudMargin,
                right: safeArea.right + MGSpacing.hudMargin,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 20,
                    ),
                    MGSpacing.hXs,
                    Text(
                      'Best: $highScore',
                      style: MGTextStyles.hudSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MGColors.warning.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Text(
        '$score',
        style: MGTextStyles.display.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
      ),
    );
  }

  Widget _buildLengthDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.linear_scale,
            color: Colors.green,
            size: 20,
          ),
          MGSpacing.hXs,
          Text(
            'Length: $length',
            style: MGTextStyles.hud.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final isLow = timeRemaining != null && timeRemaining! <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: isLow
            ? Border.all(color: Colors.red.withValues(alpha: 0.7), width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isLow ? Colors.red : Colors.orange,
            size: 20,
          ),
          MGSpacing.hXs,
          Text(
            '${timeRemaining}s',
            style: MGTextStyles.hud.copyWith(
              color: isLow ? Colors.red : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
