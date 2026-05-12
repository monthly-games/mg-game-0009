import 'package:mg_common_game/systems/tutorial/tutorial.dart';

const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Hero Collection Card Puzzle Tutorial',
  steps: [
    TutorialStep(
      id: 'match_cards',
      title: 'Match hero cards',
      description: 'Match cards to charge hero skills and clear the board.',
      targetSelector: 'board',
    ),
    TutorialStep(
      id: 'use_skills',
      title: 'Use hero skills',
      description: 'Spend skill charge to trigger powerful card effects.',
      targetSelector: 'skill_bar',
    ),
    TutorialStep(
      id: 'upgrade_deck',
      title: 'Grow your roster',
      description: 'Collect rewards and upgrade your hero deck between runs.',
      targetSelector: 'collection',
    ),
  ],
  skippable: true,
  showOnFirstLaunch: true,
  trigger: TutorialTrigger.firstLaunch,
);
