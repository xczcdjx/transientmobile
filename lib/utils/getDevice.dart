
import 'package:flutter/foundation.dart';

({String device, String poem}) getDevice() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return (device: "Android", poem: "事必专任，乃可责成。力无他分，乃能就绪。");
    case TargetPlatform.iOS:
      return (device: "iOS", poem: "惧则思，思则通微，惧则慎，慎则不败。");
    case TargetPlatform.macOS:
      return (device: "macOS", poem: "");
    case TargetPlatform.windows:
      return (device: "Windows", poem: "");
    case TargetPlatform.linux:
      return (device: "Linux", poem: "");
    case TargetPlatform.fuchsia:
      return (device: "Fuchsia", poem: "");
    case TargetPlatform.ohos:
      return (device: "Harmony", poem: "察而后谋，谋而后动，深思远虑，计无不中。");
    default:
      return (device: "未知平台", poem: "");
  }
}