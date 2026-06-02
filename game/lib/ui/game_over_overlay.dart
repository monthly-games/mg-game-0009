import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import '../core/localization/app_localizations.dart';


class GameOverOverlay extends StatefulWidget {
  final int score;
  final int highScore;
  final bool isNewRecord;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  final String? battleResult; // 'win', 'lose', 'draw'

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.onRestart,
    required this.onMainMenu,
    this.battleResult,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _goldEarned = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();

    // Reward Logic: 1 Gold per 1 Score? Or 10 Score?
    // Let's make it 1 Gold per 1 Score for now to be generous.
    // Battle mode: wins give bonus gold
    if (widget.battleResult == 'win') {
      _goldEarned = widget.score > 0 ? widget.score + 10 : 10; // Bonus win gold
    } else if (widget.battleResult == 'lose' || widget.battleResult == 'draw') {
      _goldEarned = widget.score > 0 ? widget.score : 2; // Consolation gold
    } else {
      _goldEarned = widget.score;
    }

    // Add Gold
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_goldEarned > 0) {
        GetIt.I<GoldManager>().addGold(_goldEarned);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(MGSpacing.lg),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MGColors.textDisabled, width: 2),
            boxShadow: [
              BoxShadow(
                color: MGColors.backgroundDark.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                _getGameTitle(),
                style: TextStyle(
                  color: _getTitleColor(),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: MGSpacing.lg),

              // Scores
              if (widget.battleResult != null)
                _buildBattleResult(),
              if (widget.battleResult == null)
                _buildScoreRow('Score', '${widget.score}'),
              const SizedBox(height: MGSpacing.sm),
              if (widget.battleResult == null)
                _buildScoreRow(
                  'Best',
                  '${widget.highScore}',
                  isNewRecord: widget.isNewRecord,
                ),

              const SizedBox(height: MGSpacing.lg),

              // Gold Reward
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: MGColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MGColors.gold.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: MGColors.gold),
                    const SizedBox(width: MGSpacing.xs),
                    Text(
                      '+$_goldEarned Gold',
                      style: const TextStyle(
                        color: MGColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: MGSpacing.xl),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    icon: Icons.home,
                    label: context.l10n.menuNavigationMainMenu,
                    color: MGColors.surfaceDark,
                    onTap: widget.onMainMenu,
                  ),
                  _buildButton(
                    icon: Icons.refresh,
                    label: 'Retry',
                    color: MGColors.success,
                    onTap: widget.onRestart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(
    String label,
    String value, {
    bool isNewRecord = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MGColors.common,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            if (isNewRecord)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: MGColors.gold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: MGColors.backgroundDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            Text(
              value,
              style: const TextStyle(
                color: MGColors.textHighEmphasis,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: MGColors.textHighEmphasis, size: 28),
              const SizedBox(height: MGSpacing.xxs),
              Text(
                label,
                style: const TextStyle(
                  color: MGColors.textHighEmphasis,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGameTitle() {
    if (widget.battleResult == 'win') return 'VICTORY!';
    if (widget.battleResult == 'lose') return 'DEFEAT';
    if (widget.battleResult == 'draw') return 'DRAW';
    return 'GAME OVER';
  }

  Color _getTitleColor() {
    if (widget.battleResult == 'win') return MGColors.success;
    if (widget.battleResult == 'lose') return MGColors.error;
    if (widget.battleResult == 'draw') return MGColors.warning;
    return Colors.redAccent;
  }

  Widget _buildBattleResult() {
    String resultText;
    Color resultColor;
    String description;

    switch (widget.battleResult) {
      case 'win':
        resultText = '🏆 승리!';
        resultColor = MGColors.success;
        description = 'AI 뱀을 물리쳤습니다!';
        break;
      case 'lose':
        resultText = '💀 패배';
        resultColor = MGColors.error;
        description = 'AI 뱀이 이겼습니다.';
        break;
      case 'draw':
        resultText = '🤝 무승부';
        resultColor = MGColors.warning;
        description = '동시에 충돌했습니다!';
        break;
      default:
        resultText = '게임 종료';
        resultColor = MGColors.textHighEmphasis;
        description = '';
    }

    return Column(
      children: [
        Text(
          resultText,
          style: TextStyle(
            color: resultColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              description,
              style: const TextStyle(
                color: MGColors.textMediumEmphasis,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
