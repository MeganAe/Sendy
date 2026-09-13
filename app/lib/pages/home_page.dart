// Modified for Sendy: adaptive navigation, history destination, branded header and reduced-motion transitions.
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/init.dart';
import 'package:localsend_app/config/sendy/sendy_brand.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/home_page_controller.dart';
import 'package:localsend_app/pages/receive_history_page.dart';
import 'package:localsend_app/pages/tabs/receive_tab.dart';
import 'package:localsend_app/pages/tabs/send_tab.dart';
import 'package:localsend_app/pages/tabs/settings_tab.dart';
import 'package:localsend_app/provider/animation_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/util/native/cross_file_converters.dart';
import 'package:localsend_app/widget/responsive_builder.dart';
import 'package:localsend_app/widget/sendy/sendy_logo.dart';
import 'package:refena_flutter/refena_flutter.dart';

enum HomeTab {
  send(Icons.north_east_rounded),
  receive(Icons.south_west_rounded),
  history(Icons.history_rounded),
  settings(Icons.settings_outlined)
  ;

  const HomeTab(this.icon);

  final IconData icon;

  String get label {
    switch (this) {
      case HomeTab.receive:
        return t.receiveTab.title;
      case HomeTab.send:
        return t.sendTab.title;
      case HomeTab.history:
        return t.receiveHistoryPage.title;
      case HomeTab.settings:
        return t.settingsTab.title;
    }
  }
}

class HomePage extends StatefulWidget {
  final HomeTab initialTab;

  /// It is important for the initializing step
  /// because the first init clears the cache
  final bool appStart;

  const HomePage({
    required this.initialTab,
    required this.appStart,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with Refena {
  bool _dragAndDropIndicator = false;

  @override
  void initState() {
    super.initState();

    ensureRef((ref) async {
      ref.redux(homePageControllerProvider).dispatch(ChangeTabAction(widget.initialTab));
      await postInit(context, ref, widget.appStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    Translations.of(context); // rebuild on locale change
    final vm = context.watch(homePageControllerProvider);
    final animations = context.watch(animationProvider) && !MediaQuery.disableAnimationsOf(context);
    void changeTab(HomeTab tab) => ref.redux(homePageControllerProvider).dispatch(ChangeTabAction(tab, animate: animations));
    const mainTabs = [HomeTab.send, HomeTab.receive, HomeTab.history];

    return DropTarget(
      onDragEntered: (_) {
        setState(() {
          _dragAndDropIndicator = true;
        });
      },
      onDragExited: (_) {
        setState(() {
          _dragAndDropIndicator = false;
        });
      },
      onDragDone: (event) async {
        // the drop may contain a mix of files and directories
        final droppedDirectories = event.files.where((file) => Directory(file.path).existsSync()).toList();
        final droppedFiles = event.files.where((file) => !Directory(file.path).existsSync()).toList();

        for (final directory in droppedDirectories) {
          await ref.redux(selectedSendingFilesProvider).dispatchAsync(AddDirectoryAction(directory.path));
        }

        if (droppedFiles.isNotEmpty) {
          await ref
              .redux(selectedSendingFilesProvider)
              .dispatchAsync(
                AddFilesAction(
                  files: droppedFiles,
                  converter: CrossFileConverters.convertXFile,
                ),
              );
        }
        if (mounted) {
          setState(() => _dragAndDropIndicator = false);
          changeTab(HomeTab.send);
        }
      },
      child: ResponsiveBuilder(
        builder: (sizingInformation) {
          return Scaffold(
            appBar: sizingInformation.isMobile
                ? AppBar(
                    title: const SendyLogo(size: 27),
                    actions: [
                      IconButton(
                        tooltip: t.settingsTab.title,
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => changeTab(HomeTab.settings),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                : null,
            body: Row(
              children: [
                if (!sizingInformation.isMobile)
                  NavigationRail(
                    selectedIndex: vm.currentTab.index,
                    onDestinationSelected: (index) => changeTab(HomeTab.values[index]),
                    extended: sizingInformation.isDesktop,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    minExtendedWidth: 210,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                      child: SendyLogo(size: 30, withText: sizingInformation.isDesktop),
                    ),
                    destinations: HomeTab.values.map((tab) {
                      return NavigationRailDestination(
                        icon: Icon(tab.icon),
                        label: Text(tab.label),
                      );
                    }).toList(),
                  ),
                Expanded(
                  child: SafeArea(
                    left: sizingInformation.isMobile,
                    child: Stack(
                      children: [
                        PageView(
                          controller: vm.controller,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            SendTab(),
                            ReceiveTab(),
                            ReceiveHistoryPage(),
                            SettingsTab(),
                          ],
                        ),
                        if (_dragAndDropIndicator)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SendyLogo(size: 80, withText: false),
                                const SizedBox(height: 30),
                                Text(SendyCopy(context).dropFiles, style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: sizingInformation.isMobile
                ? NavigationBar(
                    selectedIndex: vm.currentTab == HomeTab.settings ? 3 : mainTabs.indexOf(vm.currentTab),
                    onDestinationSelected: (index) => changeTab(index == 3 ? HomeTab.settings : mainTabs[index]),
                    destinations: [...mainTabs, if (vm.currentTab == HomeTab.settings) HomeTab.settings].map((tab) {
                      return NavigationDestination(icon: Icon(tab.icon), label: tab.label);
                    }).toList(),
                  )
                : null,
          );
        },
      ),
    );
  }
}
