---
title: Setting Up a Fully Automated Publish Tool for My Hugo Blog
date: 2026-01-07
description: ""
image: ""
categories:
  - Note
draft: false
---
~~Too lazy for a full tut (just can't finish homework fr).~~

First off, for the writing setup, I went with **Obsidian**. Simple reasons: open source, cross-plat, and the plugin ecosystem goes hard.

If you're part of the broke student gang like me, just use **Remote Sync**. iCloud on Windows is honestly kinda sus/unstable for direct reading in my experience.

Since I'm using massive **CJK fonts** (Kose Font/Xiaolai), I had to do local subsetting so the site doesn't take forever to load. Started with `pyftsubset` on my old setup but it was slow AF, so I swapped to the more basic `harfbuzz` and `woff2`.

> apparently if you compile `harfbuzz` with `FreeType` it can handle `.woff2` internally, but I cba to test that. I just grabbed a pre-compiled `harfbuzz` and compiled Google’s official `woff2` myself. Y'all can try the other way if you want tho.

---

**TBC...**