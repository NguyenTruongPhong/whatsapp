import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/common/providers/refresh_screen.dart';
import 'package:whatsapp_ui/common/providers/toggle_group_chat.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/build_search_text_field.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

import 'package:whatsapp_ui/features/call/screens/call_invitation_screen.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';

import 'package:whatsapp_ui/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_ui/features/status/screens/status_confirm_screen.dart';
import 'package:whatsapp_ui/features/status/screens/status_contacts_screen.dart';
import 'package:whatsapp_ui/features/chat/widgets/contacts_list.dart';

import '../common/providers/searching.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/mobile-layout';

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const MobileLayoutScreen(),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabBarController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print(state.name.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        await ref.watch(authControllerProvider).updateOnlineState(true);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        await ref.watch(authControllerProvider).updateOnlineState(false);
        break;
    }
  }

  void floatingActionButtonJob() async {
    if (tabBarController.index == 0) {
      Navigator.pushNamed(context, SelectContactsScreen.routeName);
    } else {
      await pickImageOrVideoFromGallery(
        context: context,
        type: ImagePickerTypeEnum.image,
      ).then((File? image) {
        if (image == null) {
          return;
        } else {
          Navigator.of(context).pushNamed(
            StatusConfirmScreen.routeName,
            arguments: image,
          );
        }
      });
    }
  }

  void startSearching(String query) {
    print('call searching');
    ref.read(searchingStateProvider.notifier).update((state) => query.trim());
    setState(() {});
  }

  void cancelSearching() {
    isSearching = false;
    searchController.clear();
    ref.read(searchingStateProvider.notifier).update((state) => '');
    setState(() {});
  }

  void clearSearching() {
    searchController.clear();
    ref.read(searchingStateProvider.notifier).update((state) => '');
    setState(() {});
  }

  void refreshScreen() {
    ref.listen<bool>(refreshScreenStateProvider, (previous, next) {
      if (!previous! && next && isSearching) {
        setState(() {
          isSearching = false;
        });
      }
      ref.read(refreshScreenStateProvider.notifier).update((state) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshScreen(); // in the case using search but not cancel and go straight to the mobile chat screen
    return GestureDetector(
      onTap: () {
        isSearching = false;
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {});
      },
      child: CallInvitationScreen(
        isGroupChat: ref.watch(toggleGroupChatProvider),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: appBarColor,
              centerTitle: false,
              title: isSearching
                  ? BuildSearchTextField(
                      startSearching: startSearching,
                      clearSearching: clearSearching,
                      cancelSearching: cancelSearching,
                      searchController: searchController,
                    )
                  : const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              actions: isSearching
                  ? null
                  : [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            isSearching = true;
                          });
                        },
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        // color: greyColor,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: const Text('Create Group'),
                              onTap: () {
                                Future(
                                  () => Navigator.of(context)
                                      .pushNamed(CreateGroupScreen.routeName),
                                );
                              },
                            ),
                          ];
                        },
                      ),
                    ],
              bottom: TabBar(
                controller: tabBarController,
                indicatorColor: tabColor,
                indicatorWeight: 4,
                labelColor: tabColor,
                unselectedLabelColor: greyColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(
                    text: 'CHATS',
                  ),
                  Tab(
                    text: 'STATUS',
                  ),
                  Tab(
                    text: 'CALLS',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: tabBarController,
              children: const [
                ContactsList(),
                StatusContactsScreen(),
                Center(child: Text('Calls')),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: floatingActionButtonJob,
              backgroundColor: tabColor,
              child: const Icon(
                Icons.comment,
                color: whiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
