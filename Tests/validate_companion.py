#!/usr/bin/env python3
"""
Test & Validation Suite for WoWPeru_Companion (World of Warcraft 3.3.5a)
Validates:
1. Physical existence of all files listed in WoWPeru_Companion.toc
2. Syntactic integrity of all Lua 5.1 files (block openers/closers balance)
3. Absence of incompatible Retail/MoP APIs without polyfills
"""

import os, sys, re

REPO_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def test_toc_integrity():
    toc_path = os.path.join(REPO_DIR, "WoWPeru_Companion.toc")
    print("[1/3] Testing WoWPeru_Companion.toc file references...")
    if not os.path.exists(toc_path):
        print("ERROR: WoWPeru_Companion.toc not found!")
        return False

    with open(toc_path, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    missing = []
    count = 0
    for line in lines:
        clean = line.strip()
        if not clean or clean.startswith("#"):
            continue
        rel = clean.replace("\\", os.sep).replace("/", os.sep)
        full = os.path.join(REPO_DIR, rel)
        count += 1
        if not os.path.exists(full):
            missing.append(rel)

    if missing:
        print(f"FAILED: {len(missing)} files missing on disk: {missing}")
        return False
    print(f"PASSED: All {count} files referenced in TOC exist on disk.")
    return True

def check_file_syntax(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    content = re.sub(r"--\[\[.*?\]\]", "", content, flags=re.DOTALL)
    lines = content.split('\n')
    stack = []
    kw_count = 0

    for line_idx, line in enumerate(lines, 1):
        clean = re.sub(r"--.*", "", line)
        clean = re.sub(r'"(?:[^"\\]|\\.)*"', '""', clean)
        clean = re.sub(r"'(?:[^'\\]|\\.)*'", "''", clean)

        keywords = re.findall(r"\b(function|if|then|elseif|else|for|while|do|repeat|until|end)\b", clean)
        kw_count += len(keywords)

        for k in keywords:
            if k == "function":
                stack.append((line_idx, "function"))
            elif k == "if":
                stack.append((line_idx, "if"))
            elif k in ("for", "while"):
                stack.append((line_idx, k))
            elif k == "do":
                if stack and stack[-1][1] in ("for", "while"):
                    stack.pop()
                    stack.append((line_idx, "loop"))
                else:
                    stack.append((line_idx, "do"))
            elif k == "repeat":
                stack.append((line_idx, "repeat"))
            elif k == "until":
                if stack and stack[-1][1] == "repeat":
                    stack.pop()
                else:
                    return False, f"Line {line_idx}: unexpected 'until'"
            elif k == "end":
                if not stack:
                    return False, f"Line {line_idx}: unexpected 'end'"
                top = stack.pop()
                if top[1] not in ("function", "if", "loop", "do"):
                    return False, f"Line {line_idx}: mismatched 'end' with {top}"

    if stack:
        return False, f"Unclosed blocks at EOF: {stack}"
    return True, f"Balanced ({kw_count} keywords)"

def test_lua_syntax():
    print("[2/3] Testing Lua 5.1 syntax and block balance...")
    total = 0
    failed = []
    for root, dirs, files in os.walk(REPO_DIR):
        if "Tests" in dirs: dirs.remove("Tests")
        if ".git" in dirs: dirs.remove(".git")
        for f in files:
            if f.endswith(".lua"):
                total += 1
                p = os.path.join(root, f)
                ok, msg = check_file_syntax(p)
                if not ok:
                    failed.append((f, msg))

    if failed:
        print(f"FAILED: {len(failed)} files failed syntax check: {failed}")
        return False
    print(f"PASSED: All {total} Lua files balanced (depth=0).")
    return True

def test_retail_api_leak():
    print("[3/3] Scanning for prohibited Retail/MoP APIs in WotLK 3.3.5a...")
    FORBIDDEN = [
        ("GROUP_ROSTER_UPDATE", "Retail event (use RAID_ROSTER_UPDATE / PARTY_MEMBERS_CHANGED)"),
        ("GetSpecialization", "Retail API"),
        ("C_Timer", "Retail API"),
        ("SetColorTexture", "Retail API"),
    ]
    leaks = []
    for root, dirs, files in os.walk(REPO_DIR):
        if "Tests" in dirs: dirs.remove("Tests")
        if ".git" in dirs: dirs.remove(".git")
        for f in files:
            if f.endswith(".lua"):
                p = os.path.join(root, f)
                with open(p, "r", encoding="utf-8", errors="ignore") as fl:
                    content = fl.read()
                clean_content = re.sub(r"--\[\[.*?\]\]", "", content, flags=re.DOTALL)
                lines = clean_content.split('\n')
                for idx, line in enumerate(lines, 1):
                    clean = re.sub(r"--.*", "", line).strip()
                    if not clean: continue
                    for pat, reason in FORBIDDEN:
                        if pat in clean:
                            leaks.append((f, idx, pat, reason))

    if leaks:
        print(f"FAILED: {len(leaks)} Retail API leaks found: {leaks}")
        return False
    print("PASSED: Zero prohibited Retail/MoP APIs detected.")
    return True

if __name__ == "__main__":
    print("=" * 50)
    print("      WOWPERU_COMPANION TEST SUITE               ")
    print("=" * 50)
    t1 = test_toc_integrity()
    t2 = test_lua_syntax()
    t3 = test_retail_api_leak()
    print("=" * 50)
    if t1 and t2 and t3:
        print(">>> ALL TESTS PASSED SUCCESSFULLY (100%) <<<")
        sys.exit(0)
    else:
        print(">>> TEST SUITE FAILED <<<")
        sys.exit(1)
