import argparse
import re
import shutil
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path, PurePosixPath


ADDON_NAME = "Bagnon_Battles"
DEV_NAME = ADDON_NAME + "_Dev"
DEV_TITLE = "Bagnon Battles (Dev)"
ROOT = Path(__file__).resolve().parents[2]
WOW_ROOT = Path("/mnt/d/Games/Battle.net Games/World of Warcraft")
WOW_ADDONS = {client: WOW_ROOT / f"_{client}_" / "Interface" / "AddOns" for client in ("retail", "forever")}
DEVELOPMENT_MARKERS = (".git", "_dev")
BLOCKED_PARTS = {
    "_dev", ".git", ".agents", ".codex", ".aws", ".github", "__pycache__",
    "tests", "test", "tools", "docs", "examples", "example",
}
ASSET_SUFFIXES = {
    ".tga", ".blp", ".png", ".jpg", ".jpeg", ".dds", ".gif",
    ".ogg", ".mp3", ".wav", ".ttf", ".otf", ".m2", ".skin", ".anim",
}
LICENSE_NAME = re.compile(r"^(licen[sc]e|copying|copyright|notice)(?:[._-].*)?$", re.I)


class PackageError(Exception):
    pass


def require(condition, message):
    if not condition:
        raise PackageError(message)


def source_path(root, base, reference):
    require(isinstance(reference, str) and reference.strip(), "Empty runtime reference")
    reference = reference.strip().replace("\\", "/")
    parsed = PurePosixPath(reference)
    require(not parsed.is_absolute() and not re.match(r"^[A-Za-z]:", reference),
            f"Unsafe runtime path: {reference}")
    require(not any(ord(char) < 32 for char in reference), f"Unsafe runtime path: {reference}")
    candidate = base.joinpath(*parsed.parts)
    resolved = candidate.resolve()
    require(resolved.is_relative_to(root), f"Runtime path leaves addon folder: {reference}")
    relative = resolved.relative_to(root)
    require(relative.parts and not any(part.startswith(".") or part.lower() in BLOCKED_PARTS for part in relative.parts),
            f"Development file referenced at runtime: {relative}")
    for parent in (candidate, *candidate.parents):
        if parent == root:
            break
        require(not parent.is_symlink(), f"Symlink is not allowed in runtime files: {relative}")
    require(resolved.is_file(), f"Missing runtime file: {relative}")
    return resolved


def collect_files(root):
    root = Path(root).resolve()
    toc = source_path(root, root, ADDON_NAME + ".toc")
    files, folded, visiting = set(), {}, set()

    def include(path):
        relative = path.relative_to(root).as_posix()
        key = relative.casefold()
        require(key not in folded or folded[key] == relative, f"File names differ only by case: {relative}")
        folded[key] = relative
        files.add(path)

    def runtime(path):
        require(path.suffix.lower() in {".lua", ".xml"}, f"Unsupported runtime reference: {path.relative_to(root)}")
        require(path not in visiting, f"XML include cycle: {path.relative_to(root)}")
        if path in files:
            return
        include(path)
        if path.suffix.lower() == ".xml":
            visiting.add(path)
            try:
                document = ET.parse(path)
            except (ET.ParseError, OSError) as error:
                raise PackageError(f"Invalid XML {path.relative_to(root)}: {error}") from error
            for element in document.iter():
                tag = element.tag.rsplit("}", 1)[-1]
                if tag in {"Script", "Include"} and "file" in element.attrib:
                    child = source_path(root, path.parent, element.attrib["file"])
                    expected = ".lua" if tag == "Script" else ".xml"
                    require(child.suffix.lower() == expected, f"Unexpected {tag} reference: {child.relative_to(root)}")
                    runtime(child)
            visiting.remove(path)

    include(toc)
    icons = []
    for line in toc.read_text(encoding="utf-8-sig").splitlines():
        stripped = line.strip()
        match = re.match(r"##\s*IconTexture\s*:\s*(.+)$", stripped, re.I)
        if match:
            icons.append(match.group(1).replace("\\", "/"))
        if not stripped or stripped.startswith("#"):
            continue
        runtime(source_path(root, root, stripped))
    require(len(icons) == 1 and re.fullmatch(r"Interface/Icons/[A-Za-z0-9_]+(?:\.(?:blp|tga))?", icons[0], re.I),
            "TOC IconTexture must name one native Interface\\Icons texture")

    media = root / "Media"
    require(media.is_dir() and not media.is_symlink(), "Missing or unsafe Media folder")
    for path in sorted(media.rglob("*")):
        if path.is_dir():
            require(not path.is_symlink(), f"Symlink is not allowed in Media: {path.relative_to(root)}")
            continue
        checked = source_path(root, root, path.relative_to(root).as_posix())
        require(checked.suffix.lower() in ASSET_SUFFIXES, f"Non-runtime file in Media: {checked.relative_to(root)}")
        include(checked)

    libraries = {root / "Libs" / path.relative_to(root).parts[1]
                 for path in files if len(path.relative_to(root).parts) > 2 and path.relative_to(root).parts[0] == "Libs"}
    for directory in [root, *sorted(libraries)]:
        for path in sorted(directory.iterdir()):
            if path.is_file() and LICENSE_NAME.fullmatch(path.name):
                include(source_path(root, root, path.relative_to(root).as_posix()))
    return sorted(path.relative_to(root) for path in files)


def copy_files(root, files, tree):
    for relative in files:
        destination = tree / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(root / relative, destination)


def build_package(root):
    root = Path(root).resolve()
    files = collect_files(root)
    dist = root / "_dev" / "dist"
    for path in (root / "_dev", dist, dist / ADDON_NAME, dist / (ADDON_NAME + ".zip")):
        require(not path.is_symlink(), f"Unsafe package destination: {path}")
    dist.mkdir(parents=True, exist_ok=True)
    stage, archive = dist / ADDON_NAME, dist / (ADDON_NAME + ".zip")
    with tempfile.TemporaryDirectory(prefix=".package-", dir=dist) as temporary:
        temporary = Path(temporary)
        tree, output = temporary / ADDON_NAME, temporary / archive.name
        copy_files(root, files, tree)
        with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as package:
            for relative in files:
                info = zipfile.ZipInfo(ADDON_NAME + "/" + relative.as_posix(), (1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                package.writestr(info, (tree / relative).read_bytes(), compresslevel=9)
        with zipfile.ZipFile(output) as package:
            expected = [ADDON_NAME + "/" + path.as_posix() for path in files]
            require(package.namelist() == expected and package.testzip() is None, "Package integrity check failed")
        if stage.exists():
            require(stage.is_dir(), f"Package staging path is not a folder: {stage}")
            shutil.rmtree(stage)
        tree.replace(stage)
        output.replace(archive)
    return stage, archive, len(files)


def install_dev(root, addons):
    root, addons = Path(root).resolve(), Path(addons)
    files = collect_files(root)
    require(addons.is_dir() and not addons.is_symlink(), f"Missing or unsafe AddOns folder: {addons}")
    target = addons / DEV_NAME
    require(not target.is_symlink(), f"Unsafe install destination: {target}")
    require(not any((target / marker).exists() for marker in DEVELOPMENT_MARKERS),
            f"Refusing to replace a development checkout: {target}")
    with tempfile.TemporaryDirectory(prefix=f".{DEV_NAME}-", dir=addons) as temporary:
        temporary = Path(temporary)
        tree = temporary / DEV_NAME
        copy_files(root, files, tree)
        toc = tree / (ADDON_NAME + ".toc")
        content, titles = re.subn(rb"^(##\s*Title\s*:)[^\r\n]*", rb"\1 " + DEV_TITLE.encode(), toc.read_bytes(),
                                  count=1, flags=re.M)
        require(titles == 1, "TOC is missing a Title line")
        (tree / (DEV_NAME + ".toc")).write_bytes(content)
        toc.unlink()
        if target.exists():
            require(target.is_dir(), f"Install destination is not a folder: {target}")
            target.replace(temporary / "previous")
        tree.replace(target)
    return target, len(files)


def main():
    parser = argparse.ArgumentParser(description="Build a runtime-only Bagnon Battles addon package.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="Validate runtime files without writing a package.")
    mode.add_argument("--dev", nargs="*", choices=sorted(WOW_ADDONS), metavar="CLIENT",
                      help=f"Copy the runtime files into {DEV_NAME} in the given clients' AddOns folders (default: all).")
    parser.add_argument("--addons-dir", type=Path,
                        help="Override the AddOns folder used by --dev.")
    options = parser.parse_args()
    if options.addons_dir is not None and options.dev is None:
        parser.error("--addons-dir requires --dev")
    try:
        if options.check:
            print(f"Validated {len(collect_files(ROOT))} runtime and license files.")
        elif options.dev is not None:
            if options.addons_dir is not None:
                targets = [options.addons_dir]
            else:
                targets = [WOW_ADDONS[client] for client in (options.dev or sorted(WOW_ADDONS))]
            for addons in targets:
                target, count = install_dev(ROOT, addons)
                print(f"Copied {count} runtime and license files to {target}")
        else:
            stage, archive, count = build_package(ROOT)
            print(f"Packaged {count} runtime and license files.")
            print(f"Upload folder: {stage}")
            print(f"ZIP: {archive}")
    except (PackageError, OSError) as error:
        print(f"Package failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
