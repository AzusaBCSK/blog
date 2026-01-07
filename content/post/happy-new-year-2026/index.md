---
title: Happy New Year 2026! Time for a 2025 Recap!
date: 2026-01-01
description: Hmm... Survived another year.
image: 2025end_SAO.png
categories:
  - Note
  - Whim
draft: false
---
## So you finally remembered you have a Blog?
Today, while setting up the avatar for [Fork](https://git-fork.com/), I realized [Gravatar](https://gravatar.com/) could effectively be used as a personal homepage. So, I whipped up a Cloudflare Worker as a reverse proxy, nuked some useless HTML components, and tossed it onto my new domain: wynn.moe. It actually looks pretty decent 🤔  
[Check out my new home base](https://wynn.moe)  
And then it hit me—I have a blog. It's all just a bit... spontaneous.  
{{< details title="Here's the Workers code:" >}}

```js
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.protocol === "http:") {
      url.protocol = "https:";
      return Response.redirect(url.href, 301);
    }

    const targetHost = "www.gravatar.com"; 
    const username = "YOUR_GRAVATAR_USERNAME";

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
            const iconUrl = `https://www.gravatar.com/avatar/YOUR_EMAIL_MD5_HASH?s=32`;
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
## Ramblings
Haven't blogged in ages. A ton has happened recently (though I *did* secretly update the About page).

### 🎓 School & Academics

- **July**: Got into my dream school (or close enough).  
    Met some amazing teachers and classmates there.
    
- Joined a **Business Competition** during orientation.  
    My team's startup **took 1st place in the roadshow**!!!
    
- Learned a crazy amount of new stuff in the International Department.
    

### 🌏 Travel & Friends

- **End of August**: First solo trip to **Shenzhen & Hong Kong**.  
    Met up with the homies: [ResetPower](https://github.com/ResetPower26) & [StrParfait](https://github.com/Texas20041108).
    
- Had some drama with an important friend 😭  
    But we made up later wwww.
    
### 🎹 Gear & Hobbies

- Secured some dream loot:
    
    - A 15-inch **Surface Book 3** (Massive 32GB RAM / 1TB SSD beast).
        
    - A **Roland FA-08 (The Sakiko model!)**.
        
- Our veteran **MacBook Pro Early 2013** has officially retired.  
    It served well. Wynn finally bids farewell to the "8+256" nightmare.
    
- Formed a **band-like group** for the first time.
    - And immediately went through a "Band Implosion Incident" (? Is it a universal rule that every band must blow up at least once).
    
### 💻 Coding & Quirks

- Coding style is shifting towards... **Japanese Programmer style (?)**.
    
- Developed a weird obsession with **1.44MB-class, dependency-free executables**.
    
    - Stuff like WebView2: **だめだめー ❌**.
        

### 🧠 Mental Check

- Thanks to the support from the new environment, **my mental state has stabilized a ton**. Big thanks to everyone for sticking around.
    
- Looking back, **a certain someone actually lived a pretty fulfilling life in the second half of 2025**. Joyous! Joyous!
    

Alright, this "fulfilling life" person needs to use the New Year holiday to grind for GPA. See ya next time~

> ~~Btw your writing is all over the place, is ur mental state *really* okay?~~


![Cheers!](2025end_SAO.jpg)