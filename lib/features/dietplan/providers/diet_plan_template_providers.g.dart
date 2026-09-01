// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_template_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dietPlanTemplateApi)
final dietPlanTemplateApiProvider = DietPlanTemplateApiProvider._();

final class DietPlanTemplateApiProvider
    extends
        $FunctionalProvider<
          DietPlanTemplateApi,
          DietPlanTemplateApi,
          DietPlanTemplateApi
        >
    with $Provider<DietPlanTemplateApi> {
  DietPlanTemplateApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dietPlanTemplateApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dietPlanTemplateApiHash();

  @$internal
  @override
  $ProviderElement<DietPlanTemplateApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DietPlanTemplateApi create(Ref ref) {
    return dietPlanTemplateApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DietPlanTemplateApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DietPlanTemplateApi>(value),
    );
  }
}

String _$dietPlanTemplateApiHash() =>
    r'8504497cd650e8c1e45aae7cd67a4fd130633635';

/// Elenco dei template di proprietà di chi opera (CT-2, CT-3), da
/// ricaricare dopo ogni creazione o eliminazione (`ref.invalidateSelf`).

@ProviderFor(DietPlanTemplateList)
final dietPlanTemplateListProvider = DietPlanTemplateListProvider._();

/// Elenco dei template di proprietà di chi opera (CT-2, CT-3), da
/// ricaricare dopo ogni creazione o eliminazione (`ref.invalidateSelf`).
final class DietPlanTemplateListProvider
    extends
        $AsyncNotifierProvider<
          DietPlanTemplateList,
          List<DietPlanTemplateSummary>
        > {
  /// Elenco dei template di proprietà di chi opera (CT-2, CT-3), da
  /// ricaricare dopo ogni creazione o eliminazione (`ref.invalidateSelf`).
  DietPlanTemplateListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dietPlanTemplateListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dietPlanTemplateListHash();

  @$internal
  @override
  DietPlanTemplateList create() => DietPlanTemplateList();
}

String _$dietPlanTemplateListHash() =>
    r'd060107d6c70a7224e4fadb18f1541814ebd6f48';

/// Elenco dei template di proprietà di chi opera (CT-2, CT-3), da
/// ricaricare dopo ogni creazione o eliminazione (`ref.invalidateSelf`).

abstract class _$DietPlanTemplateList
    extends $AsyncNotifier<List<DietPlanTemplateSummary>> {
  FutureOr<List<DietPlanTemplateSummary>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<DietPlanTemplateSummary>>,
              List<DietPlanTemplateSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DietPlanTemplateSummary>>,
                List<DietPlanTemplateSummary>
              >,
              AsyncValue<List<DietPlanTemplateSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Creazione del template (TP-4, TP-7): nessuno stato da ricaricare al
/// primo utilizzo, sul modello di [CreateDietPlanController].

@ProviderFor(CreateDietPlanTemplateController)
final createDietPlanTemplateControllerProvider =
    CreateDietPlanTemplateControllerProvider._();

/// Creazione del template (TP-4, TP-7): nessuno stato da ricaricare al
/// primo utilizzo, sul modello di [CreateDietPlanController].
final class CreateDietPlanTemplateControllerProvider
    extends
        $NotifierProvider<
          CreateDietPlanTemplateController,
          AsyncValue<DietPlanTemplate>?
        > {
  /// Creazione del template (TP-4, TP-7): nessuno stato da ricaricare al
  /// primo utilizzo, sul modello di [CreateDietPlanController].
  CreateDietPlanTemplateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDietPlanTemplateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDietPlanTemplateControllerHash();

  @$internal
  @override
  CreateDietPlanTemplateController create() =>
      CreateDietPlanTemplateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<DietPlanTemplate>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<DietPlanTemplate>?>(
        value,
      ),
    );
  }
}

String _$createDietPlanTemplateControllerHash() =>
    r'c4e9a032f3c7d7ea14268999861258ead0da31fd';

/// Creazione del template (TP-4, TP-7): nessuno stato da ricaricare al
/// primo utilizzo, sul modello di [CreateDietPlanController].

abstract class _$CreateDietPlanTemplateController
    extends $Notifier<AsyncValue<DietPlanTemplate>?> {
  AsyncValue<DietPlanTemplate>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DietPlanTemplate>?,
              AsyncValue<DietPlanTemplate>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DietPlanTemplate>?,
                AsyncValue<DietPlanTemplate>?
              >,
              AsyncValue<DietPlanTemplate>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
/// nessun metodo di scrittura su questo notifier.

@ProviderFor(DietPlanTemplatePreview)
final dietPlanTemplatePreviewProvider = DietPlanTemplatePreviewFamily._();

/// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
/// nessun metodo di scrittura su questo notifier.
final class DietPlanTemplatePreviewProvider
    extends $AsyncNotifierProvider<DietPlanTemplatePreview, DietPlanTemplate> {
  /// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
  /// nessun metodo di scrittura su questo notifier.
  DietPlanTemplatePreviewProvider._({
    required DietPlanTemplatePreviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dietPlanTemplatePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dietPlanTemplatePreviewHash();

  @override
  String toString() {
    return r'dietPlanTemplatePreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DietPlanTemplatePreview create() => DietPlanTemplatePreview();

  @override
  bool operator ==(Object other) {
    return other is DietPlanTemplatePreviewProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dietPlanTemplatePreviewHash() =>
    r'01492f9f0a62d0f06665ea3fd7b5af99d791a44a';

/// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
/// nessun metodo di scrittura su questo notifier.

final class DietPlanTemplatePreviewFamily extends $Family
    with
        $ClassFamilyOverride<
          DietPlanTemplatePreview,
          AsyncValue<DietPlanTemplate>,
          DietPlanTemplate,
          FutureOr<DietPlanTemplate>,
          String
        > {
  DietPlanTemplatePreviewFamily._()
    : super(
        retry: null,
        name: r'dietPlanTemplatePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
  /// nessun metodo di scrittura su questo notifier.

  DietPlanTemplatePreviewProvider call(String templateId) =>
      DietPlanTemplatePreviewProvider._(argument: templateId, from: this);

  @override
  String toString() => r'dietPlanTemplatePreviewProvider';
}

/// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
/// nessun metodo di scrittura su questo notifier.

abstract class _$DietPlanTemplatePreview
    extends $AsyncNotifier<DietPlanTemplate> {
  late final _$args = ref.$arg as String;
  String get templateId => _$args;

  FutureOr<DietPlanTemplate> build(String templateId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DietPlanTemplate>, DietPlanTemplate>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DietPlanTemplate>, DietPlanTemplate>,
              AsyncValue<DietPlanTemplate>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Template in redazione (TP-12): caricato per `templateId` al primo
/// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
/// modello di [DietPlanScheduleController].

@ProviderFor(DietPlanTemplateScheduleController)
final dietPlanTemplateScheduleControllerProvider =
    DietPlanTemplateScheduleControllerFamily._();

/// Template in redazione (TP-12): caricato per `templateId` al primo
/// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
/// modello di [DietPlanScheduleController].
final class DietPlanTemplateScheduleControllerProvider
    extends
        $AsyncNotifierProvider<
          DietPlanTemplateScheduleController,
          DietPlanTemplate
        > {
  /// Template in redazione (TP-12): caricato per `templateId` al primo
  /// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
  /// modello di [DietPlanScheduleController].
  DietPlanTemplateScheduleControllerProvider._({
    required DietPlanTemplateScheduleControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dietPlanTemplateScheduleControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$dietPlanTemplateScheduleControllerHash();

  @override
  String toString() {
    return r'dietPlanTemplateScheduleControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DietPlanTemplateScheduleController create() =>
      DietPlanTemplateScheduleController();

  @override
  bool operator ==(Object other) {
    return other is DietPlanTemplateScheduleControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dietPlanTemplateScheduleControllerHash() =>
    r'66bd5e6c48b713cfdd67bbdccd8a1795a57cc71a';

/// Template in redazione (TP-12): caricato per `templateId` al primo
/// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
/// modello di [DietPlanScheduleController].

final class DietPlanTemplateScheduleControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DietPlanTemplateScheduleController,
          AsyncValue<DietPlanTemplate>,
          DietPlanTemplate,
          FutureOr<DietPlanTemplate>,
          String
        > {
  DietPlanTemplateScheduleControllerFamily._()
    : super(
        retry: null,
        name: r'dietPlanTemplateScheduleControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Template in redazione (TP-12): caricato per `templateId` al primo
  /// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
  /// modello di [DietPlanScheduleController].

  DietPlanTemplateScheduleControllerProvider call(String templateId) =>
      DietPlanTemplateScheduleControllerProvider._(
        argument: templateId,
        from: this,
      );

  @override
  String toString() => r'dietPlanTemplateScheduleControllerProvider';
}

/// Template in redazione (TP-12): caricato per `templateId` al primo
/// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
/// modello di [DietPlanScheduleController].

abstract class _$DietPlanTemplateScheduleController
    extends $AsyncNotifier<DietPlanTemplate> {
  late final _$args = ref.$arg as String;
  String get templateId => _$args;

  FutureOr<DietPlanTemplate> build(String templateId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DietPlanTemplate>, DietPlanTemplate>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DietPlanTemplate>, DietPlanTemplate>,
              AsyncValue<DietPlanTemplate>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Rinomina e modifica della descrizione (TP-12).

@ProviderFor(UpdateDietPlanTemplateController)
final updateDietPlanTemplateControllerProvider =
    UpdateDietPlanTemplateControllerProvider._();

/// Rinomina e modifica della descrizione (TP-12).
final class UpdateDietPlanTemplateControllerProvider
    extends
        $NotifierProvider<
          UpdateDietPlanTemplateController,
          AsyncValue<DietPlanTemplate>?
        > {
  /// Rinomina e modifica della descrizione (TP-12).
  UpdateDietPlanTemplateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDietPlanTemplateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDietPlanTemplateControllerHash();

  @$internal
  @override
  UpdateDietPlanTemplateController create() =>
      UpdateDietPlanTemplateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<DietPlanTemplate>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<DietPlanTemplate>?>(
        value,
      ),
    );
  }
}

String _$updateDietPlanTemplateControllerHash() =>
    r'db0caaf659519b76159b32338faf048cf5c51fb1';

/// Rinomina e modifica della descrizione (TP-12).

abstract class _$UpdateDietPlanTemplateController
    extends $Notifier<AsyncValue<DietPlanTemplate>?> {
  AsyncValue<DietPlanTemplate>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DietPlanTemplate>?,
              AsyncValue<DietPlanTemplate>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DietPlanTemplate>?,
                AsyncValue<DietPlanTemplate>?
              >,
              AsyncValue<DietPlanTemplate>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Eliminazione del template (TP-12): nessun effetto sui piani già
/// derivati (CT-16).

@ProviderFor(DeleteDietPlanTemplateController)
final deleteDietPlanTemplateControllerProvider =
    DeleteDietPlanTemplateControllerProvider._();

/// Eliminazione del template (TP-12): nessun effetto sui piani già
/// derivati (CT-16).
final class DeleteDietPlanTemplateControllerProvider
    extends
        $NotifierProvider<DeleteDietPlanTemplateController, AsyncValue<void>?> {
  /// Eliminazione del template (TP-12): nessun effetto sui piani già
  /// derivati (CT-16).
  DeleteDietPlanTemplateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteDietPlanTemplateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteDietPlanTemplateControllerHash();

  @$internal
  @override
  DeleteDietPlanTemplateController create() =>
      DeleteDietPlanTemplateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$deleteDietPlanTemplateControllerHash() =>
    r'0f4953578dd1a6d007ac70ebe0e3409450aeca71';

/// Eliminazione del template (TP-12): nessun effetto sui piani già
/// derivati (CT-16).

abstract class _$DeleteDietPlanTemplateController
    extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Salvataggio del piano come template (TP-5, CD-18), dalla redazione del
/// piano: nessuno stato da ricaricare al primo utilizzo.

@ProviderFor(SaveDietPlanAsTemplateController)
final saveDietPlanAsTemplateControllerProvider =
    SaveDietPlanAsTemplateControllerProvider._();

/// Salvataggio del piano come template (TP-5, CD-18), dalla redazione del
/// piano: nessuno stato da ricaricare al primo utilizzo.
final class SaveDietPlanAsTemplateControllerProvider
    extends
        $NotifierProvider<
          SaveDietPlanAsTemplateController,
          AsyncValue<DietPlanTemplate>?
        > {
  /// Salvataggio del piano come template (TP-5, CD-18), dalla redazione del
  /// piano: nessuno stato da ricaricare al primo utilizzo.
  SaveDietPlanAsTemplateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDietPlanAsTemplateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDietPlanAsTemplateControllerHash();

  @$internal
  @override
  SaveDietPlanAsTemplateController create() =>
      SaveDietPlanAsTemplateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<DietPlanTemplate>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<DietPlanTemplate>?>(
        value,
      ),
    );
  }
}

String _$saveDietPlanAsTemplateControllerHash() =>
    r'd7ad309cb6ad0fece8decda5c2239a3d5116827d';

/// Salvataggio del piano come template (TP-5, CD-18), dalla redazione del
/// piano: nessuno stato da ricaricare al primo utilizzo.

abstract class _$SaveDietPlanAsTemplateController
    extends $Notifier<AsyncValue<DietPlanTemplate>?> {
  AsyncValue<DietPlanTemplate>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DietPlanTemplate>?,
              AsyncValue<DietPlanTemplate>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DietPlanTemplate>?,
                AsyncValue<DietPlanTemplate>?
              >,
              AsyncValue<DietPlanTemplate>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
