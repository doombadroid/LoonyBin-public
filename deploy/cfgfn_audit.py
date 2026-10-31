#!/usr/bin/env python3
"""Block-aware CfgFunctions audit (two-pass).

`file = "..."` is a class ATTRIBUTE and applies to the whole block regardless of declaration
order, so resolution must happen AFTER the tree is built -- a single in-order pass wrongly
flags members declared above their own block's file= line.
"""
import os, re, sys

TOK = re.compile(r'class\s+(\w+)|(\{)|(\})|file\s*=\s*"([^"]+)"')

def build(src):
    src = re.sub(r'/\*.*?\*/', '', src, flags=re.S)
    src = re.sub(r'//[^\n]*', '', src)
    root = {"name": None, "line": 0, "file": None, "kids": []}
    stack, pending = [root], None
    for m in TOK.finditer(src):
        line = src[:m.start()].count("\n") + 1
        cls, lb, rb, fv = m.groups()
        if cls:
            pending = (cls, line)
        elif lb:
            n = {"name": pending[0] if pending else None,
                 "line": pending[1] if pending else line, "file": None, "kids": []}
            pending = None
            stack[-1]["kids"].append(n); stack.append(n)
        elif fv:
            stack[-1]["file"] = fv.replace("\\", "/").lstrip("/")
        elif rb and len(stack) > 1:
            stack.pop()
    return root

def resolve(node, root_dir, inherited, out, strip):
    d = node["file"] or inherited
    if node["name"] and not node["kids"] and not node["file"]:
        if d is None:
            out.append((node["line"], node["name"], "<no file= in any ancestor>")); return
        rel = d[len(strip):].lstrip("/") if strip and d.startswith(strip) else d
        if not os.path.exists(os.path.join(root_dir, rel, "fn_%s.sqf" % node["name"])):
            out.append((node["line"], node["name"], "%s/fn_%s.sqf" % (rel, node["name"])))
        return
    for k in node["kids"]:
        resolve(k, root_dir, d, out, strip)

def audit(cfg, root_dir, label, strip=""):
    out = []
    resolve(build(open(cfg, errors="ignore").read()), root_dir, None, out, strip)
    out = [x for x in out if x[1] != "BIS_AddonInfo"]
    print("== %s: %d unresolved" % (label, len(out)))
    for i, n, p in out:
        print("   line %d: class %s -> %s" % (i, n, p))
    return out

if __name__ == "__main__":
    base = sys.argv[1] if len(sys.argv) > 1 else "."
    M = os.path.join(base, "mission/LooneyBin.Altis")
    audit(os.path.join(M, "Functions.h"), M, "mission/Functions.h")
    S = os.path.join(base, "server/life_server")
    audit(os.path.join(S, "config.cpp"), S, "server/config.cpp", strip="life_server")

