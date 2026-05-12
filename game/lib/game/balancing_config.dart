import 'package:mg_common_game/systems/balancing/balancing.dart';

const kDefaultBalancingConfig = BalancingConfig(
  gameId: 'mg-0009',
  version: 1,
  currencies: [
    CurrencyConfig(id: 'gold', baseEarnRate: 10.0),
    CurrencyConfig(
      id: 'gems',
      baseEarnRate: 1.0,
      earnCurve: CurveType.logarithmic,
      earnGrowthFactor: 0.5,
    ),
  ],
  xpCurve: XpCurveConfig(baseXp: 100, maxLevel: 100),
  difficultyScaling: DifficultyScalingConfig(scalingFactor: 0.08),
  customParams: {
    'card_reward_multiplier': 1.0,
    'skill_charge_rate': 1.0,
  },
);
