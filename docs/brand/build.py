"""Generate the Wayfinch mark variants as SVG files."""
import pathlib

OUT = pathlib.Path(__file__).parent / "assets"
OUT.mkdir(exist_ok=True)

YELLOW, NAVY, ORANGE = "#F7B84B", "#23324A", "#E8833A"

# Checkmark centerline and thickness
CHECK = "M69 312 L202 449 L447 201"
CHECK_W = 87

# Bird shapes
HEAD = dict(cx=334, cy=126, r=88)
BODY = dict(cx=242, cy=228, rx=150, ry=122, rot=-40)
# soft fill between head and back so the joint is a smooth dip, not a notch
DIP = "M186 154 Q236 120 266 74 L310 170 Z"
# fills the crook of the check under the belly
CROOK = "M140 300 L202 430 L300 330 L240 300 Z"
WING = ("M112 282 C148 220 214 182 266 190 C306 196 314 242 288 272 "
        "C258 306 196 312 156 298 C136 290 122 284 112 282 Z")
BEAK = "M410 102 L466 124 L410 148 Z"
EYE = dict(cx=364, cy=122, r=17)
CAP = dict(cx=396, cy=30, rx=68, ry=58)

# Region above the check's centerline: the bird is clipped to it so it
# tucks into the check with no gap
ABOVE_CHECK = "0,0 512,0 512,135 202,449 0,241"


def body_shapes(fill):
    return (
        f'<circle cx="{HEAD["cx"]}" cy="{HEAD["cy"]}" r="{HEAD["r"]}" fill="{fill}"/>'
        f'<ellipse cx="{BODY["cx"]}" cy="{BODY["cy"]}" rx="{BODY["rx"]}" ry="{BODY["ry"]}" '
        f'transform="rotate({BODY["rot"]} {BODY["cx"]} {BODY["cy"]})" fill="{fill}"/>'
        f'<path d="{DIP}" fill="{fill}"/>'
        f'<path d="{CROOK}" fill="{fill}"/>'
    )


def color_svg():
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <title>Wayfinch</title>
  <defs>
    <clipPath id="above"><polygon points="{ABOVE_CHECK}"/></clipPath>
    <clipPath id="head"><circle cx="{HEAD["cx"]}" cy="{HEAD["cy"]}" r="{HEAD["r"]}"/></clipPath>
  </defs>
  <g clip-path="url(#above)">
    {body_shapes(YELLOW)}
    <path d="{WING}" fill="{NAVY}"/>
  </g>
  <ellipse cx="{CAP["cx"]}" cy="{CAP["cy"]}" rx="{CAP["rx"]}" ry="{CAP["ry"]}" fill="{NAVY}" clip-path="url(#head)"/>
  <path d="{BEAK}" fill="{ORANGE}" stroke="{ORANGE}" stroke-width="10" stroke-linejoin="round"/>
  <circle cx="{EYE["cx"]}" cy="{EYE["cy"]}" r="{EYE["r"]}" fill="{NAVY}"/>
  <path d="{CHECK}" fill="none" stroke="{NAVY}" stroke-width="{CHECK_W}" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
'''


def mono_svg(ink):
    """One-color version: same drawing, separations cut out as transparent gaps."""
    gap = 14
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <title>Wayfinch</title>
  <defs>
    <clipPath id="above"><polygon points="{ABOVE_CHECK}"/></clipPath>
    <mask id="cut" maskUnits="userSpaceOnUse" x="0" y="0" width="512" height="512">
      <rect width="512" height="512" fill="#fff"/>
      <path d="{CHECK}" fill="none" stroke="#000" stroke-width="{CHECK_W + 2 * gap}" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="{WING}" fill="none" stroke="#000" stroke-width="{gap}" stroke-linejoin="round"/>
      <circle cx="{EYE["cx"]}" cy="{EYE["cy"]}" r="{EYE["r"]}" fill="#000"/>
    </mask>
  </defs>
  <g mask="url(#cut)">
    <g clip-path="url(#above)">{body_shapes(ink)}</g>
    <path d="{BEAK}" fill="{ink}" stroke="{ink}" stroke-width="10" stroke-linejoin="round"/>
  </g>
  <path d="{CHECK}" fill="none" stroke="{ink}" stroke-width="{CHECK_W}" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
'''


def sticker_svg():
    """Color mark with a white outline so it stays visible on dark taskbars."""
    inner = color_svg().split("\n", 1)[1].rsplit("</svg>", 1)[0]
    outline = 22
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="-16 -16 544 544" width="512" height="512">
  <defs>
    <clipPath id="above-s"><polygon points="{ABOVE_CHECK}"/></clipPath>
  </defs>
  <g fill="#FFFFFF" stroke="#FFFFFF" stroke-width="{outline * 2}" stroke-linejoin="round" stroke-linecap="round">
    <g clip-path="url(#above-s)">{body_shapes("#FFFFFF")}</g>
    <path d="{BEAK}"/>
    <path d="{CHECK}" fill="none" stroke-width="{CHECK_W + outline * 2}"/>
  </g>
  {inner}
</svg>
'''


(OUT / "wayfinch-mark.svg").write_text(color_svg())
(OUT / "wayfinch-mark-mono-navy.svg").write_text(mono_svg(NAVY))
(OUT / "wayfinch-mark-mono-white.svg").write_text(mono_svg("#FFFFFF"))
(OUT / "wayfinch-app-icon.svg").write_text(sticker_svg())
print("ok")
