/// Elementi del contenuto di uno slot (GG-11, GG-12, CO-7bis). Rispecchiano
/// `SlotItemResponse` e `SlotItemAlternativeResponse` sul backend.
///
/// Il genere e l'unità non sono enumerativi puri ma **codici conservati**: il
/// valore ricevuto è tenuto com'è e riscritto invariato. VR-10 vorrebbe che
/// un valore sconosciuto facesse omettere l'elemento, ma qui l'omissione lo
/// esporrebbe alla cancellazione al primo `PUT` dello schema, che rimanda
/// l'elenco intero (CO-7quater, vedi decisioni.md). Un client vecchio davanti
/// a un'unità nuova mostra dunque il codice così com'è, e non perde nulla.
library;

/// Genere di un elemento (GG-12).
enum SlotItemKind {
  food,
  recipe;

  String toJson() => switch (this) {
        SlotItemKind.food => 'FOOD',
        SlotItemKind.recipe => 'RECIPE',
      };

  static SlotItemKind? tryFromJson(String value) => switch (value) {
        'FOOD' => SlotItemKind.food,
        'RECIPE' => SlotItemKind.recipe,
        _ => null,
      };
}

/// Unità della quantità (GG-22, CO-7ter). L'ordine di dichiarazione è
/// l'ordine di presentazione, come nell'enumerativo del backend: le unità più
/// frequenti per prime.
enum QuantityUnit {
  gram,
  milliliter,
  piece,
  slice,
  tablespoon,
  teaspoon,
  portion,
  cup,
  glass,
  jar,
  can,
  smallCup,
  handful;

  String toJson() => switch (this) {
        QuantityUnit.gram => 'GRAM',
        QuantityUnit.milliliter => 'MILLILITER',
        QuantityUnit.piece => 'PIECE',
        QuantityUnit.slice => 'SLICE',
        QuantityUnit.tablespoon => 'TABLESPOON',
        QuantityUnit.teaspoon => 'TEASPOON',
        QuantityUnit.portion => 'PORTION',
        QuantityUnit.cup => 'CUP',
        QuantityUnit.glass => 'GLASS',
        QuantityUnit.jar => 'JAR',
        QuantityUnit.can => 'CAN',
        QuantityUnit.smallCup => 'SMALL_CUP',
        QuantityUnit.handful => 'HANDFUL',
      };

  /// `null` per un'unità che questa versione del client non conosce: chi la
  /// riceve ne conserva il codice e lo presenta così com'è (CO-7quater).
  static QuantityUnit? tryFromJson(String? value) => switch (value) {
        'GRAM' => QuantityUnit.gram,
        'MILLILITER' => QuantityUnit.milliliter,
        'PIECE' => QuantityUnit.piece,
        'SLICE' => QuantityUnit.slice,
        'TABLESPOON' => QuantityUnit.tablespoon,
        'TEASPOON' => QuantityUnit.teaspoon,
        'PORTION' => QuantityUnit.portion,
        'CUP' => QuantityUnit.cup,
        'GLASS' => QuantityUnit.glass,
        'JAR' => QuantityUnit.jar,
        'CAN' => QuantityUnit.can,
        'SMALL_CUP' => QuantityUnit.smallCup,
        'HANDFUL' => QuantityUnit.handful,
        _ => null,
      };
}

/// Alternativa a un elemento (GG-25): stessa composizione di un elemento, ma
/// priva di identificativo e di alternative proprie (CO-7bis). Solo
/// informativa: il sistema non registra quale sia stata consumata (GG-26).
class SlotItemAlternative {
  const SlotItemAlternative({
    required this.kindCode,
    required this.name,
    this.quantity,
    this.unitCode,
    this.recipeText,
  });

  factory SlotItemAlternative.fromJson(Map<String, dynamic> json) => SlotItemAlternative(
        kindCode: json['kind'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as num?,
        unitCode: json['unit'] as String?,
        recipeText: json['recipeText'] as String?,
      );

  final String kindCode;
  final String name;
  final num? quantity;
  final String? unitCode;
  final String? recipeText;

  SlotItemKind? get kind => SlotItemKind.tryFromJson(kindCode);

  QuantityUnit? get unit => QuantityUnit.tryFromJson(unitCode);

  bool get isRecipe => kind == SlotItemKind.recipe;

  Map<String, dynamic> toJson() => {
        'kind': kindCode,
        'name': name,
        'quantity': quantity,
        'unit': unitCode,
        'recipeText': recipeText,
      };

  SlotItemAlternative copyWith({
    String? kindCode,
    String? name,
    num? quantity,
    String? unitCode,
    String? recipeText,
    bool clearQuantity = false,
    bool clearRecipeText = false,
  }) =>
      SlotItemAlternative(
        kindCode: kindCode ?? this.kindCode,
        name: name ?? this.name,
        quantity: clearQuantity ? null : quantity ?? this.quantity,
        unitCode: clearQuantity ? null : unitCode ?? this.unitCode,
        recipeText: clearRecipeText ? null : recipeText ?? this.recipeText,
      );
}

/// Elemento del contenuto di uno slot (GG-11). L'ordine è quello dell'elenco
/// che lo contiene (GG-21).
class SlotItem {
  const SlotItem({
    required this.itemId,
    required this.kindCode,
    required this.name,
    this.quantity,
    this.unitCode,
    this.recipeText,
    this.alternatives = const [],
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) => SlotItem(
        itemId: json['itemId'] as String?,
        kindCode: json['kind'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as num?,
        unitCode: json['unit'] as String?,
        recipeText: json['recipeText'] as String?,
        alternatives: ((json['alternatives'] as List?) ?? const [])
            .map((e) => SlotItemAlternative.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// `null` per un elemento appena aggiunto in redazione: l'identificativo lo
  /// assegna il sistema (CO-7bis).
  final String? itemId;
  final String kindCode;
  final String name;
  final num? quantity;
  final String? unitCode;
  final String? recipeText;
  final List<SlotItemAlternative> alternatives;

  SlotItemKind? get kind => SlotItemKind.tryFromJson(kindCode);

  QuantityUnit? get unit => QuantityUnit.tryFromJson(unitCode);

  bool get isRecipe => kind == SlotItemKind.recipe;

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'kind': kindCode,
        'name': name,
        'quantity': quantity,
        'unit': unitCode,
        'recipeText': recipeText,
        'alternatives': alternatives.map((e) => e.toJson()).toList(),
      };

  SlotItem copyWith({
    String? itemId,
    String? kindCode,
    String? name,
    num? quantity,
    String? unitCode,
    String? recipeText,
    List<SlotItemAlternative>? alternatives,
    bool clearQuantity = false,
    bool clearRecipeText = false,
  }) =>
      SlotItem(
        itemId: itemId ?? this.itemId,
        kindCode: kindCode ?? this.kindCode,
        name: name ?? this.name,
        quantity: clearQuantity ? null : quantity ?? this.quantity,
        unitCode: clearQuantity ? null : unitCode ?? this.unitCode,
        recipeText: clearRecipeText ? null : recipeText ?? this.recipeText,
        alternatives: alternatives ?? this.alternatives,
      );
}

/// Gli elementi di uno slot, nella forma in cui giungono dalle risposte.
List<SlotItem> slotItemsFromJson(dynamic value) => ((value as List?) ?? const [])
    .map((e) => SlotItem.fromJson(e as Map<String, dynamic>))
    .toList();
