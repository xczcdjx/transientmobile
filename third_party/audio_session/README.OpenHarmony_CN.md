> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>audio_session</code> </h1>
</p>

本项目基于 [audio_session](https://pub.dev/packages/audio_session) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
---
dependencies:
  audio_session:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_audio_session.git
      # ref: 根据下方表格选择不同框架适配的TAG版本
      ref: TAG # 根据下方表格选择不同框架适配的TAG版本
```

执行命令

```bash
flutter pub get
```

> TAG 命名规则：`原库版本-ohos-版本号-betax`，不同 TAG 之间的变更详见 CHANGELOG.OpenHarmony.md。

| Flutter 框架版本  | TAG 名称                | 分支名 |
| ---------------- | ----------------------- | ---- |
| 3.7              | 0.1.18-ohos-1.0.0-beta.1 | master |
| 3.22             | 0.1.21-ohos-1.0.0-beta.1 | br_v0.1.21_ohos |
| 3.27             | 0.2.2-ohos-1.0.1 | br_v0.2.2_ohos |
| 3.35             | 0.2.2-ohos-1.0.1 | br_v0.2.2_ohos |

> 版本升级 / 迁移说明：
> - 跨 Flutter 框架版本升级（如 3.7 → 3.27 / 3.35）时，将 `pubspec.yaml` 中的 `ref` 更新为对应 TAG 后执行 `flutter pub get`。每个 TAG 绑定特定 OHOS Flutter SDK，版本不匹配会导致构建失败。
> - OHOS 实现的 API 在各 TAG 间保持兼容，升级时已有的 Dart 调用（`AudioSession.instance`、`OhosAudioManager()` 等）无需改动。
> - 若基于旧分支二次开发，建议基于目标分支（`br_v0.2.2_ohos`）rebase 而非 cherry-pick，以保证 `ohos/` 原生层与 Dart 代理层一致。

<!-- tabs:end -->

### 1.2 使用案例

完整可运行示例见 [example/lib/main.dart](./example/lib/main.dart)。推荐调用链为：**导入 → 获取会话 → 配置 → 激活**。

```dart
import 'package:audio_session/audio_session.dart';

// 1. 获取单例音频会话。
final session = await AudioSession.instance;

// 2. 配置会话（iOS/Android/OHOS 通用 API）。
await session.configure(const AudioSessionConfiguration.speech());

// 3. 激活会话。OHOS 底层会以请求的并发模式激活 AudioSessionStrategy。
await session.setActive(true);
```

如需使用 OHOS 专属能力，通过平台代理 `OhosAudioManager` 直接调用类型化 API：

```dart
import 'package:audio_session/src/ohos.dart';

// OHOS 专属：使用 DevicesFlags 位掩码查询音频设备。
final manager = OhosAudioManager();
final devices = await manager.getDevices(
  DevicesFlags.outputDevicesFlag | DevicesFlags.inputDevicesFlag,
);

// OHOS 专属：监听设备增删事件。
manager.setAudioDevicesAddedListener((added) {
  // added: List<OhosAudioDeviceDescriptor>
});
manager.setAudioDevicesRemovedListener((removed) {
  // removed: List<OhosAudioDeviceDescriptor>
});

// OHOS 专属：接收音频中断（会话停用）事件。
await manager.setInterruptionEventListener(OhosInterruptListernerRequest(
  audioAttributes: OhosAudioAttributes(
    streamUsage: StreamUsage.music,
    samplingRate: AudioSamplingRate.sampleRate44100,
    channels: AudioChannel.channel2,
    sampleFormat: AudioSampleFormat.sampleFormatS16LE,
    encodingType: AudioEncodingType.encodingTypePcm,
  ),
  isOnListener: true,
  onAudioFocusChanged: (reason) {
    // reason: AudioSessionDeactivatedReason
  },
));
```

## 2. 约束与限制

### 2.1 OHOS 环境配置

在 OpenHarmony / HarmonyOS 上构建并运行本插件前，请准备以下工具链。本项目的实测版本组合见 [2.2 兼容性](#22-兼容性)。

1. **DevEco Studio**：安装 DevEco Studio 并首次启动，使其下载内置 SDK（`ohpm`、`hvigor`、HarmonyOS SDK）。
2. **OHOS 命令行工具**：确保 `ohpm` 与 `hvigorw` 在 `PATH` 中（通常位于 `<DevEcoStudio>/tools/ohpm/bin` 和 `<DevEcoStudio>/tools/hvigor/bin`），可用 `ohpm -v` 验证。
3. **Flutter（OHOS 分支）**：安装支持 OHOS 的 Flutter SDK（`flutter --version` 应显示 `-ohos` 后缀，例如 `3.27.5-ohos`）。平台检测使用 `Platform.isOhos`。
4. **构建示例 HAP**：在 `example/` 目录下执行：

   ```bash
   flutter pub get
   flutter build hap --debug
   # 为保证构建确定性，可在 example/ohos/hvigor/hvigor-config.json5 中
   # 设置 execution.daemon=false 关闭 hvigor daemon
   ```

5. **安装到设备**：`hdc install <hap 路径>`，或通过 DevEco Studio 部署。

### 2.2 兼容性

在以下版本中已测试通过

1. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

### 2.3 平台能力限制

- `OhosAudioManager.setMicrophoneMute`：底层依赖 `ohos.permission.MANAGE_AUDIO_CONFIG`（仅系统应用可申请）。三方应用调用将返回 `UnsupportedOperation`。只读接口 `isMicrophoneMute` 仍可用。

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### OhosAudioManager 

| Name                           | Description                      | Type     | Input                                                    | Output                                    | ohos Support |
| ------------------------------ | -------------------------------- | -------- | -------------------------------------------------------- | ----------------------------------------- | ------------ |
| setAudioDevicesAddedListener   | 设置音频设备添加的监听器         | function | `OhosOnAudioDevicesChanged` listener                     | /                                         | yes          |
| setAudioDevicesRemovedListener | 设置音频设备移除的监听器         | function | `OhosOnAudioDevicesChanged` listener                     | /                                         | yes          |
| setInterruptionEventListener   | 设置中断事件监听器               | function | `OhosInterruptListernerRequest` listernerRequest         | /                                         | yes          |
| setActive                      | 设置音频会话是否激活             | function | `bool` active, {`AudioConcurrencyMode?` concurrencyMode} | `Future<bool>`                            | yes          |
| isVolumeUnadjustable           | 检查音量是否不可调整             | function | /                                                        | `Future<bool>`                            | yes          |
| getRingerMode                  | 获取铃声模式                     | function | /                                                        | `Future<AudioRingMode>`                   | yes          |
| getMaxVolume                   | 获取指定流类型的系统最大音量     | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| getMinVolume                   | 获取指定流类型的系统最小音量     | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| getVolume                      | 获取指定流类型的当前系统音量     | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| getSystemVolumeInDb            | 获取指定流类型在分贝中的系统音量 | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| isMute                         | 检查指定流类型是否静音           | function | `AudioVolumeType` streamType                             | `Future<bool>`                            | yes          |
| getDevices                     | 获取所有音频设备                 | function | `DevicesFlags` flags                                     | `Future<List<OhosAudioDeviceDescriptor>>` | yes          |
| setSpeakerphoneOn              | 设置扬声器是否开启               | function | `bool` enabled                                           | `Future<void>`                            | yes          |
| isSpeakerphoneOn               | 检查扬声器是否开启               | function | /                                                        | `Future<bool>`                            | yes          |
| setMicrophoneMute              | 设置麦克风是否静音               | function | `bool` enabled                                           | `Future<void>`                            | no（需系统权限 `MANAGE_AUDIO_CONFIG`，三方应用返回 UnsupportedOperation） |
| isMicrophoneMute               | 检查麦克风是否静音               | function | /                                                        | `Future<bool>`                            | yes          |
| getAudioScene                  | 获取当前音频场景                 | function | /                                                        | `Future<AudioScene>`                      | yes          |
| isMusicActive                  | 检查是否有音乐正在播放           | function | /                                                        | `Future<bool>`                            | yes          |
| setAudioParameter              | 设置音频参数                     | function | `String` parameters, `String` value                      | `Future<void>`                            | yes          |
| getAudioParameter              | 获取音频参数                     | function | `String` key                                             | `Future<String>`                          | yes          |

### OhosInterruptEvent API

| Name      | Description  | Type | Input | Output | ohos Support |
| --------- | ------------ | ---- | ----- | ------ | ------------ |
| eventType | 中断事件类型 | enum | /     | /      | yes          |
| forceType | 中断强制类型 | enum | /     | /      | yes          |
| hintType  | 中断提示类型 | enum | /     | /      | yes          |

### OhosInterruptType API

| Name               | Description | Type | Input | Output | ohos Support |
| ------------------ | ----------- | ---- | ----- | ------ | ------------ |
| interruptTypeBegin | 开始中断    | enum | /     | /      | yes          |
| interruptTypeEnd   | 结束中断    | enum | /     | /      | yes          |

### OhosInterruptForceType API

| Name           | Description | Type | Input | Output | ohos Support |
| -------------- | ----------- | ---- | ----- | ------ | ------------ |
| interruptForce | 强制中断    | enum | /     | /      | yes          |
| interruptShare | 共享中断    | enum | /     | /      | yes          |

### OhosInterruptHint API

| Name                | Description  | Type | Input | Output | ohos Support |
| ------------------- | ------------ | ---- | ----- | ------ | ------------ |
| interruptHintNone   | 无提示       | enum | /     | /      | yes          |
| interruptHintResume | 恢复提示     | enum | /     | /      | yes          |
| interruptHintPause  | 暂停提示     | enum | /     | /      | yes          |
| interruptHintStop   | 停止提示     | enum | /     | /      | yes          |
| interruptHintDuck   | 降低音量提示 | enum | /     | /      | yes          |
| interruptHintUnduck | 恢复音量提示 | enum | /     | /      | yes          |

### AudioRingMode API

| Name              | Description | Type | Input | Output | ohos Support |
| ----------------- | ----------- | ---- | ----- | ------ | ------------ |
| ringerModeSilent  | 静音模式    | enum | /     | /      | yes          |
| ringerModeVibrate | 振动模式    | enum | /     | /      | yes          |
| ringerModeNormal  | 正常模式    | enum | /     | /      | yes          |

### AudioScene API

| Name                | Description  | Type | Input | Output | ohos Support |
| ------------------- | ------------ | ---- | ----- | ------ | ------------ |
| audioSceneDefault   | 默认音频场景 | enum | /     | /      | yes          |
| audioSceneRinging   | 铃声场景     | enum | /     | /      | yes          |
| audioScenePhoneCall | 电话通话场景 | enum | /     | /      | yes          |
| audioSceneVoiceChat | 语音聊天场景 | enum | /     | /      | yes          |

### AudioSessionDeactivatedReason API

| Name                     | Description        | Type | Input | Output | ohos Support |
| ------------------------ | ------------------ | ---- | ----- | ------ | ------------ |
| deactivatedLowerPriority | 因为优先级低被停用 | enum | /     | /      | yes          |
| deactivatedTimeout       | 超时停用           | enum | /     | /      | yes          |

### OhosAudioDeviceDescriptor API

| Name          | Description        | Type              | Input | Output | ohos Support |
| ------------- | ------------------ | ----------------- | ----- | ------ | ------------ |
| deviceRole    | 设备角色           | DeviceRole        | /     | /      | yes          |
| deviceType    | 设备类型           | DeviceType        | /     | /      | yes          |
| id            | 设备 ID            | int               | /     | /      | yes          |
| name          | 设备名称           | String            | /     | /      | yes          |
| address       | 设备地址           | String            | /     | /      | yes          |
| sampleRates   | 支持的采样率列表   | List<int>         | /     | /      | yes          |
| channelCounts | 支持的声道数列表   | List<int>         | /     | /      | yes          |
| channelMasks  | 支持的声道掩码列表 | List<int>         | /     | /      | yes          |
| displayName   | 显示名称           | String            | /     | /      | yes          |
| encodingTypes | 支持的编码类型     | AudioEncodingType | /     | /      | yes          |

### AudioEncodingType API

| Name                | Description  | Type | Input | Output | ohos Support |
| ------------------- | ------------ | ---- | ----- | ------ | ------------ |
| encodingTypeInvalid | 无效编码类型 | enum | /     | /      | yes          |
| encodingTypeRaw     | 原始编码类型 | enum | /     | /      | yes          |

### DeviceRole API

| Name         | Description | Type | Input | Output | ohos Support |
| ------------ | ----------- | ---- | ----- | ------ | ------------ |
| inputDevice  | 输入设备    | enum | /     | /      | yes          |
| outputDevice | 输出设备    | enum | /     | /      | yes          |

### DeviceType API

| Name            | Description          | Type | Input | Output | ohos Support |
| --------------- | -------------------- | ---- | ----- | ------ | ------------ |
| invalid         | 无效设备             | enum | /     | /      | yes          |
| earpiece        | 听筒                 | enum | /     | /      | yes          |
| speaker         | 扬声器               | enum | /     | /      | yes          |
| wiredHeadset    | 有线耳机             | enum | /     | /      | yes          |
| wiredHeadphones | 有线耳机（带麦克风） | enum | /     | /      | yes          |
| bluetoothSco    | 蓝牙 SCO 连接        | enum | /     | /      | yes          |
| bluetoothA2dp   | 蓝牙 A2DP 连接       | enum | /     | /      | yes          |
| mic             | 麦克风               | enum | /     | /      | yes          |
| usbHeadset      | USB 耳机             | enum | /     | /      | yes          |
| defaultDevice   | 默认设备             | enum | /     | /      | yes          |

### AudioVolumeType API

| Name           | Description | Type | Input | Output | ohos Support |
| -------------- | ----------- | ---- | ----- | ------ | ------------ |
| voiceCall      | 语音通话    | enum | /     | /      | yes          |
| ringTone       | 铃声        | enum | /     | /      | yes          |
| media          | 媒体        | enum | /     | /      | yes          |
| alarm          | 闹钟        | enum | /     | /      | yes          |
| accessibility  | 辅助功能    | enum | /     | /      | yes          |
| voiceAssistant | 语音助手    | enum | /     | /      | yes          |
| ultraSonic     | 超声波      | enum | /     | /      | yes          |
| all            | 所有        | enum | /     | /      | yes          |

### OhosAudioAttributes API

| Name         | Description | Type              | Input | Output | ohos Support |
| ------------ | ----------- | ----------------- | ----- | ------ | ------------ |
| streamUsage  | 流使用      | StreamUsage       | /     | /      | yes          |
| samplingRate | 采样率      | AudioSamplingRate | /     | /      | yes          |
| channels     | 声道        | AudioChannel      | /     | /      | yes          |
| sampleFormat | 样本格式    | AudioSampleFormat | /     | /      | yes          |
| encodingType | 编码类型    | AudioEncodingType | /     | /      | yes          |

### StreamUsage API

| Name               | Description | Type | Input | Output | ohos Support |
| ------------------ | ----------- | ---- | ----- | ------ | ------------ |
| unknown            | 未知用途    | enum | /     | /      | yes          |
| music              | 音乐        | enum | /     | /      | yes          |
| voiceCommunication | 语音通信    | enum | /     | /      | yes          |
| voiceAssistant     | 语音助手    | enum | /     | /      | yes          |
| alarm              | 闹钟        | enum | /     | /      | yes          |
| voiceMessage       | 语音消息    | enum | /     | /      | yes          |
| ringTone           | 铃声        | enum | /     | /      | yes          |
| notification       | 通知        | enum | /     | /      | yes          |
| accessibility      | 辅助功能    | enum | /     | /      | yes          |
| movie              | 电影        | enum | /     | /      | yes          |
| game               | 游戏        | enum | /     | /      | yes          |
| audioBook          | 有声书      | enum | /     | /      | yes          |
| navigation         | 导航        | enum | /     | /      | yes          |

### OhosInterruptListernerRequest API

| Name                | Description          | Type                | Input | Output | ohos Support |
| ------------------- | -------------------- | ------------------- | ----- | ------ | ------------ |
| audioAttributes     | 音频属性             | OhosAudioAttributes | /     | /      | yes          |
| onAudioFocusChanged | 音频焦点变化回调函数 | function            | /     | /      | yes          |
| isOnListener        | 是否开启监听器       | bool                | /     | /      | yes          |

### AudioSamplingRate API

| Name            | Description    | Type | Input | Output | ohos Support |
| --------------- | -------------- | ---- | ----- | ------ | ------------ |
| sampleRate8000  | 8000Hz 采样率  | enum | /     | /      | yes          |
| sampleRate11025 | 11025Hz 采样率 | enum | /     | /      | yes          |
| sampleRate12000 | 12000Hz 采样率 | enum | /     | /      | yes          |
| sampleRate16000 | 16000Hz 采样率 | enum | /     | /      | yes          |
| sampleRate22050 | 22050Hz 采样率 | enum | /     | /      | yes          |
| sampleRate24000 | 24000Hz 采样率 | enum | /     | /      | yes          |
| sampleRate32000 | 32000Hz 采样率 | enum | /     | /      | yes          |
| sampleRate44100 | 44100Hz 采样率 | enum | /     | /      | yes          |
| sampleRate48000 | 48000Hz 采样率 | enum | /     | /      | yes          |
| sampleRate64000 | 64000Hz 采样率 | enum | /     | /      | yes          |
| sampleRate96000 | 96000Hz 采样率 | enum | /     | /      | yes          |

### AudioChannel API

| Name      | Description | Type | Input | Output | ohos Support |
| --------- | ----------- | ---- | ----- | ------ | ------------ |
| channel1  | 单声道      | enum | /     | /      | yes          |
| channel2  | 双声道      | enum | /     | /      | yes          |
| channel3  | 三声道      | enum | /     | /      | yes          |
| channel4  | 四声道      | enum | /     | /      | yes          |
| channel5  | 五声道      | enum | /     | /      | yes          |
| channel6  | 六声道      | enum | /     | /      | yes          |
| channel7  | 七声道      | enum | /     | /      | yes          |
| channel8  | 八声道      | enum | /     | /      | yes          |
| channel9  | 九声道      | enum | /     | /      | yes          |
| channel10 | 十声道      | enum | /     | /      | yes          |
| channel11 | 十一声道    | enum | /     | /      | yes          |
| channel12 | 十二声道    | enum | /     | /      | yes          |
| channel13 | 十三声道    | enum | /     | /      | yes          |
| channel14 | 十四声道    | enum | /     | /      | yes          |
| channel15 | 十五声道    | enum | /     | /      | yes          |
| channel16 | 十六声道    | enum | /     | /      | yes          |

### AudioSampleFormat API

| Name                | Description           | Type | Input | Output | ohos Support |
| ------------------- | --------------------- | ---- | ----- | ------ | ------------ |
| sampleFormatInvalid | 无效格式              | enum | /     | /      | yes          |
| sampleFormatU8      | 8 位无符号整型        | enum | /     | /      | yes          |
| sampleFormatS16LE   | 16 位有符号整型小端序 | enum | /     | /      | yes          |
| sampleFormatS24LE   | 24 位有符号整型小端序 | enum | /     | /      | yes          |
| sampleFormatS32LE   | 32 位有符号整型小端序 | enum | /     | /      | yes          |
| sampleFormatF32LE   | 32 位浮点型小端序     | enum | /     | /      | yes          |

### AudioConcurrencyMode API

| Name                     | Description  | Type | Input | Output | ohos Support |
| ------------------------ | ------------ | ---- | ----- | ------ | ------------ |
| concurrencyDefault       | 默认并发模式 | enum | /     | /      | yes          |
| concurrencyMixWithOthers | 与其它混合   | enum | /     | /      | yes          |
| concurrencyDuckOthers    | 让其它变弱   | enum | /     | /      | yes          |
| concurrencyPauseOthers   | 暂停其它     | enum | /     | /      | yes          |

### DevicesFlags API

`OhosAudioManager.getDevices(flags)` 使用的位掩码，用于过滤返回的音频设备。可通过下方位运算符组合使用。

| Name                       | Description                          | Type   | Input           | Output         | ohos Support |
| -------------------------- | ------------------------------------ | ------ | --------------- | -------------- | ------------ |
| noneDevicesFlag            | 无设备标志（值 `0`）                 | const  | /               | /              | yes          |
| outputDevicesFlag          | 输出设备（值 `1`）                   | const  | /               | /              | yes          |
| inputDevicesFlag           | 输入设备（值 `2`）                   | const  | /               | /              | yes          |
| allDevicesFlag             | 所有本地设备（值 `3`）               | const  | /               | /              | yes          |
| distributedOutputDevicesFlag | 分布式输出设备（值 `4`）           | const  | /               | /              | yes          |
| distributedInputDevicesFlag  | 分布式输入设备（值 `8`）           | const  | /               | /              | yes          |
| addDistributedDevicesFlag  | 所有分布式设备（值 `12`）            | const  | /               | /              | yes          |
| operator \|                | 返回两个标志的并集                   | method | `DevicesFlags`  | `DevicesFlags` | yes          |
| operator &                 | 返回两个标志的交集                   | method | `DevicesFlags`  | `DevicesFlags` | yes          |
| contains                   | 判断是否完整包含另一个标志集         | method | `DevicesFlags`  | `bool`         | yes          |

### InterruptMode API

OHOS 音频中断共享模式。

| Name          | Description                 | Type | Input | Output | ohos Support |
| ------------- | --------------------------- | ---- | ----- | ------ | ------------ |
| shareMode     | 多应用共享音频焦点          | enum | /     | /      | yes          |
| indepentMode  | 独占音频焦点                | enum | /     | /      | yes          |

### OhosOnAudioFocusChanged（typedef）

OHOS 音频会话被停用（发生音频焦点变化）时触发的回调签名。

| Name                    | Description                       | Type    | Input                          | Output | ohos Support |
| ----------------------- | --------------------------------- | ------- | ------------------------------ | ------ | ------------ |
| OhosOnAudioFocusChanged | 音频焦点 / 中断事件监听回调       | typedef | `AudioSessionDeactivatedReason`| `void` | yes          |

### OhosOnAudioDevicesChanged（typedef）

OHOS 音频设备增删时触发的回调签名。

| Name                      | Description         | Type    | Input                            | Output | ohos Support |
| ------------------------- | ------------------- | ------- | -------------------------------- | ------ | ------------ |
| OhosOnAudioDevicesChanged | 音频设备变化监听回调 | typedef | `List<OhosAudioDeviceDescriptor>`| `void` | yes          |

## 4. 遗留问题

## 5. 其他

## 6. 开源协议

本项目基于 [The MIT License (MIT)](./LICENSE) ，请自由地享受和参与开源。

## 附录：OHOS 与 Android/iOS 平台差异说明

以下差异属于鸿蒙平台能力边界或有意适配策略，接入时请注意：

| 能力 | Android / iOS | OHOS 现状 |
| --- | --- | --- |
| `getSystemVolumeInDb` | Android 需 stream/index/device 三参 | Dart OHOS API 仅传 `AudioVolumeType`；原生侧用当前音量等级 + `SPEAKER` 补齐后查询，并四舍五入为 `int` |
| `isVolumeUnadjustable` | Android `isVolumeFixed` | 对应 `VolumeGroupManager.isVolumeUnadjustable()` |
| 音频焦点 / 中断 | AudioFocus / AVAudioSession interruption | 使用 `AudioSessionManager` 的 `activateAudioSession` / `audioSessionDeactivated` |
| `channelIndexMasks` | Android 设备描述含该字段 | OHOS `AudioDeviceDescriptor` 无此字段，编码时返回空数组，避免误用 `channelMasks` |
| `adjustStreamVolume` / `adjustVolume` / `setStreamVolume` / `setRingerMode` | 有原生实现 | 已用 `AudioManager.setVolume` / `setRingerMode`（API 9 起标记废弃，仍可编译调用）实现 |
| `setCommunicationDevice` / `getCommunicationDevice` / `clearCommunicationDevice` | 有原生实现 | 公开 `CommunicationDeviceType` 仅 `SPEAKER`；通过 `setCommunicationDevice(SPEAKER, …)` / `isCommunicationDeviceActiveSync` 近似实现 |
| `setAllowedCapturePolicy` / `getAllowedCapturePolicy` / `setMode(setAudioScene)` | 有原生实现 | **公开 SDK 无对等 API**（系统能力），调用 no-op 并打日志 |
| `startBluetoothSco` / `setBluetoothScoOn` / `generateAudioSessionId` 等 | 有原生实现 | **公开 SDK 无对等 API**，调用返回 null |

