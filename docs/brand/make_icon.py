#!/usr/bin/env python3
"""Dayfold app icon: one SVG design -> light/dark/tinted iOS icons + macOS sizes.

Run from the repo root:  python3 docs/brand/make_icon.py
Needs `rsvg-convert` (brew install librsvg). Writes SVGs next to this file
(usable as layers in Icon Composer) and PNGs into the AppIcon asset set.
"""
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
BRAND = ROOT / "docs/brand"
ICONSET = ROOT / "dayfold/Assets.xcassets/AppIcon.appiconset"

# bg_top/bg_bottom: background gradient. page/flap: paper + folded corner. ink: marks. faint: done/note marks.
THEMES = {
    "light":  dict(bg_top="#46569C", bg_bottom="#33417D", page="#FAF7F2", flap="#DDD6C8", ink="#3B4A8C", check="#FAF7F2", faint="#9AA0B5", shadow=0.28),
    "dark":   dict(bg_top="#1C1B19", bg_bottom="#0E0D0C", page="#26231F", flap="#3B3732", ink="#A3B0F2", check="#1C1B19", faint="#6E6A64", shadow=0.5),
    "tinted": dict(bg_top="#000000", bg_bottom="#000000", page="#E6E6E6", flap="#9A9A9A", ink="#3C3C3C", check="#E6E6E6", faint="#8A8A8A", shadow=0.0),
}


def artwork(t: dict) -> str:
    """The 1024x1024 full-bleed design (no outer mask; iOS rounds the corners)."""
    return f"""
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{t['bg_top']}"/><stop offset="1" stop-color="{t['bg_bottom']}"/>
    </linearGradient>
    <filter id="lift" x="-20%" y="-20%" width="140%" height="150%">
      <feDropShadow dx="0" dy="22" stdDeviation="26" flood-color="#000" flood-opacity="{t['shadow']}"/>
    </filter>
  </defs>
  <rect width="1024" height="1024" fill="url(#bg)"/>

  <!-- the page, top-right corner folded -->
  <path filter="url(#lift)" fill="{t['page']}"
        d="M 296 186 H 640 L 770 316 V 804 A 34 34 0 0 1 736 838 H 296 A 34 34 0 0 1 262 804 V 220 A 34 34 0 0 1 296 186 Z"/>
  <path fill="{t['flap']}" d="M 640 186 V 288 A 28 28 0 0 0 668 316 H 770 Z"/>

  <!-- ○ open task -->
  <circle cx="356" cy="428" r="33" fill="none" stroke="{t['ink']}" stroke-width="17"/>
  <rect x="432" y="411" width="236" height="34" rx="17" fill="{t['ink']}"/>

  <!-- ✓ done task -->
  <circle cx="356" cy="548" r="41.5" fill="{t['ink']}"/>
  <path d="M 336 549 L 350 563 L 377 533" fill="none" stroke="{t['check']}" stroke-width="15"
        stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="432" y="531" width="180" height="34" rx="17" fill="{t['ink']}" opacity="0.38"/>

  <!-- – note -->
  <rect x="331" y="658" width="50" height="20" rx="10" fill="{t['faint']}"/>
  <rect x="432" y="651" width="214" height="34" rx="17" fill="{t['ink']}"/>
"""


def svg(body: str) -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">{body}</svg>\n'


def mac_svg(t: dict) -> str:
    """macOS grid: 824pt rounded square centred on the 1024 canvas, with a soft drop shadow."""
    return svg(f"""
  <defs>
    <clipPath id="squircle"><rect x="100" y="100" width="824" height="824" rx="185"/></clipPath>
    <filter id="tile" x="-10%" y="-10%" width="120%" height="125%">
      <feDropShadow dx="0" dy="12" stdDeviation="14" flood-color="#000" flood-opacity="0.3"/>
    </filter>
  </defs>
  <rect x="100" y="100" width="824" height="824" rx="185" fill="{t['bg_bottom']}" filter="url(#tile)"/>
  <g clip-path="url(#squircle)">
    <g transform="translate(100 100) scale({824 / 1024})">{artwork(t)}</g>
  </g>""")


def render(svg_text: str, out: pathlib.Path, px: int) -> None:
    subprocess.run(["rsvg-convert", "-w", str(px), "-h", str(px), "-o", str(out)],
                   input=svg_text.encode(), check=True)


def main() -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)
    images = []

    # iOS: one 1024 image per appearance.
    for name, theme in THEMES.items():
        source = svg(artwork(theme))
        (BRAND / f"icon-{name}.svg").write_text(source)
        filename = f"icon-ios-{name}.png"
        render(source, ICONSET / filename, 1024)
        entry = {"idiom": "universal", "platform": "ios", "size": "1024x1024", "filename": filename}
        if name != "light":
            entry["appearances"] = [{"appearance": "luminosity", "value": name}]
        images.append(entry)

    # macOS: classic size set, light artwork on the Mac grid.
    mac = mac_svg(THEMES["light"])
    (BRAND / "icon-mac.svg").write_text(mac)
    for points in (16, 32, 128, 256, 512):
        for scale in (1, 2):
            filename = f"icon-mac-{points}@{scale}x.png"
            render(mac, ICONSET / filename, points * scale)
            images.append({"idiom": "mac", "scale": f"{scale}x", "size": f"{points}x{points}", "filename": filename})

    (ICONSET / "Contents.json").write_text(json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
    print(f"wrote {len(images)} icons to {ICONSET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
