import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI ê¸°ë°˜ Card Puzzle ê²Œìž„ HUD
/// mg_common_game??ê³µí†µ UI ì»´í¬?ŒíŠ¸ ?œìš©
class MGCardPuzzleHud extends StatelessWidget {
  final int score;
  final int highScore;
  final int length;
  final int coins;
  final int? timeRemaining; // ?€?„ì–´??ëª¨ë“œ??  final bool isPaused;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const MGCardPuzzleHud({
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
          // ?ë‹¨ HUD: ?¼ì‹œ?•ì? + ?ìˆ˜ + ì½”ì¸
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ?¼ì‹œ?•ì? ë²„íŠ¼
                MGIconButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  onPressed: isPaused ? onResume : onPause,
                  size: 44,
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                ),

                // ?ìˆ˜ ?œì‹œ
                _buildScoreDisplay(),

                // ì½”ì¸ ?œì‹œ
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

          // ë±€ ê¸¸ì´ + ?€?´ë¨¸ ?œì‹œ
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

          // ì¤‘ì•™ ?ì—­ ?•ìž¥ (ê²Œìž„ ?ì—­)
          const Expanded(child: SizedBox()),

          // ?˜ë‹¨: ìµœê³  ?ìˆ˜ (?„ìš”??
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
