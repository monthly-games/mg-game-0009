import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Card Warrior ─────────────────────────────────────────────

const kCardWarriorMeta = SpineAssetMeta(
  key: 'card_warrior',
  path: 'spine/characters/card_warrior',
  atlasPath: 'assets/spine/characters/card_warrior/card_warrior.atlas',
  skeletonPath: 'assets/spine/characters/card_warrior/card_warrior.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Card Mage ────────────────────────────────────────────────

const kCardMageMeta = SpineAssetMeta(
  key: 'card_mage',
  path: 'spine/characters/card_mage',
  atlasPath: 'assets/spine/characters/card_mage/card_mage.atlas',
  skeletonPath: 'assets/spine/characters/card_mage/card_mage.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Card Archer ──────────────────────────────────────────────

const kCardArcherMeta = SpineAssetMeta(
  key: 'card_archer',
  path: 'spine/characters/card_archer',
  atlasPath: 'assets/spine/characters/card_archer/card_archer.atlas',
  skeletonPath: 'assets/spine/characters/card_archer/card_archer.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);
