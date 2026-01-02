---
title: あけおめ2026！2025年の振り返りいってみよう！
date: 2026-01-01
description: ふむ……また一年、生き延びたか。
image: 2025end_SAO.png
categories:
  - 語り
  - こころ
draft: true
---
## やっとブログの存在を思い出した？
本日、[Fork](https://git-fork.com/) のアバターを設定している折、[Gravatar](https://gravatar.com/) が個人のホームとして転用可能僕はなことに気づいた。そこで僕は Cloudflare Workers を用いてReverse Proxyを即席で組み上げ、無用なHTML部品を排除し、新ドメイン wynn.moe へと投下した。見た目も案外、悪くない🤔  
[僕のホーム、見に来てね](https://wynn.moe)  
そこでハッとした。「そういえば僕、ブログ持ってるじゃん」と。相変わらず気まぐれなことで。  
{{< details title="Workersのコードはこんな感じ：" >}}
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
## 雑記
ブログ書くの何億年ぶりだろう。最近いろいろあったなぁ（「自己紹介」ページはこっそり更新してたけど）。

### 🎓 学校 & 学業

- **7月**：気づけば、学び舎への道が開けていた。  
    僕はよき師、そして学びを共にする友と巡り逢うことができた。
    
- 入学しての手始めの集いにて商いの競いに挑む。  
    我らが模擬会社が Roadshow にて一番の誉れをいただいた！！！
    
- 国際部にて新たな学びを多く得た。
    
### 🌏 旅 & 友だち

- **8月末**：初めて一人で **深圳＆香港** へ。  
  ……一人旅とか、僕がほんとにやる日が来るとは。  
  で、ちゃんと友だちにも会えた： [ResetPower](https://resetpower.moe/) と [StrParfait](https://github.com/Texas20041108)

- 大事な友だちと少しズレたことがあった😭
  でも、今は普通に話せるようにはなった。wwww

### 🎹 機材 & 趣味

- 僕はずっと欲しかったやつ、ついに手に入れた：

  - 15インチ、32GB RAM と 1TB SSD の **Surface Book 3**
  - **祥子と同じモデルの Roland FA-08**

- 古い **MacBook Pro Early 2013**、ついに退役。  
  ほんとに尽くしてくれた。おつかれさま。  
  Wynnくん、ようやく **8+256** の窮屈な呪縛に別れを告げた（長かった）。

- 初めて **バンドっぽい集団** を組んだ。  
  - そして例の「解散騒動」も経験済み（？ なんでどのバンドも一回は爆発するんだ）。

### 💻 プログラミング & 癖

- 僕はコーディングの癖が **日本のプログラマ（？）** 寄りになってきた。  
  何がどう、って言われると難しいけど……なんか、そう。

- **1.44MB級・追加依存なしの単体実行ファイル** に、妙な執念が芽生えた。  
  自分でも「なにやってんだ」って思う。  
  - WebView2 みたいなの：だめ ❌

### 🧠 状態まとめ

- 新しい環境の **支え** と励ましのおかげで、**精神は……たぶん、前よりは安定した、気がする**。  
  ……ありがたい。ほんとに。

- こうして並べてみると、**2025年下半期の某人、わりと充実してた**。  
  いや、充実しすぎてて怖いぐらいだけど。  
  ふむ……まあ、また一年、生き延びたか。

よし。生活「充実」してた某人は、正月休みで **GPA を稼ぎに** 行きます。また今度〜

> ~~文章だいぶ散らかってるけど、精神状態ほんと大丈夫？~~

![Cheers!](2025end_SAO.jpg)