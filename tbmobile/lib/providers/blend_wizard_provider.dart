import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/models/base_mix.dart';
import '../data/models/ingredient.dart';
import '../data/models/blend_ingredient.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/ingredient_repository.dart';
import '../services/blend_formulation_service.dart';

class BlendWizardProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final IngredientRepository _ingredientRepository = IngredientRepository();
  final BlendFormulationService _formulationService = BlendFormulationService();

  // Wizard state
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Client & Setup
  User? _selectedClient;
  String _blendName = '';
  BaseMix? _selectedBaseMix;
  String _description = '';

  // Step 2: Health Goals
  final Set<String> _selectedHealthGoals = {};

  // Step 3: Ingredients
  final Map<int, double> _selectedIngredients = {}; // ingredientId -> amount
  List<Ingredient> _availableIngredients = [];
  List<Ingredient> _recommendedIngredients = [];

  // Step 4: Dosage Fine-tuning
  final Map<int, DosageValidation> _dosageValidations = {};

  // Step 5: Review
  double _totalWeight = 0.0;
  List<String> _warnings = [];

  // Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get selectedClient => _selectedClient;
  String get blendName => _blendName;
  BaseMix? get selectedBaseMix => _selectedBaseMix;
  String get description => _description;
  Set<String> get selectedHealthGoals => _selectedHealthGoals;
  Map<int, double> get selectedIngredients => _selectedIngredients;
  List<Ingredient> get availableIngredients => _availableIngredients;
  List<Ingredient> get recommendedIngredients => _recommendedIngredients;
  Map<int, DosageValidation> get dosageValidations => _dosageValidations;
  double get totalWeight => _totalWeight;
  List<String> get warnings => _warnings;

  // Navigation
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Step 1 Methods
  Future<List<User>> searchClients(String query) async {
    return await _userRepository.searchPatients(query);
  }

  void selectClient(User? client) {
    _selectedClient = client;
    notifyListeners();
  }

  void updateBlendName(String name) {
    _blendName = name;
    notifyListeners();
  }

  void selectBaseMix(BaseMix? baseMix) {
    _selectedBaseMix = baseMix;
    notifyListeners();
  }

  void updateDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  bool validateStep1() {
    return _selectedClient != null && 
           _blendName.isNotEmpty && 
           _selectedBaseMix != null;
  }

  // Step 2 Methods
  void toggleHealthGoal(String goal) {
    if (_selectedHealthGoals.contains(goal)) {
      _selectedHealthGoals.remove(goal);
    } else {
      _selectedHealthGoals.add(goal);
    }
    _updateRecommendations();
    notifyListeners();
  }

  bool validateStep2() {
    return _selectedHealthGoals.isNotEmpty;
  }

  // Step 3 Methods
  Future<void> loadIngredients() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _availableIngredients = await _ingredientRepository.getAllIngredients();
      await _updateRecommendations();
    } catch (e) {
      _errorMessage = 'Failed to load ingredients: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateRecommendations() async {
    if (_selectedHealthGoals.isEmpty) {
      _recommendedIngredients = [];
      return;
    }

    _recommendedIngredients = await _ingredientRepository
        .getRecommendedIngredients(_selectedHealthGoals.toList());
    notifyListeners();
  }

  void toggleIngredient(Ingredient ingredient) {
    if (_selectedIngredients.containsKey(ingredient.ingredientId)) {
      _selectedIngredients.remove(ingredient.ingredientId);
      _dosageValidations.remove(ingredient.ingredientId);
    } else {
      // Add with recommended dosage
      _selectedIngredients[ingredient.ingredientId] = ingredient.recommendedRange;
      _validateDosage(ingredient, ingredient.recommendedRange);
    }
    _calculateTotalWeight();
    notifyListeners();
  }

  bool isIngredientSelected(int ingredientId) {
    return _selectedIngredients.containsKey(ingredientId);
  }

  bool validateStep3() {
    return _selectedIngredients.isNotEmpty;
  }

  // Step 4 Methods
  void updateDosage(Ingredient ingredient, double amount) {
    _selectedIngredients[ingredient.ingredientId] = amount;
    _validateDosage(ingredient, amount);
    _calculateTotalWeight();
    notifyListeners();
  }

  void _validateDosage(Ingredient ingredient, double amount) {
    final validation = _formulationService.getDosageValidation(
      ingredient,
      amount,
      false, // Using customer max for now
    );
    _dosageValidations[ingredient.ingredientId] = validation;
  }

  void _calculateTotalWeight() {
    _totalWeight = _selectedIngredients.values.fold(0.0, (sum, amount) => sum + amount);
  }

  bool validateStep4() {
    // Check all dosages are valid
    for (var validation in _dosageValidations.values) {
      if (!validation.isValid) {
        return false;
      }
    }
    
    // Check total weight is within base mix range
    if (_selectedBaseMix != null) {
      return _formulationService.validateBlendWeight(_selectedBaseMix!, _totalWeight);
    }
    
    return true;
  }

  // Step 5 Methods
  Future<void> prepareReview() async {
    _warnings.clear();
    
    // Check ingredient interactions
    final ingredientIds = _selectedIngredients.keys.toList();
    _warnings = await _formulationService.checkIngredientInteractions(ingredientIds);
    
    // Add weight warning if needed
    if (_selectedBaseMix != null) {
      if (!_selectedBaseMix!.isWithinRange(_totalWeight)) {
        _warnings.add(
          'Total weight (${_totalWeight.toStringAsFixed(1)}g) is outside the recommended range ${_selectedBaseMix!.rangeDisplay}'
        );
      }
    }
    
    notifyListeners();
  }

  List<BlendIngredient> getBlendIngredients() {
    return _selectedIngredients.entries.map((entry) {
      return BlendIngredient(
        blendId: 0, // Will be set when saved
        ingredientId: entry.key,
        amount: entry.value,
      );
    }).toList();
  }

  // Reset wizard
  void reset() {
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    _selectedClient = null;
    _blendName = '';
    _selectedBaseMix = null;
    _description = '';
    _selectedHealthGoals.clear();
    _selectedIngredients.clear();
    _availableIngredients.clear();
    _recommendedIngredients.clear();
    _dosageValidations.clear();
    _totalWeight = 0.0;
    _warnings.clear();
    notifyListeners();
  }

  // Create the blend
  Future<bool> createBlend(int practitionerId) async {
    if (_selectedClient == null || _selectedBaseMix == null) {
      _errorMessage = 'Missing required information';
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _formulationService.createBlend(
        name: _blendName,
        baseMixId: _selectedBaseMix!.baseMixId,
        formulatedBy: practitionerId,
        formulatedFor: _selectedClient!.userId,
        description: _description,
        notes: 'Health Goals: ${_selectedHealthGoals.join(', ')}',
        ingredients: getBlendIngredients(),
      );
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create blend: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}