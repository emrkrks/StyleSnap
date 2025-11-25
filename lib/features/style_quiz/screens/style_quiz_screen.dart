import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/style_quiz_providers.dart';

class StyleQuizScreen extends ConsumerStatefulWidget {
  const StyleQuizScreen({super.key});

  @override
  ConsumerState<StyleQuizScreen> createState() => _StyleQuizScreenState();
}

class _StyleQuizScreenState extends ConsumerState<StyleQuizScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Question 1: Favorite Colors
  final List<Color> _colorOptions = [
    const Color(0xFF000000), // Black
    const Color(0xFFFFFFFF), // White
    const Color(0xFF808080), // Gray
    const Color(0xFF0000FF), // Blue
    const Color(0xFF008000), // Green
    const Color(0xFFFF0000), // Red
    const Color(0xFFFFC0CB), // Pink
    const Color(0xFF800080), // Purple
    const Color(0xFFFFA500), // Orange
    const Color(0xFFFFFF00), // Yellow
    const Color(0xFF8B4513), // Brown
    const Color(0xFF00CED1), // Turquoise
  ];

  final List<String> _colorNames = [
    'Black', 'White', 'Gray', 'Blue', 'Green', 'Red',
    'Pink', 'Purple', 'Orange', 'Yellow', 'Brown', 'Turquoise',
  ];

  // Question 2: Style Preferences
  final List<String> _styleOptions = [
    'Casual', 'Business', 'Sporty', 'Elegant', 
    'Bohemian', 'Minimalist', 'Vintage', 'Streetwear'
  ];

  // Question 3: Body Type
  final List<String> _bodyTypes = [
    'Slim', 'Athletic', 'Curvy', 'Plus Size', 'Petite', 'Tall'
  ];

  // Question 4: Occasions
  final List<String> _occasions = [
    'Work/Office', 'Casual Outings', 'Sports/Gym', 'Parties/Events',
    'Travel', 'Home/Relaxing', 'Dates', 'Formal Events'
  ];

  // Question 5: Budget
  final List<String> _budgetOptions = [
    'Budget-Friendly\n(<₺500/month)',
    'Moderate\n(₺500-1500/month)',
    'Premium\n(₺1500-3000/month)',
    'Luxury\n(>₺3000/month)',
  ];

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeQuiz();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeQuiz() {
    // Save preferences and navigate to home
    ref.read(styleQuizProvider.notifier).savePreferences();
    
    // TODO: Navigate to home screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved! 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(styleQuizProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Preferences'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildColorPage(quizState),
                _buildStylePage(quizState),
                _buildBodyTypePage(quizState),
                _buildOccasionsPage(quizState),
                _buildBudgetPage(quizState),
              ],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.grey300),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canContinue(quizState) ? _nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentPage == 4 ? 'Complete' : 'Next',
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue(StyleQuizState state) {
    switch (_currentPage) {
      case 0:
        return state.favoriteColors.isNotEmpty;
      case 1:
        return state.stylePreferences.isNotEmpty;
      case 2:
        return state.bodyType != null;
      case 3:
        return state.occasions.isNotEmpty;
      case 4:
        return state.budget != null;
      default:
        return false;
    }
  }

  Widget _buildColorPage(StyleQuizState state) {
    return _buildQuestionPage(
      question: 'What are your favorite colors?',
      subtitle: 'Select all that apply',
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _colorOptions.length,
        itemBuilder: (context, index) {
          final color = _colorOptions[index];
          final colorName = _colorNames[index];
          final isSelected = state.favoriteColors.contains(colorName);

          return GestureDetector(
            onTap: () {
              ref.read(styleQuizProvider.notifier).toggleColor(colorName);
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.grey300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.white)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  colorName,
                  style: AppTextStyles.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStylePage(StyleQuizState state) {
    return _buildQuestionPage(
      question: 'What styles do you like?',
      subtitle: 'Select all that apply',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: _styleOptions.map((style) {
          final isSelected = state.stylePreferences.contains(style);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CheckboxListTile(
              title: Text(style, style: AppTextStyles.bodyLarge),
              value: isSelected,
              onChanged: (_) {
                ref.read(styleQuizProvider.notifier).toggleStyle(style);
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.grey100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBodyTypePage(StyleQuizState state) {
    return _buildQuestionPage(
      question: 'What's your body type?',
      subtitle: 'Select one',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: _bodyTypes.map((type) {
          final isSelected = state.bodyType == type;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              title: Text(type, style: AppTextStyles.bodyLarge),
              value: type,
              groupValue: state.bodyType,
              onChanged: (value) {
                ref.read(styleQuizProvider.notifier).setBodyType(value!);
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.grey100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOccasionsPage(StyleQuizState state) {
    return _buildQuestionPage(
      question: 'What occasions do you dress for?',
      subtitle: 'Select all that apply',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: _occasions.map((occasion) {
          final isSelected = state.occasions.contains(occasion);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CheckboxListTile(
              title: Text(occasion, style: AppTextStyles.bodyLarge),
              value: isSelected,
              onChanged: (_) {
                ref.read(styleQuizProvider.notifier).toggleOccasion(occasion);
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.grey100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetPage(StyleQuizState state) {
    return _buildQuestionPage(
      question: 'What's your monthly clothing budget?',
      subtitle: 'Select one',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: _budgetOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final budget = entry.value;
          final isSelected = state.budget == index;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<int>(
              title: Text(
                budget,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              value: index,
              groupValue: state.budget,
              onChanged: (value) {
                ref.read(styleQuizProvider.notifier).setBudget(value!);
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.grey100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionPage({
    required String question,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
