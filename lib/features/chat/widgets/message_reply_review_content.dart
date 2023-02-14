import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageReplyReviewContent extends StatelessWidget {
  const MessageReplyReviewContent({
    Key? key,
    required this.message,
    this.isGif = false,
    this.isImage = false,
    required this.onCancel,
    required this.title,
  }) : super(key: key);

  final String message;
  final bool isGif;
  final bool isImage;
  final String title;
  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 40, minWidth: size.width),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 10,
          top: 5,
          right: 5,
          bottom: 5,
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: size.width * 0.6,
                  child: Text(
                    isGif
                        ? 'GIF'
                        : isImage
                            ? 'Image'
                            : message,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isGif || isImage) ...[
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.blue,
                ),
                height: 30,
                width: 30,
                child: CachedNetworkImage(
                  imageUrl: message,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            )
          ],
        ),
      ),
    );
  }
}
