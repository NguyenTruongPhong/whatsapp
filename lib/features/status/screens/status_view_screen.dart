import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/features/models/status_model.dart';
import "package:story_view/story_view.dart";

class StatusViewScreen extends ConsumerStatefulWidget {
  const StatusViewScreen({Key? key, required this.status}) : super(key: key);

  final StatusModel status;

  static const routeName = '/status-view';
  static Route route(StatusModel status) {
    return MaterialPageRoute(
      builder: (context) => StatusViewScreen(status: status),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatusViewScreenState();
}

class _StatusViewScreenState extends ConsumerState<StatusViewScreen> {
  late final StoryController storyController;

  @override
  void initState() {
    super.initState();
    storyController = StoryController();
  }

  @override
  Widget build(BuildContext context) {
    return StoryView(
      storyItems: widget.status.photoUrls
          .map((photoUrl) =>
              StoryItem.pageImage(url: photoUrl, controller: storyController))
          .toList(),
      controller: storyController,
      repeat: false,
      onComplete: () => Navigator.of(context).pop(),
      onVerticalSwipeComplete: (direction) {
        if (direction == Direction.down) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
