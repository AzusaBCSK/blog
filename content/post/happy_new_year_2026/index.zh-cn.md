---
title: 2026 新年快乐！来做个 2025 的年终总结吧！
date: 2026-01-01
description: 唔……又活过了一年呢
image: 2025end_SAO.png
categories:
  - 述
  - 念
draft: false
---
## 你终于想起来自己有个 Blog 了？
今天配置 [Fork](https://git-fork.com/) 的头像，发现 [Gravatar](https://gravatar.com/) 可以用来当个人主页，于是利用Cloudflare Workers配置了一个反代，删了一点不要的HTML组件然后扔到我的新域名wynn.moe上，看着效果还不错🤔  
[来看我的个人主页喵](https://wynn.moe)  
然后就想起来了。多少有点非常随性了。  
{{< details title="放一下 Workers 的代码：" >}}

```js
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.protocol === "http:") {
      url.protocol = "https:";
      return Response.redirect(url.href, 301);
    }

    const targetHost = "www.gravatar.com";
    const username = "你的 Gravatar 用户名";

    const actualPath = url.pathname === "/" ? `/${username}` : url.pathname;
    const targetUrl = `https://${targetHost}${actualPath}${url.search}`;

    let response = await fetch(targetUrl, {
      headers: {
        "User-Agent": request.headers.get("User-Agent"),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
      }
    });

    const contentType = response.headers.get("content-type") || "";

    if (contentType.includes("text/html")) {
      const rewriter = new HTMLRewriter()
        .on("head", {
          element(e) {
            const iconUrl = `https://www.gravatar.com/avatar/这里填你注册邮箱的MD5?s=32`;
            e.append(`<link rel="icon" type="image/png" href="${iconUrl}">`, { html: true });
          }
        })
        .on("#unified-header", { element(e) { e.remove(); } })
        .on("footer", { element(e) { e.remove(); } })
        .on("img", {
          element(e) {
            const src = e.getAttribute("src");
            if (src && src.startsWith("/")) {
              e.setAttribute("src", `https://${targetHost}${src}`);
            }
          }
        })
        .on("link", {
          element(e) {
            const href = e.getAttribute("href");
            if (href && href.startsWith("/")) {
              e.setAttribute("href", `https://${targetHost}${href}`);
            }
          }
        });

      let newHdrs = new Headers(response.headers);
      newHdrs.delete("X-Frame-Options");
      newHdrs.delete("Content-Security-Policy");
      newHdrs.set("Content-Type", "text/html; charset=utf-8");

      const transformedResponse = rewriter.transform(response);

      return new Response(transformedResponse.body, {
        status: response.status,
        headers: newHdrs
      });
    }

    return response;
  }
};
```

{{< /details >}}

---
## 碎碎念
好久没写博客了，最近发生了好多事（虽然有偷偷更新 About ）  

### 🎓 学校 & 学业

- **7 月**：被算是目标校的学校录取  
    在新学校遇到了很好的老师和同学们。
    
- 入学教育期间参加了一次 **商赛**  
    我队的 Corp. **路演拿了第一名**！！！
    
- 在国际部学到了很多新东西哇。
    

### 🌏 出行 & 朋友

- **8 月底**：第一次自己一个人去 **深圳 & 香港**
    见到了好朋友：和 [ResetPower](https://resetpower.moe/)  [StrParfait](https://github.com/Texas20041108)
    
- 和一个很好的朋友决裂了😭  
    后来又和好了wwww。
    
### 🎹 设备 & 爱好

- 得到了很想要的：
    
    - 一台 15英寸 足足 32GB RAM 和 1TB SSD 的 **Surface Book 3**
        
    - 一台 **Sakiko 同款 Roland FA-08**
        
- 我们的老将 **MacBook Pro Early 2013** 正式退役  
    它已经尽力了。Wynn 同学终于告别了8+256的尴尬局面。
    
- 第一次组了一个**类似乐队的团体**
    - 并经历了“炸团风波”（？是不是每个乐队都得炸一次）
    
### 💻 编程 & 癖好

- 编程风格开始向 **日本程序员（？）** 转变
    
- 对 **1.44MB 级别、无额外依赖的可执行程序** 产生了诡异执念
    
    - 比如 WebView2 之类的：达咩 ❌
        

### 🧠 状态总结

- 在新环境的支持和鼓励下，**情绪稳定了不少**，也感谢大家的陪伴吧
    
- 这么一看，**2025 年的下半年某人活得还挺滋润**，真是可喜可贺，可喜可贺口牙。
    

好了“生活滋润”的某人要趁着元旦假补 GPA 了，下次再见~

> ~~话说你写的好混乱，你的精神状态真的没问题吗~~


![干杯！](2025end_SAO.jpg)