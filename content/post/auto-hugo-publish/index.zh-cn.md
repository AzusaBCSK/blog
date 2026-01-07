---
title: 关于我配置了一条全自动发布Hugo博客的工具链
date: 2026-01-03
description: 我才不会告诉你上一篇是拿这个发的喵。
image: ""
categories:
  - 述
draft: true
---
~~目前懒得写教程了（确定不是因为补不完作业吗）。~~  
首先是写 Blog 工具的选择，我选择了 Obsidian 。原因很简单就是开源多平台同步可装插件。没钱的学生党可以跟我一样用 Remote Sync ，个人感觉自己配置 iCloud for Windows 然后直接读不是很稳。
因为涉及到很大的CJK字体（Kose Font/Xiaolai），考虑到网络访问速度于是做了本地裁切字体，一开始在之前的电脑上用 `pyftsubset` 做裁切，但是实在太慢了所以换成了更基础的 `harfbuzz` 和 `woff2`。
> 其实据说 `harfbuzz` 带上 `FreeType` 编译可以直接内部处理 `.woff2` 字体，但是懒得试了于是下载了编译好的 `harfbuzz` 并自己编译了谷歌官方的 `woff2`，大家也可以自己试试。
---
未完待续……