// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NavigationStore on _NavigationStore, Store {
  final _$currentTabIndexAtom = Atom(name: '_NavigationStore.currentTabIndex');

  @override
  int get currentTabIndex {
    _$currentTabIndexAtom.reportRead();
    return super.currentTabIndex;
  }

  @override
  set currentTabIndex(int value) {
    _$currentTabIndexAtom.reportWrite(value, super.currentTabIndex, () {
      super.currentTabIndex = value;
    });
  }

  final _$selectedSidebarIndexAtom =
      Atom(name: '_NavigationStore.selectedSidebarIndex');

  @override
  int get selectedSidebarIndex {
    _$selectedSidebarIndexAtom.reportRead();
    return super.selectedSidebarIndex;
  }

  @override
  set selectedSidebarIndex(int value) {
    _$selectedSidebarIndexAtom.reportWrite(value, super.selectedSidebarIndex,
        () {
      super.selectedSidebarIndex = value;
    });
  }

  final _$selectedAgreementTypeAtom =
      Atom(name: '_NavigationStore.selectedAgreementType');

  @override
  int get selectedAgreementType {
    _$selectedAgreementTypeAtom.reportRead();
    return super.selectedAgreementType;
  }

  @override
  set selectedAgreementType(int value) {
    _$selectedAgreementTypeAtom.reportWrite(value, super.selectedAgreementType,
        () {
      super.selectedAgreementType = value;
    });
  }

  final _$_NavigationStoreActionController =
      ActionController(name: '_NavigationStore');

  @override
  void selectTab(int index, BuildContext context) {
    final _$actionInfo = _$_NavigationStoreActionController.startAction(
        name: '_NavigationStore.selectTab');
    try {
      return super.selectTab(index, context);
    } finally {
      _$_NavigationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectSidebarEntry(int index) {
    final _$actionInfo = _$_NavigationStoreActionController.startAction(
        name: '_NavigationStore.selectSidebarEntry');
    try {
      return super.selectSidebarEntry(index);
    } finally {
      _$_NavigationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectAgreementRelatedNavigation(
      int agreementType, bool hasNext, String nextRoute) {
    final _$actionInfo = _$_NavigationStoreActionController.startAction(
        name: '_NavigationStore.selectAgreementRelatedNavigation');
    try {
      return super
          .selectAgreementRelatedNavigation(agreementType, hasNext, nextRoute);
    } finally {
      _$_NavigationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setServiceLocationParameters(ServiceLocationPlaces place,
      String pageTitle, int orderType, String buttonText) {
    final _$actionInfo = _$_NavigationStoreActionController.startAction(
        name: '_NavigationStore.setServiceLocationParameters');
    try {
      return super.setServiceLocationParameters(
          place, pageTitle, orderType, buttonText);
    } finally {
      _$_NavigationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentTabIndex: ${currentTabIndex},
selectedSidebarIndex: ${selectedSidebarIndex},
selectedAgreementType: ${selectedAgreementType}
    ''';
  }
}
