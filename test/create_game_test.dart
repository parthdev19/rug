import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/create_game/controller/create_game_controller.dart';

void main() {
  group('CreateGameController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.listen(
        createGameControllerProvider,
        (previous, next) {},
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has correct default configurations', () {
      final state = container.read(createGameControllerProvider);
      expect(state.totalPlayers, 5);
      expect(state.defaultPoints, 100);
      expect(state.totalRounds, 5);
      expect(state.isValid, true);
    });

    test('incrementPlayers and decrementPlayers respect limits (5 to 9)', () {
      final notifier = container.read(createGameControllerProvider.notifier);

      // Decrement below min (5)
      notifier.decrementPlayers();
      expect(container.read(createGameControllerProvider).totalPlayers, 5);

      // Increment step-by-step to max (9)
      for (int i = 0; i < 4; i++) {
        notifier.incrementPlayers();
      }
      expect(container.read(createGameControllerProvider).totalPlayers, 9);

      // Increment beyond max (9)
      notifier.incrementPlayers();
      expect(container.read(createGameControllerProvider).totalPlayers, 9);

      // Decrement back down
      notifier.decrementPlayers();
      expect(container.read(createGameControllerProvider).totalPlayers, 8);
    });

    test('incrementPoints and decrementPoints respect limits (100 to 170, steps of 5)', () {
      final notifier = container.read(createGameControllerProvider.notifier);

      // Decrement below min (100)
      notifier.decrementPoints();
      expect(container.read(createGameControllerProvider).defaultPoints, 100);

      // Increment step-by-step to max (170)
      for (int i = 0; i < 15; i++) {
        notifier.incrementPoints();
      }
      expect(container.read(createGameControllerProvider).defaultPoints, 170);

      // Increment beyond max (170)
      notifier.incrementPoints();
      expect(container.read(createGameControllerProvider).defaultPoints, 170);

      // Decrement back down
      notifier.decrementPoints();
      expect(container.read(createGameControllerProvider).defaultPoints, 165);
    });

    test('incrementRounds and decrementRounds respect limits (1 to 20)', () {
      final notifier = container.read(createGameControllerProvider.notifier);

      // Decrement to minimum (1)
      for (int i = 0; i < 5; i++) {
        notifier.decrementRounds();
      }
      expect(container.read(createGameControllerProvider).totalRounds, 1);

      // Decrement below min (1)
      notifier.decrementRounds();
      expect(container.read(createGameControllerProvider).totalRounds, 1);

      // Increment step-by-step to max (20)
      for (int i = 0; i < 22; i++) {
        notifier.incrementRounds();
      }
      expect(container.read(createGameControllerProvider).totalRounds, 20);

      // Increment beyond max (20)
      notifier.incrementRounds();
      expect(container.read(createGameControllerProvider).totalRounds, 20);
    });

    test('validate returns true for valid bounds', () {
      final notifier = container.read(createGameControllerProvider.notifier);
      final isValid = notifier.validate();
      expect(isValid, true);
      expect(container.read(createGameControllerProvider).isValid, true);
    });
  });
}
