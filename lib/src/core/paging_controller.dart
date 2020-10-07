import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/model/paging_state.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';

typedef PageRequestListener<PageKeyType> = void Function(
  PageKeyType pageKey,
);

typedef PagingStatusListener = void Function(
  PagingStatus status,
);

/// A controller for a paged widget.
///
/// If you modify the [itemList], [error] or [nextPageKey] properties, the
/// paged widget will be notified and will update itself appropriately.
///
/// The [itemList], [error] or [nextPageKey] properties can be set from within
/// a listener added to this controller. If more than one property need to be
/// changed then the controller's [value] should be set instead.
///
/// This object should generally have a lifetime longer than the widgets
/// itself; it should be reused each time a paged widget constructor is called.
class PagingController<PageKeyType, ItemType>
    extends ValueNotifier<PagingState<PageKeyType, ItemType>> {
  PagingController({
    @required this.firstPageKey,
    this.invisibleItemsThreshold,
  }) : super(
          PagingState<PageKeyType, ItemType>(nextPageKey: firstPageKey),
        );

  ObserverList<PagingStatusListener> _statusListeners =
      ObserverList<PagingStatusListener>();

  ObserverList<PageRequestListener<PageKeyType>> _pageRequestListeners =
      ObserverList<PageRequestListener<PageKeyType>>();

  /// The number of remaining invisible items that should trigger a new fetch.
  final int invisibleItemsThreshold;

  /// The key for the first page to be fetched.
  final PageKeyType firstPageKey;

  /// List with all items loaded so far. Initially `null`.
  List<ItemType> get itemList => value.itemList;
  set itemList(List<ItemType> newItemList) {
    value = PagingState<PageKeyType, ItemType>(
      error: error,
      itemList: newItemList,
      nextPageKey: nextPageKey,
    );
  }

  /// The current error, if any. Initially `null`.
  dynamic get error => value.error;
  set error(dynamic newError) {
    value = PagingState<PageKeyType, ItemType>(
      error: newError,
      itemList: itemList,
      nextPageKey: nextPageKey,
    );
  }

  /// The key for the next page to be fetched.
  ///
  /// Initialized with the same value as [firstPageKey], received in the
  /// constructor.
  PageKeyType get nextPageKey => value.nextPageKey;
  set nextPageKey(PageKeyType newNextPageKey) {
    value = PagingState<PageKeyType, ItemType>(
      error: error,
      itemList: itemList,
      nextPageKey: newNextPageKey,
    );
  }

  /// Appends [newItems] to the previously loaded ones and replaces
  /// the next page's key.
  void appendPage(List<ItemType> newItems, PageKeyType nextPageKey) {
    final previousItems = value.itemList ?? [];
    final itemList = previousItems + newItems;
    value = PagingState<PageKeyType, ItemType>(
      itemList: itemList,
      error: null,
      nextPageKey: nextPageKey,
    );
  }

  /// Appends [newItems] to the previously loaded ones and sets the next page
  /// key to `null`.
  void appendLastPage(List<ItemType> newItems) => appendPage(newItems, null);

  /// Erases the current error and requests the last page again from the
  /// listeners.
  void retryLastRequest() {
    error = null;
    notifyPageRequestListeners(nextPageKey);
  }

  /// Resets [value] to its initial state and requests the first page again
  /// from the listeners.
  void refresh() {
    value = PagingState<PageKeyType, ItemType>(
      nextPageKey: firstPageKey,
      error: null,
      itemList: null,
    );

    notifyPageRequestListeners(firstPageKey);
  }

  /// Calls listener every time the status of the pagination changes.
  ///
  /// Listeners can be removed with [removeStatusListener].
  void addStatusListener(PagingStatusListener listener) {
    _statusListeners.add(listener);
  }

  /// Stops calling the listener every time the status of the pagination
  /// changes.
  ///
  /// Listeners can be added with [addStatusListener].
  void removeStatusListener(PagingStatusListener listener) {
    _statusListeners.remove(listener);
  }

  /// Calls all the status listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyStatusListeners(PagingStatus status) {
    final localListeners = List<PagingStatusListener>.from(_statusListeners);
    localListeners.forEach((listener) {
      if (_statusListeners.contains(listener)) {
        listener(status);
      }
    });
  }

  /// Calls listener every time new items are needed.
  ///
  /// Listeners can be removed with [removePageRequestListener].
  void addPageRequestListener(PageRequestListener<PageKeyType> listener) {
    _pageRequestListeners.add(listener);
  }

  /// Stops calling the listener every time new items are needed.
  ///
  /// Listeners can be added with [addPageRequestListener].
  void removePageRequestListener(PageRequestListener<PageKeyType> listener) {
    _pageRequestListeners.remove(listener);
  }

  /// Calls all the page request listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyPageRequestListeners(PageKeyType pageKey) {
    final localListeners =
        List<PageRequestListener<PageKeyType>>.from(_pageRequestListeners);

    localListeners.forEach((listener) {
      if (_pageRequestListeners.contains(listener)) {
        listener(pageKey);
      }
    });
  }

  /// Corresponding to [ValueNotifier.value].
  @override
  set value(PagingState<PageKeyType, ItemType> newValue) {
    if (value.status != newValue.status) {
      notifyStatusListeners(newValue.status);
    }

    super.value = newValue;
  }

  @override
  void dispose() {
    _statusListeners = null;
    _pageRequestListeners = null;
    super.dispose();
  }
}