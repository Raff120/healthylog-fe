// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cookingGroupApi)
final cookingGroupApiProvider = CookingGroupApiProvider._();

final class CookingGroupApiProvider
    extends
        $FunctionalProvider<CookingGroupApi, CookingGroupApi, CookingGroupApi>
    with $Provider<CookingGroupApi> {
  CookingGroupApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cookingGroupApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cookingGroupApiHash();

  @$internal
  @override
  $ProviderElement<CookingGroupApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CookingGroupApi create(Ref ref) {
    return cookingGroupApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CookingGroupApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CookingGroupApi>(value),
    );
  }
}

String _$cookingGroupApiHash() => r'0501c778b08b7e9e5fef8ad5529b0eb5867c1639';

/// RG-3: il Gruppo dell'Utente autenticato. Un `RESOURCE_NOT_FOUND` (404)
/// significa assenza di Gruppo (8.1 interfaccia.md), non un errore da
/// segnalare — la schermata lo distingue leggendo il codice dell'errore.
/// Ricaricato dopo ogni azione che modifica composizione o denominazione
/// (`ref.invalidateSelf`, tramite `ref.invalidate` dai controller sotto).

@ProviderFor(CurrentCookingGroup)
final currentCookingGroupProvider = CurrentCookingGroupProvider._();

/// RG-3: il Gruppo dell'Utente autenticato. Un `RESOURCE_NOT_FOUND` (404)
/// significa assenza di Gruppo (8.1 interfaccia.md), non un errore da
/// segnalare — la schermata lo distingue leggendo il codice dell'errore.
/// Ricaricato dopo ogni azione che modifica composizione o denominazione
/// (`ref.invalidateSelf`, tramite `ref.invalidate` dai controller sotto).
final class CurrentCookingGroupProvider
    extends $AsyncNotifierProvider<CurrentCookingGroup, CookingGroup> {
  /// RG-3: il Gruppo dell'Utente autenticato. Un `RESOURCE_NOT_FOUND` (404)
  /// significa assenza di Gruppo (8.1 interfaccia.md), non un errore da
  /// segnalare — la schermata lo distingue leggendo il codice dell'errore.
  /// Ricaricato dopo ogni azione che modifica composizione o denominazione
  /// (`ref.invalidateSelf`, tramite `ref.invalidate` dai controller sotto).
  CurrentCookingGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCookingGroupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCookingGroupHash();

  @$internal
  @override
  CurrentCookingGroup create() => CurrentCookingGroup();
}

String _$currentCookingGroupHash() =>
    r'826c977a5d3251428af5971a647fc84a97c1e9be';

/// RG-3: il Gruppo dell'Utente autenticato. Un `RESOURCE_NOT_FOUND` (404)
/// significa assenza di Gruppo (8.1 interfaccia.md), non un errore da
/// segnalare — la schermata lo distingue leggendo il codice dell'errore.
/// Ricaricato dopo ogni azione che modifica composizione o denominazione
/// (`ref.invalidateSelf`, tramite `ref.invalidate` dai controller sotto).

abstract class _$CurrentCookingGroup extends $AsyncNotifier<CookingGroup> {
  FutureOr<CookingGroup> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CookingGroup>, CookingGroup>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>, CookingGroup>,
              AsyncValue<CookingGroup>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
/// Proprietario — la schermata non invoca questo provider per un
/// richiedente diverso, coerente con la verifica lato server.

@ProviderFor(GroupInviteCodes)
final groupInviteCodesProvider = GroupInviteCodesFamily._();

/// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
/// Proprietario — la schermata non invoca questo provider per un
/// richiedente diverso, coerente con la verifica lato server.
final class GroupInviteCodesProvider
    extends $AsyncNotifierProvider<GroupInviteCodes, List<InviteCode>> {
  /// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
  /// Proprietario — la schermata non invoca questo provider per un
  /// richiedente diverso, coerente con la verifica lato server.
  GroupInviteCodesProvider._({
    required GroupInviteCodesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupInviteCodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupInviteCodesHash();

  @override
  String toString() {
    return r'groupInviteCodesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GroupInviteCodes create() => GroupInviteCodes();

  @override
  bool operator ==(Object other) {
    return other is GroupInviteCodesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupInviteCodesHash() => r'80c5b23764e9bee92d5652c8ffaec41ea1a48035';

/// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
/// Proprietario — la schermata non invoca questo provider per un
/// richiedente diverso, coerente con la verifica lato server.

final class GroupInviteCodesFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupInviteCodes,
          AsyncValue<List<InviteCode>>,
          List<InviteCode>,
          FutureOr<List<InviteCode>>,
          String
        > {
  GroupInviteCodesFamily._()
    : super(
        retry: null,
        name: r'groupInviteCodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
  /// Proprietario — la schermata non invoca questo provider per un
  /// richiedente diverso, coerente con la verifica lato server.

  GroupInviteCodesProvider call(String groupId) =>
      GroupInviteCodesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupInviteCodesProvider';
}

/// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
/// Proprietario — la schermata non invoca questo provider per un
/// richiedente diverso, coerente con la verifica lato server.

abstract class _$GroupInviteCodes extends $AsyncNotifier<List<InviteCode>> {
  late final _$args = ref.$arg as String;
  String get groupId => _$args;

  FutureOr<List<InviteCode>> build(String groupId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<InviteCode>>, List<InviteCode>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<InviteCode>>, List<InviteCode>>,
              AsyncValue<List<InviteCode>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// GR-9: anteprima del codice inserito, senza consumarne l'utilizzo —
/// `autoDispose` di default: non ha senso conservarla oltre il foglio di
/// adesione che la richiede.

@ProviderFor(inviteCodePreview)
final inviteCodePreviewProvider = InviteCodePreviewFamily._();

/// GR-9: anteprima del codice inserito, senza consumarne l'utilizzo —
/// `autoDispose` di default: non ha senso conservarla oltre il foglio di
/// adesione che la richiede.

final class InviteCodePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<InviteCodePreview>,
          InviteCodePreview,
          FutureOr<InviteCodePreview>
        >
    with
        $FutureModifier<InviteCodePreview>,
        $FutureProvider<InviteCodePreview> {
  /// GR-9: anteprima del codice inserito, senza consumarne l'utilizzo —
  /// `autoDispose` di default: non ha senso conservarla oltre il foglio di
  /// adesione che la richiede.
  InviteCodePreviewProvider._({
    required InviteCodePreviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inviteCodePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inviteCodePreviewHash();

  @override
  String toString() {
    return r'inviteCodePreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<InviteCodePreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InviteCodePreview> create(Ref ref) {
    final argument = this.argument as String;
    return inviteCodePreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InviteCodePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inviteCodePreviewHash() => r'afb9698ad2e46cb286fe221e33b6bb1520ce30b7';

/// GR-9: anteprima del codice inserito, senza consumarne l'utilizzo —
/// `autoDispose` di default: non ha senso conservarla oltre il foglio di
/// adesione che la richiede.

final class InviteCodePreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<InviteCodePreview>, String> {
  InviteCodePreviewFamily._()
    : super(
        retry: null,
        name: r'inviteCodePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// GR-9: anteprima del codice inserito, senza consumarne l'utilizzo —
  /// `autoDispose` di default: non ha senso conservarla oltre il foglio di
  /// adesione che la richiede.

  InviteCodePreviewProvider call(String code) =>
      InviteCodePreviewProvider._(argument: code, from: this);

  @override
  String toString() => r'inviteCodePreviewProvider';
}

/// GE-1, GE-2: creazione del Gruppo.

@ProviderFor(CreateCookingGroupController)
final createCookingGroupControllerProvider =
    CreateCookingGroupControllerProvider._();

/// GE-1, GE-2: creazione del Gruppo.
final class CreateCookingGroupControllerProvider
    extends
        $NotifierProvider<
          CreateCookingGroupController,
          AsyncValue<CookingGroup>?
        > {
  /// GE-1, GE-2: creazione del Gruppo.
  CreateCookingGroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCookingGroupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCookingGroupControllerHash();

  @$internal
  @override
  CreateCookingGroupController create() => CreateCookingGroupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CookingGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CookingGroup>?>(value),
    );
  }
}

String _$createCookingGroupControllerHash() =>
    r'8782fa41142e3ec6576e55d9aaac42fd4e1ee68f';

/// GE-1, GE-2: creazione del Gruppo.

abstract class _$CreateCookingGroupController
    extends $Notifier<AsyncValue<CookingGroup>?> {
  AsyncValue<CookingGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>,
              AsyncValue<CookingGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GR-9, GR-10, GR-11: adesione tramite codice, dopo la conferma esplicita
/// raccolta dal foglio di adesione (l'anteprima l'ha già mostrata).

@ProviderFor(JoinCookingGroupController)
final joinCookingGroupControllerProvider =
    JoinCookingGroupControllerProvider._();

/// GR-9, GR-10, GR-11: adesione tramite codice, dopo la conferma esplicita
/// raccolta dal foglio di adesione (l'anteprima l'ha già mostrata).
final class JoinCookingGroupControllerProvider
    extends
        $NotifierProvider<
          JoinCookingGroupController,
          AsyncValue<CookingGroup>?
        > {
  /// GR-9, GR-10, GR-11: adesione tramite codice, dopo la conferma esplicita
  /// raccolta dal foglio di adesione (l'anteprima l'ha già mostrata).
  JoinCookingGroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinCookingGroupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinCookingGroupControllerHash();

  @$internal
  @override
  JoinCookingGroupController create() => JoinCookingGroupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CookingGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CookingGroup>?>(value),
    );
  }
}

String _$joinCookingGroupControllerHash() =>
    r'4504a28d4cf4754aedd51a62205ff1a58dd6168b';

/// GR-9, GR-10, GR-11: adesione tramite codice, dopo la conferma esplicita
/// raccolta dal foglio di adesione (l'anteprima l'ha già mostrata).

abstract class _$JoinCookingGroupController
    extends $Notifier<AsyncValue<CookingGroup>?> {
  AsyncValue<CookingGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>,
              AsyncValue<CookingGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GE-12, GR-1: modifica della denominazione.

@ProviderFor(RenameCookingGroupController)
final renameCookingGroupControllerProvider =
    RenameCookingGroupControllerProvider._();

/// GE-12, GR-1: modifica della denominazione.
final class RenameCookingGroupControllerProvider
    extends
        $NotifierProvider<
          RenameCookingGroupController,
          AsyncValue<CookingGroup>?
        > {
  /// GE-12, GR-1: modifica della denominazione.
  RenameCookingGroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'renameCookingGroupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$renameCookingGroupControllerHash();

  @$internal
  @override
  RenameCookingGroupController create() => RenameCookingGroupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CookingGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CookingGroup>?>(value),
    );
  }
}

String _$renameCookingGroupControllerHash() =>
    r'4c2665774d2e5c1c93632207696cfa12c7631b65';

/// GE-12, GR-1: modifica della denominazione.

abstract class _$RenameCookingGroupController
    extends $Notifier<AsyncValue<CookingGroup>?> {
  AsyncValue<CookingGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>,
              AsyncValue<CookingGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GE-12, UT-14: uscita volontaria — a scioglimento avvenuto o meno, il
/// Gruppo dell'Utente non è più quello di prima (`invalidate`).

@ProviderFor(LeaveCookingGroupController)
final leaveCookingGroupControllerProvider =
    LeaveCookingGroupControllerProvider._();

/// GE-12, UT-14: uscita volontaria — a scioglimento avvenuto o meno, il
/// Gruppo dell'Utente non è più quello di prima (`invalidate`).
final class LeaveCookingGroupControllerProvider
    extends $NotifierProvider<LeaveCookingGroupController, AsyncValue<void>?> {
  /// GE-12, UT-14: uscita volontaria — a scioglimento avvenuto o meno, il
  /// Gruppo dell'Utente non è più quello di prima (`invalidate`).
  LeaveCookingGroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveCookingGroupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveCookingGroupControllerHash();

  @$internal
  @override
  LeaveCookingGroupController create() => LeaveCookingGroupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$leaveCookingGroupControllerHash() =>
    r'0177448f3bb5d7d2071a5ba33d997579eb854745';

/// GE-12, UT-14: uscita volontaria — a scioglimento avvenuto o meno, il
/// Gruppo dell'Utente non è più quello di prima (`invalidate`).

abstract class _$LeaveCookingGroupController
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

/// GE-12: scioglimento esplicito, riservato al Proprietario.

@ProviderFor(DissolveCookingGroupController)
final dissolveCookingGroupControllerProvider =
    DissolveCookingGroupControllerProvider._();

/// GE-12: scioglimento esplicito, riservato al Proprietario.
final class DissolveCookingGroupControllerProvider
    extends
        $NotifierProvider<DissolveCookingGroupController, AsyncValue<void>?> {
  /// GE-12: scioglimento esplicito, riservato al Proprietario.
  DissolveCookingGroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dissolveCookingGroupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dissolveCookingGroupControllerHash();

  @$internal
  @override
  DissolveCookingGroupController create() => DissolveCookingGroupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$dissolveCookingGroupControllerHash() =>
    r'94ba29273ff6b026ec5d871b621f8569b8ee8a28';

/// GE-12: scioglimento esplicito, riservato al Proprietario.

abstract class _$DissolveCookingGroupController
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

/// GE-6: rimozione di un membro, riservata al Proprietario.

@ProviderFor(RemoveGroupMemberController)
final removeGroupMemberControllerProvider =
    RemoveGroupMemberControllerProvider._();

/// GE-6: rimozione di un membro, riservata al Proprietario.
final class RemoveGroupMemberControllerProvider
    extends
        $NotifierProvider<
          RemoveGroupMemberController,
          AsyncValue<CookingGroup>?
        > {
  /// GE-6: rimozione di un membro, riservata al Proprietario.
  RemoveGroupMemberControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeGroupMemberControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeGroupMemberControllerHash();

  @$internal
  @override
  RemoveGroupMemberController create() => RemoveGroupMemberController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CookingGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CookingGroup>?>(value),
    );
  }
}

String _$removeGroupMemberControllerHash() =>
    r'32e03fd77dc73f53331800dd9b9fd60036cccc42';

/// GE-6: rimozione di un membro, riservata al Proprietario.

abstract class _$RemoveGroupMemberController
    extends $Notifier<AsyncValue<CookingGroup>?> {
  AsyncValue<CookingGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>,
              AsyncValue<CookingGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GE-7, GE-8: promozione a Cuoco o revoca del privilegio.

@ProviderFor(UpdateGroupMemberController)
final updateGroupMemberControllerProvider =
    UpdateGroupMemberControllerProvider._();

/// GE-7, GE-8: promozione a Cuoco o revoca del privilegio.
final class UpdateGroupMemberControllerProvider
    extends
        $NotifierProvider<
          UpdateGroupMemberController,
          AsyncValue<CookingGroup>?
        > {
  /// GE-7, GE-8: promozione a Cuoco o revoca del privilegio.
  UpdateGroupMemberControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateGroupMemberControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateGroupMemberControllerHash();

  @$internal
  @override
  UpdateGroupMemberController create() => UpdateGroupMemberController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CookingGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CookingGroup>?>(value),
    );
  }
}

String _$updateGroupMemberControllerHash() =>
    r'a79e430cdd453a8bfb2484a0b06a25dd2d7fee65';

/// GE-7, GE-8: promozione a Cuoco o revoca del privilegio.

abstract class _$UpdateGroupMemberController
    extends $Notifier<AsyncValue<CookingGroup>?> {
  AsyncValue<CookingGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>,
              AsyncValue<CookingGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GE-9, GR-15: trasferimento volontario della proprietà.

@ProviderFor(TransferGroupOwnershipController)
final transferGroupOwnershipControllerProvider =
    TransferGroupOwnershipControllerProvider._();

/// GE-9, GR-15: trasferimento volontario della proprietà.
final class TransferGroupOwnershipControllerProvider
    extends
        $NotifierProvider<
          TransferGroupOwnershipController,
          AsyncValue<CookingGroup>?
        > {
  /// GE-9, GR-15: trasferimento volontario della proprietà.
  TransferGroupOwnershipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferGroupOwnershipControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferGroupOwnershipControllerHash();

  @$internal
  @override
  TransferGroupOwnershipController create() =>
      TransferGroupOwnershipController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CookingGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CookingGroup>?>(value),
    );
  }
}

String _$transferGroupOwnershipControllerHash() =>
    r'7896131f7fc02a4572cf0c95c26d437ea5c25d4d';

/// GE-9, GR-15: trasferimento volontario della proprietà.

abstract class _$TransferGroupOwnershipController
    extends $Notifier<AsyncValue<CookingGroup>?> {
  AsyncValue<CookingGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CookingGroup>?, AsyncValue<CookingGroup>?>,
              AsyncValue<CookingGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GR-7, GR-8: generazione di un nuovo codice — la stessa chiamata serve
/// sia la prima generazione sia la rigenerazione (invalida quello
/// precedente lato server).

@ProviderFor(GenerateInviteCodeController)
final generateInviteCodeControllerProvider =
    GenerateInviteCodeControllerProvider._();

/// GR-7, GR-8: generazione di un nuovo codice — la stessa chiamata serve
/// sia la prima generazione sia la rigenerazione (invalida quello
/// precedente lato server).
final class GenerateInviteCodeControllerProvider
    extends
        $NotifierProvider<
          GenerateInviteCodeController,
          AsyncValue<InviteCode>?
        > {
  /// GR-7, GR-8: generazione di un nuovo codice — la stessa chiamata serve
  /// sia la prima generazione sia la rigenerazione (invalida quello
  /// precedente lato server).
  GenerateInviteCodeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateInviteCodeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateInviteCodeControllerHash();

  @$internal
  @override
  GenerateInviteCodeController create() => GenerateInviteCodeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<InviteCode>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<InviteCode>?>(value),
    );
  }
}

String _$generateInviteCodeControllerHash() =>
    r'd147fb479a84ef0628eef890384f58615dff4617';

/// GR-7, GR-8: generazione di un nuovo codice — la stessa chiamata serve
/// sia la prima generazione sia la rigenerazione (invalida quello
/// precedente lato server).

abstract class _$GenerateInviteCodeController
    extends $Notifier<AsyncValue<InviteCode>?> {
  AsyncValue<InviteCode>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<InviteCode>?, AsyncValue<InviteCode>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InviteCode>?, AsyncValue<InviteCode>?>,
              AsyncValue<InviteCode>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// GR-7: revoca esplicita, senza generarne uno nuovo.

@ProviderFor(RevokeInviteCodeController)
final revokeInviteCodeControllerProvider =
    RevokeInviteCodeControllerProvider._();

/// GR-7: revoca esplicita, senza generarne uno nuovo.
final class RevokeInviteCodeControllerProvider
    extends $NotifierProvider<RevokeInviteCodeController, AsyncValue<void>?> {
  /// GR-7: revoca esplicita, senza generarne uno nuovo.
  RevokeInviteCodeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revokeInviteCodeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revokeInviteCodeControllerHash();

  @$internal
  @override
  RevokeInviteCodeController create() => RevokeInviteCodeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$revokeInviteCodeControllerHash() =>
    r'bc6cc1b73ab50b5f6d443c05c0b8765e13fde843';

/// GR-7: revoca esplicita, senza generarne uno nuovo.

abstract class _$RevokeInviteCodeController
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
