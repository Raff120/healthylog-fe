/// Elementi di slot nella forma JSON delle risposte (CO-7bis), per le prove
/// che simulano il servizio.
library;

Map<String, dynamic> foodJson(
  String name, {
  num? quantity,
  String? unit,
  List<Map<String, dynamic>> alternatives = const [],
}) => {
      'itemId': 'item-${name.hashCode}',
      'kind': 'FOOD',
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'recipeText': null,
      'alternatives': alternatives,
    };

Map<String, dynamic> recipeJson(
  String name, {
  String? recipeText,
  List<Map<String, dynamic>> alternatives = const [],
}) => {
      'itemId': 'item-${name.hashCode}',
      'kind': 'RECIPE',
      'name': name,
      'quantity': null,
      'unit': null,
      'recipeText': recipeText,
      'alternatives': alternatives,
    };

Map<String, dynamic> alternativeFoodJson(String name, {num? quantity, String? unit}) => {
      'kind': 'FOOD',
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'recipeText': null,
    };

Map<String, dynamic> alternativeRecipeJson(String name, {String? recipeText}) => {
      'kind': 'RECIPE',
      'name': name,
      'quantity': null,
      'unit': null,
      'recipeText': recipeText,
    };

/// Gli elementi di uno slot descritto come lo si descriveva col testo libero:
/// un alimento con la denominazione, ed eventualmente una ricetta. Serve alle
/// prove che quel contenuto lo davano per scontato.
List<Map<String, dynamic>> itemsJson(String? content, {String? recipeName, String? recipeText}) => [
      if (content != null) foodJson(content),
      if (recipeName != null) recipeJson(recipeName, recipeText: recipeText),
    ];
