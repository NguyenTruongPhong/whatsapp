enum ImagePickerTypeEnum {
  image,
  video,
}

enum MessageTypeEnum {
  text,
  gif,
  audio,
  image,
  video,
  file,
  icon,
  // text('text'),
  // gif('gif'),
  // audio('audio'),
  // image('image'),
  // video('video'),
  // file('file'),
  // icon('icon');

  // const MessageTypeEnum(this.type);
  // final String type;
}

extension ConvertStringToMessageTypeEnum on String {
  MessageTypeEnum convertStringToMessageTypeEnum() {
    switch (this) {
      case 'text':
        return MessageTypeEnum.text;
      case 'gif':
        return MessageTypeEnum.gif;
      case 'audio':
        return MessageTypeEnum.audio;
      case 'image':
        return MessageTypeEnum.image;
      case 'video':
        return MessageTypeEnum.video;
      case 'icon':
        return MessageTypeEnum.icon;
      default:
        return MessageTypeEnum.text;
    }
  }
}
