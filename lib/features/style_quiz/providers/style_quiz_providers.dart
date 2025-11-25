import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/user_repository.dart';
import '../../auth/providers/auth_providers.dart';

final styleQuizProvider =
    StateNotifierProvider<StyleQuizNotifier, StyleQuizState>((ref) {
      return StyleQuizNotifier(ref);
    });

class StyleQuizState {
  final List<String> favoriteColors;
  final List<String> stylePreferences;
  final String? bodyType;
  final List<String> occasions;
  final int? budget;

  StyleQuizState({
    this.favoriteColors = const [],
    this.stylePreferences = const [],
    this.bodyType,
    this.occasions = const [],
    this.budget,
  });

  StyleQuizState copyWith({
    List<String>? favoriteColors,
    List<String>? stylePreferences,
    String? bodyType,
    List<String>? occasions,
    int? budget,
  }) {
    return StyleQuizState(
      favoriteColors: favoriteColors ?? this.favoriteColors,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      bodyType: bodyType ?? this.bodyType,
      occasions: occasions ?? this.occasions,
      budget: budget ?? this.budget,
    );
  }
}

class StyleQuizNotifier extends StateNotifier<StyleQuizState> {
  final Ref ref;

  StyleQuizNotifier(this.ref) : super(StyleQuizState());

  void toggleColor(String color) {
    final colors = List<String>.from(state.favoriteColors);
    if (colors.contains(color)) {
      colors.remove(color);
    } else {
      colors.add(color);
    }
    state = state.copyWith(favoriteColors: colors);
  }

  void toggleStyle(String style) {
    final styles = List<String>.from(state.stylePreferences);
    if (styles.contains(style)) {
      styles.remove(style);
    } else {
      styles.add(style);
    }
    state = state.copyWith(stylePreferences: styles);
  }

  void setBodyType(String bodyType) {
    state = state.copyWith(bodyType: bodyType);
  }

  void toggleOccasion(String occasion) {
    final occasions = List<String>.from(state.occasions);
    if (occasions.contains(occasion)) {
      occasions.remove(occasion);
    } else {
      occasions.add(occasion);
    }
    state = state.copyWith(occasions: occasions);
  }

  void setBudget(int budget) {
    state = state.copyWith(budget: budget);
  }

  Future<void> savePreferences() async {
    final repository = ref.read(userRepositoryProvider);
    final currentUser = ref.read(currentUserProvider).value;

    if (currentUser != null) {
      // Update user profile with style preferences
      final updatedUser = currentUser.copyWith(
        favoriteColors: state.favoriteColors,
        stylePreferences: state.stylePreferences,
        bodyType: state.bodyType,
        preferredOccasions: state.occasions,
        clothingBudget: _getBudgetValue(state.budget),
        onboardingCompleted: true,
        updatedAt: DateTime.now(),
      );

      await repository.updateUser(updatedUser);
    }
  }

  double? _getBudgetValue(int? budgetIndex) {
    if (budgetIndex == null) return null;

    switch (budgetIndex) {
      case 0:
        return 500.0;
      case 1:
        return 1000.0;
      case 2:
        return 2000.0;
      case 3:
        return 3500.0;
      default:
        return null;
    }
  }
}
