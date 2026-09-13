// Modified for Sendy: start on Send and animate navigation only on explicit accessible user actions.
import 'package:flutter/material.dart';
import 'package:localsend_app/pages/home_page.dart';
import 'package:refena_flutter/refena_flutter.dart';

class HomePageVm {
  final PageController controller;
  final HomeTab currentTab;
  final void Function(HomeTab) changeTab;

  HomePageVm({
    required this.controller,
    required this.currentTab,
    required this.changeTab,
  });
}

final homePageControllerProvider = ReduxProvider<HomePageController, HomePageVm>(
  (ref) => HomePageController(),
);

class HomePageController extends ReduxNotifier<HomePageVm> {
  @override
  HomePageVm init() {
    return HomePageVm(
      controller: PageController(),
      currentTab: HomeTab.send,
      changeTab: (tab) => redux.dispatch(ChangeTabAction(tab)),
    );
  }
}

class ChangeTabAction extends ReduxAction<HomePageController, HomePageVm> {
  final HomeTab tab;

  final bool animate;

  ChangeTabAction(this.tab, {this.animate = false});

  @override
  HomePageVm reduce() {
    if (state.controller.hasClients) {
      if (animate) {
        // ignore: discarded_futures
        state.controller.animateToPage(tab.index, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
      } else {
        state.controller.jumpToPage(tab.index);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.controller.hasClients) {
          state.controller.jumpToPage(state.currentTab.index);
        }
      });
    }
    return HomePageVm(
      controller: state.controller,
      currentTab: tab,
      changeTab: state.changeTab,
    );
  }
}
