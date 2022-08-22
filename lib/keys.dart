/*
Use the enum values defined here for any ValueKeys passed to widgets.
Using strings in keys (e.g. ValueKey('loginButton)) is error prone, because we would need to duplicate the string
e.g. in test files and typos will cause errors that are not detected at compile-time.
*/

enum AppKey {
  loginEmailTextField,
  loginPasswordTextField,
  loginButton,
  loginErrorMessage,
  loginTipButton,

  //home screen navigation widgets
  drawerExtendButton,
  drawerExploreButton,
  drawerSearchButton,
  drawerFavoritesButton,
  drawerSettingsButton,
  drawerLogoutButton,

  navbarExploreButton,
  navbarSearchButton,
  navbarFavoritesButton,
  appbarPopupMenu,
  appbarSettingsButton,
  appbarLogoutButton,

  exploreFavoritesNextButton,
  exploreRandomNextButton,
  exploreRandomErrorRetryWidget,

  favoritesErrorRetryWidget,
  favoritesFilterTextField,
  favoritesSortButton,
  favoritesSortPopupNewestButton,
  favoritesSortPopupOldestButton,
  favoritesFilterAddTagsButton,
  favoritesFilterAddTagsDialog,

  searchBarTextField,
  searchBarSearchButton,
  searchErrorRetryWidget,
  searchLoadMoreButton,
  searchLoadMoreErrorRetryWidget,

  tipDialogDisableTipsCheckbox,
  tipDialogCloseButton,
}
