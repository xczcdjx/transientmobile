flutter create \
  --template=app \
  --platforms=android,ios,ohos,web,windows,macos,linux \
  --org com.djx \
  --project-name  flutter_all_test\
  -a kotlin \
  -i swift \
  --empty \
flutter_all_test


./flutterw build apk --release


./flutterw build apk --release --split-per-abi --target-platform android-arm,android-arm64


./flutterw build apk --release --target-platform android-arm,android-arm64