---
title: Project TRITON v0.5：一种带有规范思维语核心的状态空间受控、检索接地架构
date: 2026-04-07
desc: 一种结合了 Mamba-3 控制、因子化检索和基于规范 FHRR 内部表征的神经符号语言架构。
categories:
  - 述
math: true
---
> **摘要。**
> 本文提出了 Project TRITON v0.5，这是一种神经符号语言架构，整合了三项互补的设计原则。首先，Mamba-3 状态空间骨干网络提供时间控制、上下文压缩和实现规划。其次，一个因子化的检索结构将知识、词汇和风格记忆分离，将信息负担从参数化权重转移到外部存储。第三，一个规范的内部内容空间——称为**思维语**（Mentalese）并通过傅里叶全息缩减表征（FHRR）实例化——为结构化绑定、工作记忆和检索接地提供了统一的基底。该架构组织为一个四部分系统：一个 Mamba-3 控制核心、一个 FHRR 思维语核心、一个检索结构以及一个两阶段表层界面。我们描述了评估这种状态空间受控、检索接地框架所需的表征假设、模块接口、训练目标和有待实证检验的问题。

**关键词：** 状态空间模型；Mamba；神经符号系统；检索增强生成；向量符号架构；超维计算；表层实现；思维语

---

## 引言

当前，大型语言模型被期望在单一参数化骨干网络内执行若干不同的功能，包括时间序列建模、事实存储、话语管理、类似检索的回忆以及风格化表层生成。这种功能的集中化虽然在大规模下提升了通用性，但也使得模型的更新、归因和控制变得更加复杂。一系列关于检索增强的重要工作表明，生成过程中一部分信息负担可以从可微参数转移到外部记忆，具体包括显式的检索增强生成[^1]、检索增强预训练[^2] [^3]、最近邻语言建模[^2]以及上下文检索增强语言模型[^4]。关于外部记忆的相关研究进一步指出，长文本语言建模可以从远超局部处理上下文大小的记忆中显著获益。[^5] [^6] [^7]

另一条研究路线则将状态空间模型确立为长序列建模的一种有竞争力的基础架构。从 HiPPO 和结构化状态空间模型[^8] [^9]开始，该领域的研究逐渐发展到选择性状态空间模型，以及更近期的 Mamba 系列[^10] [^11] [^12]。Mamba 在线性时间复杂度的骨干网络中引入了选择性状态更新。[^10] [^11] Mamba-2 通过结构化状态空间对偶性重新表述了该架构。[^9] Mamba-3 则将设计重点进一步转向面向推理的序列建模和硬件效率。[^10] [^11] [^12] 这些发展表明，状态空间骨干网络非常适合时间控制、上下文压缩和序列规划任务。[^8] [^9] [^10] [^11] [^12]

本文提议，应将上述两条路线与第三个要素相结合：一个为结构化绑定和推理设计的规范内部内容空间。我们将此空间称为**思维语**（Mentalese）。在本提案中，思维语通过傅里叶全息缩减表征（FHRR）实例化，后者利用高维复值向量提供分布式符号组合能力。核心的设计选择是将内容保持在一个显式的表征域中，同时将时间控制分配给一个独立的 Mamba-3 核心。随后，检索被附加到同一个规范内容空间上，而不是直接附加到原始表层词元或不透明循环激活状态上。

其成果便是 Project TRITON v0.5，一个包含四个主要组件的模块化架构：

- 一个 Mamba-3 控制核心，
- 一个基于 FHRR 的思维语核心，
- 一个具有可分离知识、词汇和风格记忆的检索结构，
- 以及一个用于解析和实现的两阶段表层界面。

本文的目标是架构性的，而非实证性的。我们并非声称整个系统已经得到了验证。相反，我们旨在定义一个连贯的研究计划，将状态空间序列控制、显式分布式符号结构以及检索接地语言生成结合在一个统一的接口下。

## 背景与动机

### 状态空间模型作为时间控制器

现代状态空间建模始于 HiPPO 和结构化状态空间模型[^8] [^9]，它们为高效序列处理引入了基于连续时间和长序列的原则性公式。随后关于选择性状态空间模型的工作证明，当状态更新以输入为条件时，线性时间序列模型可以保持其表达能力。[^9] [^10] [^11] [^12] Mamba 及其后续工作为从状态空间理论到语言建模铺平了一条实践道路。[^9] [^10] [^11] [^12] Mamba-2 将这些模型与结构化序列层更广泛的对偶视角联系起来。[^9] Mamba-3 进一步将设计推向"推理优先"的序列建模。[^10] [^11] [^12]

对于当前架构而言，其主要启示在于功能性。一个 Mamba-3 级别的骨干网络是时间组织、路由、上下文压缩和实现规划的可行候选者。这个角色与规范内容存储的角色是不同的。这种区别对于本文提出的架构至关重要。

### 检索与外部记忆

大量工作表明，语言模型能从显式访问外部记忆中获益。[^1] [^2] [^3] 检索增强生成（RAG）在知识密集型任务中将参数化生成与非参数化文档检索分离。[^1] [^13] 关于检索增强预训练[^2] [^3]、最近邻语言建模[^2]、上下文检索增强语言模型[^4]以及对无关检索上下文鲁棒性的相关研究[^14]证明，检索能够影响生成的质量和可控性。[^13]

外部记忆在标准 RAG 设置之外的长文本序列建模中也得到了研究。[^5] [^15] [^16] 在书籍、长网页文档、数学论文、源代码和形式化证明上的结果表明，显式记忆能显著降低困惑度[^5] [^15] [^16]，一开始较小的记忆容量就能带来巨大提升，随后随着记忆容量的增加，增益虽小但持续存在。[^5] [^15] [^16] 同一研究还进一步区分了外部记忆与可微参数，指出单个记忆项可以被直接更新，而参数化事实仍然纠缠在权重内部。[^6] [^7]

这些观察结果促成了 TRITON 中的检索结构。本提案将传统的基于事实的检索扩展到更广泛的因子化形式，即分为知识检索、词汇检索和风格检索。

### 为何需要规范的内部内容空间

模块化语言架构中一个反复出现的问题是表征不匹配。检索到的证据可能以文本、嵌入或非结构化键值状态的形式到达。控制模块维护着它们自身的隐藏状态。符号推理模块（如果存在）则通常使用第三种表征形式。每一个边界都会引入投影损失。

本文的核心假设是，如果所有承载内容的信息都在一个单一的规范内部空间中被表征，那么这种损失就可以被减少。我们将这个空间称为思维语。在 TRITON 中，思维语并非对认知的哲学主张，而是一个关于接口设计的系统主张：一个单一的内部表征可以简化模块间的交互、监督和可解释性。

## 相关工作

### 状态空间与循环序列建模

TRITON 与循环模型和状态空间模型直接相关，包括 LSTM 式的门控机制[^17]、HiPPO 和 S4[^8] [^9]、选择性状态空间模型、Mamba、Mamba-2 和 Mamba-3。[^9] [^12] 它也与近期关于长序列 SSM 扩展[^18]、保留网络（Retentive Networks）、RWKV 式循环模型、门控线性循环模型以及混合状态空间系统的工作相邻。[^12] [^19] [^20] [^21]

本提案与上述文献的一个不同之处在于：它不试图让状态空间骨干网络本身成为事实、符号关系和表层实现知识的唯一存储库。相反，它将骨干网络的角色收窄至时间控制和实现规划。

### 检索增强语言建模

TRITON 的检索组件与 RAG[^1] [^13]、检索增强预训练[^2] [^3]、上下文检索增强语言模型[^4]、最近邻语言模型[^2]、选择性增强[^14]以及关于在无关检索上下文下保持鲁棒性的工作[^14] [^22]相关。关键区别在于，TRITON 并不将检索视为单一、整体的记忆来源。它在一个共享的内部表征下，将事实检索、词汇检索和风格检索分离开来。

### 外部记忆与记忆增强模型

TRITON 同样与关于长文本语言建模的显式外部记忆[^5] [^6] [^17] [^18]、大型记忆层、可自我更新的大型语言模型以及测试时记忆系统的工作相关。TRITON 的独特之处在于，它提议将符号工作记忆和检索结果都通过同一内容层进行路由，而不是通过单一的隐藏状态基底。

### 神经符号与结构化内部表征

基于 FHRR 的思维语核心将 TRITON 置于更广泛的神经符号传统之中。本文中傅里叶全息表征的具体用法被提议为统一内容编码、近似变量绑定和可逆角色查询的一种架构选择。目前的工作并未假设 FHRR 单独就能解决通用推理问题。它使用 FHRR 作为一个表征基底，可以在其上定义显式的推理算子。

## 架构概览

Project TRITON v0.5 由四个主要子系统组成。

1. **表层界面。**
   该模块将面向用户的语言解析为规范内容结构，并将规范内容实现回面向用户的文本。

2. **第一层：Mamba-3 控制核心。**
   该模块维护时间状态、压缩局部上下文、路由检索、排序内容并规划表层实现。

3. **第二层：FHRR 思维语核心。**
   该模块存储规范内容、支持角色-填充项绑定、维护工作和情景记忆，并执行结构化推理操作。

4. **第三层：检索结构。**
   该模块从三个存储中提供外部检索：知识记忆、词汇记忆和风格记忆。

设计原则很简单：**内容存在于思维语中；控制存在于 Mamba 状态中；外部证据通过检索进入，并在影响生成之前被重新编码为思维语。**

## 思维语表征

### 规范内容向量

令 $m_t \in \mathbb{C}^D$ 表示在步骤 $t$ 时的规范思维语表征，其中 $D$ 是一个高维复向量空间。在 FHRR 设定下，每个维度都位于复单位圆上或附近。

该表征使用四类基元：

- 概念向量，
- 角色向量，
- 结构向量，
- 控制或查询向量。

一个角色-填充项事件框架定义为：

$$ m_t = \text{AGENT} \otimes a_t \oplus \text{ACTION} \otimes u_t \oplus \text{PATIENT} \otimes p_t \oplus \text{TIME} \otimes \rho_t(\tau_t) $$

其中，$\otimes$ 表示绑定，$\oplus$ 表示捆绑或叠加，$\rho_t$ 表示置换或位置相关的变换。

通过解绑操作可以近似地查询角色：

$$ \hat{a}_t = m_t \oslash \text{AGENT} $$

其中 $\oslash$ 表示逆角色解绑。

### 工作记忆与情景记忆

思维语核心维护两个记忆池：

- $M_{\text{work}}$ 用于当前任务状态，
- $M_{\text{epi}}$ 用于持久的话语和叙事状态。

它们的更新规则抽象地写为：

$$ M_t = M_{t-1} \oplus w_t, $$

其中 $w_t$ 是一个新编码的事件、检索结果或导出的命题。这种形式允许用户输入、检索到的证据、符号绑定和内部规划共用一条单一的表征路径。

### 为何在此选择 FHRR

选择 FHRR 是基于表征的便利性。一个复数值的分布式绑定空间与内部、语言无关的内容表征理念自然地吻合。本文并非声称 FHRR 是唯一正确的选择，而是声称 FHRR 是组合性内容、分布式记忆和结构化检索接口的一个可行的统一基底。

## Mamba-3 作为控制核心

### 功能分配

TRITON 将以下职责分配给 Mamba-3：

- 时间状态演化，
- 局部话语压缩，
- 检索路由，
- 内容调度，
- 句子级实现规划，
- 生成期间的流畅性稳定。

它不将事实存储或完整的符号闭包分配给 Mamba 骨干网络。这种角色限制是有意为之，它使得 Mamba 状态保持紧凑和功能性，而非要求其承载系统的全部语义负载。

### 思维语到控制的接口

令 $z_t$ 表示 Mamba 控制状态，并令 $P_{\text{down}}$ 为从思维语到控制空间的投影。循环更新公式为：

$$ z_t = f_\theta(z_{t-1}, P_{\text{down}}(m_t)). $$

控制状态反过来可以通过一个向上的投影生成规划提示到思维语中：

$$ \tilde{m}_t = P_{\text{up}}(z_t). $$

向上投影不会替代 $m_t$，它仅对优先级排序、顺序安排和实现控制做出贡献。

### 诠释

在此公式下，Mamba-3 充当的是内容之上的时间控制器，而非内容本身。这种选择旨在减少序列压缩与结构化推理之间的相互干扰。

## 检索结构

### 三个检索存储

TRITON 将外部检索因子化为三个存储。

**知识存储。**
该存储包含事实性的、百科性的、领域特定的以及具有时效性的材料。

**词汇存储。**
该存储包含词汇实现、搭配、次范畴化模式、功能词偏好、量词、话语连接词和习语结构。

**风格存储。**
该存储包含语域标记、体裁制约的措辞、韵律模板、意象集群和修辞偏好。

检索因子化的动机直接源自先前的检索工作和外部记忆发现。如果外部记忆能改进长文本建模[^5] [^6] [^7]，并且不同形式的信息对参数模型造成的负担不同[^1] [^2] [^3]，那么检索系统就不必局限于事实性段落。

### 检索策略

令 $q_t$ 表示思维语中的当前查询，$z_t$ 表示 Mamba 控制状态。路由策略为：

$$ \pi_t = \text{softmax}(W_r [P_{\text{down}}(q_t); z_t]). $$

所得权重在三个存储之间进行选择：

$$ r_t = \pi_t^K r_t^K \oplus \pi_t^L r_t^L \oplus \pi_t^S r_t^S. $$

检索到的材料随后被重新编码到思维语中，并合并到记忆里：

$$ M_t = M_{t-1} \oplus r_t. $$

此过程确保所有检索到的内容在影响下游生成之前都处于规范表征之内。

## 两阶段表层实现

### 动机

一个检索丰富的架构，如果直接将检索到的文本片段插入表层流中，可能会产生类似拼接片段或翻译腔的输出。关于检索质量和鲁棒性的先前工作已经表明，无关的或压缩不佳的检索上下文可能损害生成质量。[^14] [^22] 因此，TRITON 将**内容规划**与**表层实现**分离开来。

### 阶段 A：内容规划

第一阶段产生一个思维语计划：

$$ p_t = \text{PLAN} \otimes m_t \oplus \text{STYLE} \otimes s_t \oplus \text{FOCUS} \otimes f_t $$

该表征指定了应说什么、以何种顺序、以何种详细程度以及在何种风格语域下表达。

### 阶段 B：形态句法实现

第二阶段将思维语计划转换为自然语言。此阶段由 Mamba-3 控制，并受到词汇和风格存储的约束。其目标是产生符合语言习惯的实现，而非直接输出检索结果。

这种两阶段设计服务于两个目的：

- 它减少了来自检索片段的直接表层污染，
- 它允许流畅性控制保持局部化和顺序性。

词汇存储在此处尤为重要。一个事实性命题在思维语层面可以是稳定的，但仍可允许多种表层实现。词汇存储解决了与事实真值无关的局部自然度问题。

## 训练目标

训练目标是多组分的：

$$ L_{\text{total}} = \lambda_1 L_{\text{parse}} + \lambda_2 L_{\text{align}} + \lambda_3 L_{\text{retrieve}} + \lambda_4 L_{\text{reason}} + \lambda_5 L_{\text{realize}} + \lambda_6 L_{\text{style}}. $$

### 解析损失

$L_{\text{parse}}$ 监督从面向用户输入到规范内容结构的映射。

### 对齐损失

为了将控制状态与规范内容空间对齐，我们使用了一个结合幅度和方向误差的混合损失：

$$ L_{\text{align}} = \alpha \text{MSE}(P_{\text{up}}(z_t), m_t^*) + \beta (1 - \cos(P_{\text{up}}(z_t), m_t^*)). $$

此目标约束了 Mamba 控制与思维语之间的接口。

### 检索损失

$L_{\text{retrieve}}$ 监督跨三个存储的查询质量、存储路由和检索排序。

### 推理损失

$L_{\text{reason}}$ 监督对绑定敏感的任务，例如角色恢复、关系组合、排序、比较和一致性检查。

### 实现损失

$L_{\text{realize}}$ 使用标准的序列级语言建模目标加上局部表层约束来监督输出文本。

### 风格损失

$L_{\text{style}}$ 约束语域、韵律、词汇分布和体裁制约的实现。

## 讨论

本文提出的架构基于以下三个赌注。

首先，状态空间骨干网络作为时间控制器可能最有用，而非作为一个单一的整体语义存储。这与状态空间研究向高效长序列处理[^8] [^9]和面向推理设计[^10] [^11] [^12]发展的整体轨迹一致。

其次，检索应被视为一系列记忆功能，而非单一的事实查找机制。现有工作已表明，检索和外部记忆能改进长文本建模[^5] [^6] [^7]和知识密集型生成。[^1] [^2] [^3]

第三，表层流畅性应被视为一个独立的建模问题。系统应在一个空间中确定内容，在另一个空间中实现它，而不是假设仅靠检索或符号结构就能自动产生符合语言习惯的语言。

该架构也存在风险。思维语到控制的桥梁可能成为瓶颈。如果词汇检索过于模板化，可能会过度约束输出。风格检索可能与事实或话语要求相冲突。

至关重要的是，分布式表征在历史上存在一个问题：FHRR 记忆在长序列组合中可能累积噪声（即"噪声雪崩"效应）。然而，我们的单位圆 FHRR 容量实验（总结于表 1）表明，虽然朴素的平坦叠加会因加性噪声而迅速退化，但实现带有中间最近邻清理的分层分块策略能够有效地阻断噪声级联。

**表 1：** 维持 $\ge 80\%$ 召回率的情景记忆容量 ($N_{\text{max}}$)。朴素的平坦记忆快速退化，而带有清理的分层记忆缓解了 FHRR 噪声雪崩问题，使得容量达到 $O(D^{1.8}/N_{\text{roles}})$。

| **维度 ($D$)** | **块大小** | **平坦 $N_{\text{max}}$** | **清理后 $N_{\text{max}}$** |
| :---: | :---: | :---: | :---: |
| 1024 | 32 | 49 | 573 |
| 4096 | 128 | 224 | 4,023 |
| 16384 | 256 | 502 | > 131,072 |

通过利用干净的 $M_{\text{local}}$ 状态进行块内检索，这种去噪步骤完全稳定了序列演化。如表所示，容量随维度呈指数级扩展，成功解决了文档级输入中立即出现的情景记忆瓶颈。其余每个集成问题都是实证性的，需要大规模端到端的消融研究才能充分验证。

## 局限性

本文提出的是一份架构提案，并辅以组件级的 FHRR 容量模拟，而非对整个流程进行端到端的实证验证。若干断言仍有待检验。

- 虽然我们的实验测试解决了孤立的 FHRR 情景记忆中的"噪声雪崩"问题，但 FHRR 作为端到端语言任务中规范的大规模内容表征的适用性仍有待测试。
- Mamba-3 作为实现控制器而不承载过多语义负担的程度如何，仍不确定。
- 检索中的词汇/风格分离是一项设计假设。
- 该系统尚未在长文本生成、检索接地推理或文学风格控制方面建立起基准测试结果。

因此，本文的主要贡献是概念性和架构性的。其完整的实证价值取决于未来的实现与评估。

## 结论

我们提出了 Project TRITON v0.5，这是一种以思维语为中心的神经符号语言架构，它结合了 Mamba-3 控制核心、FHRR 推理与记忆核心，以及用于知识、词汇实现和风格的因子化检索结构。该架构由三条先前的研究路径驱动：状态空间序列建模[^8] [^9]、检索增强生成[^1] [^2] [^3]以及用于长文本语言建模的外部记忆[^5] [^6]。其核心设计选择是使用单一的规范内部表征来承载内容，同时将时间控制分配给专用的状态空间骨干网络。这一表述为结构化记忆、检索接地生成和风格受控的语言生成提供了一个连贯的研究计划。该提案现在需要完整的实证验证。

## 参考文献

[^1]: Patrick Lewis, Ethan Perez, Aleksandra Piktus, Fabio Petroni, Vladimir Karpukhin, Naman Goyal, Heinrich Küttler, Mike Lewis, Wen-tau Yih, Tim Rocktäschel, et al. _Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks_. NeurIPS, 2020.

[^2]: Kelvin Guu, Kenton Lee, Zora Tung, Panupong Pasupat, and Ming-Wei Chang. _Retrieval Augmented Language Model Pre-Training_. ICML, 2020. Urvashi Khandelwal, Omer Levy, Dan Jurafsky, Luke Zettlemoyer, and Mike Lewis. _Generalization through Memorization: Nearest Neighbor Language Models_. ICLR, 2020.

[^3]: Retrieval-augmented language model pre-training and related retrieval literature listed in the retrieval survey material. arXiv:2310.11511.

[^4]: Ori Ram, Yoav Levine, Itay Dalmedigos, Dor Muhlgay, Amnon Shashua, Kevin Leyton-Brown, and Yoav Shoham. _In-Context Retrieval-Augmented Language Models_. TACL, 2023.

[^5]: _Published as a conference paper at ICLR 2022._ External-memory language modeling results on PG-19, C4, arXiv Math, Github, and Isabelle, showing significant perplexity improvements from explicit memory over long-form text.

[^6]: External-memory language modeling discussion distinguishing editable memory items from differentiable model parameters. arXiv:2203.08913.

[^7]: Analysis of retrieved references, function names, and long-range retrieval behavior in external-memory language modeling. arXiv:2203.08913.

[^8]: Albert Gu, Tri Dao, Stefano Ermon, Atri Rudra, and Christopher Ré. _HIPPO: Recurrent Memory with Optimal Polynomial Projections_. NeurIPS, 2020. Albert Gu, Karan Goel, and Christopher Ré. _Efficiently Modeling Long Sequences with Structured State Spaces_. ICLR, 2022.

[^9]: Albert Gu, Karan Goel, and Christopher Ré. _Efficiently Modeling Long Sequences with Structured State Spaces_. ICLR, 2022. Albert Gu, et al. additional state-space model references listed in Mamba-2. arXiv:2405.21060.

[^10]: _Mamba-3 reference list and associated state-space literature._ arXiv:2603.15569.

[^11]: Mamba-3 reference list including Query-Key Normalization, RoFormer, and numerical analysis references. arXiv:2603.15569.

[^12]: Mamba-3 reference list including Retentive Networks and test-time training with expressive hidden states. arXiv:2603.15569.

[^13]: Retrieval literature cited by the original RAG paper, including neural-symbolic workshop references and passage reranking. arXiv:2005.11401.

[^14]: Fangyuan Xu, Weijia Shi, and Eunsol Choi. _ReComp: Improving Retrieval-Augmented LMs with Compression and Selective Augmentation_. 2023. Ori Yoran, Tomer Wolfson, Ori Ram, and Jonathan Berant. _Making Retrieval-Augmented Language Models Robust to Irrelevant Context_. 2023.

[^15]: External-memory language modeling datasets including Isabelle formal mathematics and long-context evaluation. arXiv:2203.08913.

[^16]: Long-input statistics for arXiv Math, Github, Isabelle, and PG-19 from the external-memory language modeling paper. arXiv:2203.08913.

[^17]: Felix A. Gers, Jürgen Schmidhuber, and Fred Cummins. _Learning to Forget: Continual Prediction with LSTM_. Neural Computation, 2000.Alex Graves, Greg Wayne, and Ivo Danihelka. _Neural Turing Machines_. arXiv, 2014.

[^18]: Shida Wang. _LongSSM: On the Length Extension of State-Space Models in Language Modelling_. arXiv, 2024.

[^19]: Hybrid state-space foundation model references, including B'MOJO. arXiv:2501.00663.

[^20]: _State Space Augmented Transformer_ and related efficient sequence modeling references. arXiv:2403.19887.

[^21]: Mamba-2 reference list including CosFormer, TransNormerLLM, and gated recurrent alternatives. arXiv:2405.21060.

[^22]: Alex Mallen, Akari Asai, Victor Zhong, Rajarshi Das, Daniel Khashabi, and Hannaneh Hajishirzi. _When Not to Trust Language Models: Investigating Effectiveness of Parametric and Non-Parametric Memories_. ACL, 2023.