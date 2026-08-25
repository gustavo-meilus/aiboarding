#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
fail() { printf 'FAIL: %s\n' "$1"; exit 1; }
for f in assets/aiboarding-icon.svg assets/aiboarding-wordmark-light.svg assets/aiboarding-wordmark-dark.svg assets/aiboarding-demo.svg assets/aiboarding-icon-512.png assets/aiboarding-social-preview.png docs/BRAND.md CONTRIBUTING.md CODE_OF_CONDUCT.md .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml .github/pull_request_template.md; do [ -f "$ROOT/$f" ] || fail "missing $f"; done
python3 - "$ROOT" <<'PY'
import json, re, struct, sys
from pathlib import Path
from xml.etree import ElementTree as ET
root = Path(sys.argv[1])
def fail(message): raise SystemExit(f"FAIL: {message}")
for name in ('aiboarding-icon.svg','aiboarding-wordmark-light.svg','aiboarding-wordmark-dark.svg','aiboarding-demo.svg'):
    text=(root/'assets'/name).read_text(encoding='utf-8')
    try: ET.fromstring(text)
    except ET.ParseError as e: fail(f"invalid SVG {name}: {e}")
    if re.search(r'<script|(?:href|src)=["\'](?:https?:|[^#])', text, re.I): fail(f"non-portable SVG reference in {name}")
def png(name, size):
    data=(root/'assets'/name).read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n': fail(f"invalid PNG signature {name}")
    dimensions=struct.unpack('>II', data[16:24])
    if dimensions != size: fail(f"wrong PNG dimensions {name}: {dimensions}")
    if name == 'aiboarding-social-preview.png' and len(data) >= 1_000_000: fail('social preview is >= 1 MB')
png('aiboarding-icon-512.png',(512,512)); png('aiboarding-social-preview.png',(1280,640))
readme=(root/'README.md').read_text(encoding='utf-8')
for link in re.findall(r'\]\((\.\/[^)#]+)', readme):
    if not (root/link).exists(): fail(f"broken README link {link}")
for marker in ('keeps `AGENTS.md` alive','onboarding drift','Quick start','Proof and limits'):
    if marker not in readme: fail(f"missing README marker {marker}")
if readme.index('## Proof and limits') > readme.index('## What it does'): fail('README journey places workflow before proof')
version=json.loads((root/'.claude-plugin/plugin.json').read_text())['version']
codex=root/'.codex-plugin/plugin.json'
if json.loads(codex.read_text())['version'] != version: fail(f"version mismatch {codex.relative_to(root)}")
if f'## {version} ' not in (root/'CHANGELOG.md').read_text(): fail('CHANGELOG version mismatch')
for path in (root/'.claude-plugin/plugin.json', root/'.claude-plugin/marketplace.json', root/'.codex-plugin/plugin.json'):
    if 'canonical AGENTS.md' not in path.read_text(): fail(f"positioning missing from {path.relative_to(root)}")
for key in ('composerIcon', 'logo'):
    asset=json.loads(codex.read_text())['interface'][key]
    if not asset.startswith('./') or not (root/asset[2:]).is_file(): fail(f"missing manifest asset {key}: {asset}")
for path in (root/'.github/ISSUE_TEMPLATE/bug_report.yml',root/'.github/ISSUE_TEMPLATE/feature_request.yml'):
    if 'name:' not in path.read_text() or 'body:' not in path.read_text(): fail(f"invalid issue form {path.name}")
PY
printf 'PASS: branding checks\n'
