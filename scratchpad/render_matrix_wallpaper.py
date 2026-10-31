#!/usr/bin/env python3
"""
render_matrix_wallpaper.py -- animated MATRIX RAIN phone wallpaper.

Arma cannot animate a PAA, so the animation is baked as N frames that a client loop swaps onto the
wallpaper control (idc 90300). To keep the loop SEAMLESS with few frames, the rain advances exactly
one cell per frame and every column's cycle length divides the frame count -- so frame N-1 flows back
into frame 0 with no jump. Glyphs are re-rolled per frame so the stream still flickers like the film.

Output: mission/images/wallpapers/matrix/matrix_00.paa .. matrix_<N-1>.paa
"""
import os, sys, random
from PIL import Image, ImageDraw, ImageFont
SC = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(SC, '..', 'tools'))
from make_paa import build_paa_dxt5, verify_paa

MIS    = os.path.join(SC, '..', 'mission', 'LooneyBin.Altis')
OUT    = os.path.join(MIS, 'images', 'wallpapers', 'matrix')
W, H   = 512, 256           # owner 2026-07-21: halved from 1024x512 to cut PBO weight (~11M -> ~3M). It's a
                            # stretched background, so half-res is invisible in game. All spatial constants below
                            # are halved in lockstep, so the pattern + the seamless loop are identical.
# SEAMLESS LOOP MATHS (owner 2026-07-20 -- the first cut visibly jumped):
# a column wraps every ROWS cells and advances 1 cell per frame, so the animation only closes if
# FRAMES == ROWS *and* ROWS * CELL == H exactly. 16 x 16 = 256 satisfies both, so frame 15 flows
# back into frame 0 with zero discontinuity. Do not change one of these three numbers alone.
CELL   = 16                 # glyph cell height (halved with H so ROWS stays 16)
ROWS   = H // CELL          # 16 -- tiles H exactly
FRAMES = ROWS               # 16 -- one full wrap per loop
COLW   = 10                 # column width (halved with W so COLS stays 51)
COLS   = W // COLW
assert ROWS * CELL == H and FRAMES == ROWS, "loop would not be seamless"

# NO FONT ON THIS BOX ACTUALLY HAS KATAKANA. Liberation Mono passed a naive coverage test only because
# it draws the .notdef BOX glyph (which has a bbox), so the first bake came out as a field of tofu. The
# fix is to synthesise the alphabet: each glyph is 2-4 strokes on a 3x5 lattice, deterministic per id.
# At rain scale this reads exactly like the film's alphabet and costs no font dependency.
GLYPH_COUNT = 48

HEAD = (200, 255, 210)      # near-white leading glyph
BRIGHT = (120, 255, 150)
BODY = (30, 200, 80)
DEEP = (10, 90, 35)


def glyph_atlas(cell):
    """Pre-render GLYPH_COUNT stroke-built glyphs as 'L' masks (drawn once, pasted many times)."""
    from PIL import Image as _I, ImageDraw as _D
    w, h = cell - 6, cell - 6
    xs = [0, w // 2, w]
    ys = [0, h // 4, h // 2, (3 * h) // 4, h]
    segs = (
        [((xs[0], ys[r]), (xs[2], ys[r])) for r in range(5)] +          # horizontals
        [((xs[c], ys[0]), (xs[c], ys[4])) for c in range(3)] +          # full verticals
        [((xs[c], ys[1]), (xs[c], ys[3])) for c in range(3)] +          # short verticals
        [((xs[0], ys[0]), (xs[2], ys[2])), ((xs[2], ys[0]), (xs[0], ys[2])),
         ((xs[0], ys[2]), (xs[2], ys[4])), ((xs[2], ys[2]), (xs[0], ys[4]))]
    )
    out = []
    for g in range(GLYPH_COUNT):
        r = random.Random(9000 + g)
        im = _I.new("L", (w, h), 0)
        d = _D.Draw(im)
        for (a, b) in r.sample(segs, r.randint(2, 4)):
            d.line([a, b], fill=255, width=2)
        out.append(im)
    return out


def build():
    """
    Glyphs are ANCHORED to their cells; only the BRIGHTNESS travels down the column.

    The first cut slid the whole column one cell per frame -- a 32px (1/16th screen) spatial jump that
    read as judder no matter the frame delay, because smoothness of sliding motion is capped by frame
    count, not frame rate. In the film the characters don't slide at all: they sit still and the glow
    runs down them. Animating light instead of position removes the judder completely and keeps the
    loop seamless at only FRAMES images (head wraps every ROWS == FRAMES steps).
    """
    rng = random.Random(1337)
    atlas = glyph_atlas(CELL)
    print(f"procedural glyph atlas: {GLYPH_COUNT} glyphs (anchored; brightness travels)")

    trails = [rng.randint(5, ROWS - 2) for _ in range(COLS)]
    phase  = [rng.randrange(ROWS) for _ in range(COLS)]
    lit    = [rng.random() < 0.86 for _ in range(COLS)]
    # fixed glyph per cell -- nothing moves between frames
    cellg  = [[rng.randrange(GLYPH_COUNT) for _ in range(ROWS)] for _ in range(COLS)]

    frames = []
    for f in range(FRAMES):
        img = Image.new("RGB", (W, H), (0, 0, 0))
        # a handful of cells swap glyph each frame -> the stream shimmers without shifting.
        # Seeded on f so frame FRAMES-1 -> frame 0 is as continuous as any other step.
        srng = random.Random(4242 + f)
        flick = {(srng.randrange(COLS), srng.randrange(ROWS)): srng.randrange(GLYPH_COUNT)
                 for _ in range((COLS * ROWS) // 14)}
        for c in range(COLS):
            if not lit[c]:
                continue
            head = (phase[c] + f) % ROWS
            for t in range(trails[c]):
                r = (head - t) % ROWS
                if t == 0:
                    col = HEAD
                elif t == 1:
                    col = BRIGHT
                else:
                    k = 1.0 - (t / float(trails[c]))
                    col = (int(DEEP[0] + (BODY[0] - DEEP[0]) * k),
                           int(DEEP[1] + (BODY[1] - DEEP[1]) * k),
                           int(DEEP[2] + (BODY[2] - DEEP[2]) * k))
                gi = flick.get((c, r), cellg[c][r])
                img.paste(col, (c * COLW + 3, r * CELL + 3), atlas[gi])
        frames.append(img)
    return frames


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    total = 0
    for i, im in enumerate(build()):
        p = f"/tmp/matrix_{i:02d}.png"
        im.save(p)
        dst = os.path.join(OUT, f"matrix_{i:02d}.paa")
        build_paa_dxt5(p, dst)
        total += os.path.getsize(dst)
    print(f"baked {FRAMES} frames -> {total/1048576:.1f} MB total")
    print("verify frame 0:", verify_paa(os.path.join(OUT, "matrix_00.paa"))[1])
