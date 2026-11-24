"""Compatibility workaround for Flutter OH 3.35.7 embedding with API 20.

Run after installing/updating Flutter OH artifacts:
  python3 tool/patch_harmony_api20.py --sdk /path/to/flutter_flutter
Original HAR files are preserved alongside each archive as *.api20-original.
To revert, restore those original files. Do not use this patch for API 26 builds:
it disables API 26 autofill and the newer free-window detection.
"""
import argparse
import io
from pathlib import Path
import shutil
import tarfile


def replace_body(text, marker, body):
    start = text.index(marker)
    opening = text.index('{', start)
    depth = 1
    end = opening + 1
    while depth:
        if text[end] == '{': depth += 1
        elif text[end] == '}': depth -= 1
        end += 1
    return text[:opening + 1] + '\n' + body + '\n  }' + text[end:]


def patch(name, text):
    if name.endswith('/OhosAutoFillHelper.ets'):
        text = replace_body(text, '  static requestAutoFill(', '    // API 26 autofill is not available in an API 20 build.\n    onFailure(-1);')
        text = replace_body(text, '  static requestAutoSave(', '    // API 26 autofill is not available in an API 20 build.\n    napiCallback.onFailure();')
        text = text.replace('autoFillManager.AutoFillType', 'number')
        text = text.replace('autoFillManager.ViewData', 'AutoFillManagerViewData')
    elif name.endswith('/EmbeddingNodeController.ets'):
        text = text.replace('postInputEventWithStrategy(event, CompetitionStrategy.DEFAULT)', 'postInputEvent(event)')
        if 'CompetitionStrategy.DEFAULT' in text:
            raise RuntimeError('Unrecognized input-event call; inspect this engine version')
    elif name.endswith('/FlutterManager.ets'):
        text = text.replace('return mainWindow.isInFreeWindowMode();', 'return false; // API 20: free-window detection is unavailable.')
    return text


def patch_archive(path):
    changes = {}
    with tarfile.open(path, 'r:*') as archive:
        for member in archive.getmembers():
            if member.isfile() and member.name.endswith(('OhosAutoFillHelper.ets', 'EmbeddingNodeController.ets', 'FlutterManager.ets')):
                original = archive.extractfile(member).read()
                modified = patch(member.name, original.decode()).encode()
                if modified != original:
                    changes[member.name] = modified
        if not changes:
            return False
        backup = path.with_name(path.name + '.api20-original')
        if not backup.exists(): shutil.copy2(path, backup)
        temporary = path.with_name(path.name + '.api20-tmp')
        try:
            with tarfile.open(temporary, 'w:gz') as output:
                for member in archive.getmembers():
                    data = changes.get(member.name)
                    if data is not None:
                        member.size = len(data)
                        output.addfile(member, io.BytesIO(data))
                    else:
                        output.addfile(member, archive.extractfile(member) if member.isfile() else None)
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)
    return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--sdk', required=True, type=Path)
    args = parser.parse_args()
    artifacts = args.sdk / 'bin/cache/artifacts/engine'
    paths = sorted(artifacts.glob('ohos*/flutter*.har'))
    if not paths: raise SystemExit('No downloaded Harmony Flutter HAR artifacts found')
    changed = 0
    for path in paths:
        if patch_archive(path):
            changed += 1
            print('Patched:', path)
    # This project previously used the monolithic flutter.har; patch it too.
    local = Path(__file__).resolve().parents[1] / 'ohos/har/flutter.har'
    if local.exists() and patch_archive(local):
        changed += 1
        print('Patched:', local)
    print(f'{changed} archives updated; originals preserved as *.api20-original')
