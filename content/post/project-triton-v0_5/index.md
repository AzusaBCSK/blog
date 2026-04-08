---
title: "Project TRITON v0.5: A State-Space Controlled, Retrieval-Grounded Architecture with a Canonical Mentalese Core"
date: "2026-04-07"
desc: "A neuro-symbolic language architecture combining Mamba-3 control, factorized retrieval, and a canonical FHRR-based internal representation."
categories: [
    "Note",
]
math: true
---
> **Abstract.**  
> This paper proposes Project TRITON v0.5, a neuro-symbolic language architecture that integrates three complementary design principles. First, a Mamba-3 state-space backbone provides temporal control, context compression, and realization planning. Second, a factorized retrieval fabric separates knowledge, lexical, and stylistic memory, shifting informational burden from parametric weights to external stores. Third, a canonical internal content space—termed _Mentalese_ and instantiated via Fourier Holographic Reduced Representations (FHRR)—provides a unified substrate for structured binding, working memory, and retrieval grounding. The architecture is organized as a four-part system: a Mamba-3 control core, an FHRR Mentalese core, a retrieval fabric, and a two-stage surface interface. We describe the representational assumptions, module interfaces, training objectives, and open empirical questions required to evaluate this state-space controlled, retrieval-grounded framework.

**Keywords:** state-space models; Mamba; neuro-symbolic systems; retrieval-augmented generation; vector symbolic architectures; hyperdimensional computing; surface realization; Mentalese

---

## Introduction

Large language models are currently expected to perform several distinct functions within a single parametric backbone, including temporal sequence modeling, factual storage, discourse management, retrieval-like recall, and stylistic surface production. This concentration of functions improves generality at scale, yet it also complicates updating, attribution, and control. A substantial line of work on retrieval augmentation has shown that some of the informational burden of generation can be moved from differentiable parameters to external memory, including explicit retrieval-augmented generation[^1], retrieval-augmented pretraining[^2] [^3], nearest-neighbor language modeling[^2], and in-context retrieval-augmented language models[^4]. Related work on external memory further indicates that long-form language modeling can benefit substantially from memory sizes that exceed the local processing context by large margins.[^5] [^6] [^7]

A second line of work has established state-space models as a competitive substrate for long-sequence modeling. Starting from HiPPO and structured state-space models[^8] [^9], this literature developed toward selective state-space models and, more recently, toward the Mamba family[^10] [^11] [^12]. Mamba introduced selective state updates in a linear-time backbone.[^10] [^11] Mamba-2 re-expressed the architecture through structured state-space duality.[^9] Mamba-3 shifted the design emphasis further toward inference-oriented sequence modeling and hardware efficiency.[^10] [^11] [^12] These developments suggest that a state-space backbone is well suited to temporal control, context compression, and sequential planning.[^8] [^9] [^10] [^11] [^12]

This paper proposes that these two lines should be combined with a third ingredient: a canonical internal content space designed for structured binding and reasoning. We term this space _Mentalese_. In the present proposal, Mentalese is instantiated through Fourier Holographic Reduced Representations (FHRR), which provide distributed symbolic composition through high-dimensional complex-valued vectors. The central design choice is to keep content in one explicit representational domain while assigning temporal control to a separate Mamba-3 core. Retrieval is then attached to the same canonical content space rather than to raw surface tokens or opaque recurrent activations.

The result is Project TRITON v0.5, a modular architecture with four principal components:

- a Mamba-3 control core,
- an FHRR-based Mentalese core,
- a retrieval fabric with separable knowledge, lexical, and style memory,
- and a two-stage surface interface for parsing and realization.

The goal of the paper is architectural rather than empirical. We do not claim that the full system has already been validated. We instead define a coherent research program for combining state-space sequence control, explicit distributed symbolic structure, and retrieval-grounded language generation under a unified interface.

## Background and Motivation

### State-space models as temporal controllers

The modern state-space modeling line begins with HiPPO and structured state-space models[^8] [^9], which introduced principled continuous-time and long-sequence formulations for efficient sequence processing. Later work on selective state-space models demonstrated that linear-time sequence models can remain expressive when state updates are conditioned on the input.[^9] [^10] [^11] [^12] Mamba and its follow-up work established a practical path from state-space theory to language modeling.[^9] [^10] [^11] [^12] Mamba-2 connected these models to a broader dual view of structured sequence layers.[^9] Mamba-3 pushed the design further toward inference-first sequence modeling.[^10] [^11] [^12]

For the present architecture, the main implication is functional. A Mamba-3-class backbone is a plausible candidate for temporal organization, routing, context compression, and realization planning. This role differs from the role of a canonical content store. The distinction is central to the architecture proposed here.

### Retrieval and external memory

A large body of work has shown that language models benefit from explicit access to external memory.[^1] [^2] [^3] Retrieval-Augmented Generation separated parametric generation from non-parametric document retrieval in knowledge-intensive tasks.[^1] [^13] Related work on retrieval-augmented pretraining[^2] [^3], nearest-neighbor language modeling[^2], in-context retrieval-augmented language models[^4], and robustness to irrelevant retrieved context[^14] demonstrated that retrieval can influence both quality and controllability of generation.[^13]

External memory has also been studied in long-form sequence modeling outside the standard RAG setting.[^5] [^15] [^16] Results on books, long web documents, mathematical papers, source code, and formal proofs showed that explicit memory improves perplexity substantially[^5] [^15] [^16], with initial large gains from modest memory sizes followed by smaller but persistent gains as the memory size increases.[^5] [^15] [^16] The same work further distinguishes external memory from differentiable parameters, noting that individual memory items can be updated directly while parametric facts remain entangled inside weights.[^6] [^7]

These observations motivate the retrieval fabric in TRITON. The proposal extends conventional factual retrieval toward a broader factorization into knowledge retrieval, lexical retrieval, and style retrieval.

### Why a canonical internal content space

A recurrent problem in modular language architectures is representational mismatch. Retrieved evidence may arrive as text, as embeddings, or as unstructured key-value states. Control modules maintain their own hidden states. Symbolic reasoning modules, where present, often use a third representation altogether. Each boundary introduces projection loss.

The central hypothesis of this paper is that such loss can be reduced if all content-bearing information is represented in a single canonical internal space. We call this space Mentalese. In TRITON, Mentalese is not intended as a philosophical claim about cognition. It is a systems claim about interface design: a single internal representation may simplify module interaction, supervision, and interpretability.

## Related Work

### State-space and recurrent sequence modeling

TRITON is directly related to recurrent and state-space models, including LSTM-style gating[^17], HiPPO and S4[^8] [^9], selective state-space models, Mamba, Mamba-2, and Mamba-3.[^9] [^12] It is also adjacent to recent work on long-sequence SSM extension[^18], retentive architectures, RWKV-style recurrent models, gated linear recurrent models, and hybrid state-space systems.[^12] [^19] [^20] [^21]

The present proposal differs from that literature in one respect. It does not attempt to make the state-space backbone itself the sole repository of facts, symbolic relations, and surface realization knowledge. Instead, it narrows the role of the backbone to temporal control and realization planning.

### Retrieval-augmented language modeling

The retrieval component of TRITON is related to RAG[^1] [^13], retrieval-augmented pretraining[^2] [^3], in-context retrieval-augmented language models[^4], nearest-neighbor language models[^2], selective augmentation[^14], and work on robustness under irrelevant retrieved context.[^14] [^22] The key difference is that TRITON does not treat retrieval as a single monolithic memory source. It separates factual, lexical, and stylistic retrieval under a shared internal representation.

### External memory and memory-augmented models

TRITON is also connected to work on explicit external memory for long-form language modeling[^5] [^6] [^17] [^18], large memory layers, self-updatable large language models, and test-time memory systems. What distinguishes TRITON is the proposal to route both symbolic working memory and retrieval results through the same content layer rather than through a single hidden-state substrate.

### Neuro-symbolic and structured internal representations

The FHRR-based Mentalese core places TRITON within a broader neuro-symbolic tradition. The specific use of Fourier holographic representations in this paper is proposed as an architectural choice for unified content encoding, approximate variable binding, and reversible role queries. The present work does not assume that FHRR alone solves general reasoning. It uses FHRR as a representational substrate on which explicit reasoning operators can be defined.

## Architecture Overview

Project TRITON v0.5 consists of four principal subsystems.

1. **Surface Interface.**
   This module parses user-facing language into canonical content structures and realizes canonical content back into user-facing text.

2. **Layer 1: Mamba-3 Control Core.**
   This module maintains temporal state, compresses local context, routes retrieval, orders content, and plans surface realization.

3. **Layer 2: FHRR Mentalese Core.**
   This module stores canonical content, supports role-filler binding, maintains working and episodic memory, and executes structured reasoning operations.

4. **Layer 3: Retrieval Fabric.**
   This module provides external retrieval from three stores: knowledge memory, lexical memory, and style memory.

The design principle is simple: **content lives in Mentalese; control lives in Mamba state; external evidence enters through retrieval and is re-encoded into Mentalese before it affects generation.**

## Mentalese Representation

### Canonical content vectors

Let $m_t \in \mathbb{C}^D$ denote the canonical Mentalese representation at step $t$, where $D$ is a high-dimensional complex vector space. In the FHRR setting, each dimension lies on or near the complex unit circle.

The representation uses four classes of basis elements:

- concept vectors,
- role vectors,
- structure vectors,
- control or query vectors.

A role-filler event frame is defined as

$$ m_t = \text{AGENT} \otimes a_t \oplus \text{ACTION} \otimes u_t \oplus \text{PATIENT} \otimes p_t \oplus \text{TIME} \otimes \rho_t(\tau_t) $$

Here $\otimes$ denotes binding, $\oplus$ denotes bundling or superposition, and $\rho_t$ denotes permutation or position-dependent transformation.

A role can be queried approximately by unbinding:

$$ \hat{a}_t = m_t \oslash \text{AGENT} $$

where $\oslash$ denotes inverse-role unbinding.

### Working memory and episodic memory

The Mentalese core maintains two memory pools:

- $M_{\text{work}}$ for current task state,
- $M_{\text{epi}}$ for persistent discourse and narrative state.

Their update rule is written abstractly as

$$ M_t = M_{t-1} \oplus w_t, $$

where $w_t$ is a newly encoded event, retrieval result, or derived proposition. This formulation permits a single representational path for user input, retrieved evidence, symbolic bindings, and internal planning.

### Why FHRR here

The choice of FHRR is motivated by representational convenience. A complex-valued distributed binding space aligns naturally with the idea of an internal, language-independent content representation. The paper does not claim that FHRR is uniquely correct. It claims that FHRR is a plausible unifying substrate for compositional content, distributed memory, and structured retrieval interfaces.

## Mamba-3 as a Control Core

### Functional assignment

TRITON assigns the following responsibilities to Mamba-3:

- temporal state evolution,
- local discourse compression,
- retrieval routing,
- content scheduling,
- sentence-level realization planning,
- fluency stabilization during generation.

It does not assign factual storage or full symbolic closure to the Mamba backbone. This role restriction is deliberate. It keeps the Mamba state compact and functional rather than requiring it to carry the entire semantic load of the system.

### Mentalese-to-control interface

Let $z_t$ denote the Mamba control state and let $P_{\text{down}}$ be a projection from Mentalese into control space. The recurrent update is

$$ z_t = f_\theta(z_{t-1}, P_{\text{down}}(m_t)). $$

The control state can in turn produce planning hints back into Mentalese through an upward projection:

$$ \tilde{m}_t = P_{\text{up}}(z_t). $$

The upward projection does not replace $m_t$. It only contributes to prioritization, ordering, and realization control.

### Interpretation

Under this formulation, Mamba-3 acts as a temporal controller over content rather than as the content itself. This choice is intended to reduce interference between sequence compression and structured reasoning.

## Retrieval Fabric

### Three retrieval stores

TRITON factorizes external retrieval into three stores.

**Knowledge Store.**
This store contains factual, encyclopedic, domain-specific, and time-sensitive material.

**Lexical Store.**
This store contains lexical realizations, collocations, subcategorization patterns, function-word preferences, classifiers, discourse connectives, and idiomatic constructions.

**Style Store.**
This store contains register markers, genre-conditioned phrasing, rhythm templates, imagery clusters, and rhetorical preferences.

The motivation for retrieval factorization follows directly from prior retrieval work and external-memory findings. If external memory can improve long-form modeling[^5] [^6] [^7] and if different forms of information place different burdens on parametric models[^1] [^2] [^3], then a retrieval system need not be limited to factual passages alone.

### Retrieval policy

Let $q_t$ denote the current query in Mentalese and let $z_t$ denote the Mamba control state. The routing policy is

$$ \pi_t = \text{softmax}(W_r [P_{\text{down}}(q_t); z_t]). $$

The resulting weights select among the three stores:

$$ r_t = \pi_t^K r_t^K \oplus \pi_t^L r_t^L \oplus \pi_t^S r_t^S. $$

The retrieved material is then re-encoded into Mentalese and merged into memory:

$$ M_t = M_{t-1} \oplus r_t. $$

This procedure keeps all retrieved content inside the canonical representation before it affects downstream generation.

## Two-Stage Surface Realization

### Motivation

A retrieval-rich architecture risks producing outputs that resemble stitched fragments or translationese if retrieved text is inserted directly into the surface stream. Prior work on retrieval quality and robustness already suggests that irrelevant or poorly compressed retrieved context can degrade generation.[^14] [^22] TRITON therefore separates **content planning** from **surface realization**.

### Stage A: content planning

The first stage produces a Mentalese plan:

$$ p_t = \text{PLAN} \otimes m_t \oplus \text{STYLE} \otimes s_t \oplus \text{FOCUS} \otimes f_t $$

This representation specifies what should be said, in what order, at what level of explicitness, and under what stylistic register.

### Stage B: morphosyntactic realization

The second stage converts the Mentalese plan into natural language. This stage is controlled by Mamba-3 and constrained by the lexical and style stores. The objective is idiomatic realization rather than direct retrieval emission.

This two-stage design serves two purposes:

- it reduces direct surface contamination from retrieved fragments,
- it allows fluency control to remain local and sequential.

The lexical store is especially important here. A factual proposition may be stable at the Mentalese level while still admitting multiple surface realizations. The lexical store resolves local naturalness questions that are orthogonal to factual truth.

## Training Objective

The training objective is multi-component:

$$ L_{\text{total}} = \lambda_1 L_{\text{parse}} + \lambda_2 L_{\text{align}} + \lambda_3 L_{\text{retrieve}} + \lambda_4 L_{\text{reason}} + \lambda_5 L_{\text{realize}} + \lambda_6 L_{\text{style}}. $$

### Parsing loss

$L_{\text{parse}}$ supervises the mapping from user-facing input to canonical content structures.

### Alignment loss

To align the control state with the canonical content space, we use a mixed loss over magnitude and direction:

$$ L_{\text{align}} = \alpha \text{MSE}(P_{\text{up}}(z_t), m_t^*) + \beta (1 - \cos(P_{\text{up}}(z_t), m_t^*)). $$

This objective constrains the interface between Mamba control and Mentalese.

### Retrieval loss

$L_{\text{retrieve}}$ supervises query quality, store routing, and retrieval ranking across the three stores.

### Reasoning loss

$L_{\text{reason}}$ supervises binding-sensitive tasks such as role recovery, relation composition, ordering, comparison, and consistency checking.

### Realization loss

$L_{\text{realize}}$ supervises the output text with standard sequence-level language modeling objectives plus local surface constraints.

### Style loss

$L_{\text{style}}$ constrains register, rhythm, lexical distribution, and genre-conditioned realization.

## Discussion

The architecture proposed here makes three bets.

First, a state-space backbone may be most useful as a temporal controller rather than as a monolithic semantic store. This is consistent with the broader state-space trajectory toward efficient long-sequence processing[^8] [^9] and inference-oriented design.[^10] [^11] [^12]

Second, retrieval should be treated as a family of memory functions rather than a single factual lookup mechanism. Existing work already shows that retrieval and external memory improve long-form modeling[^5] [^6] [^7] and knowledge-intensive generation.[^1] [^2] [^3]

Third, surface fluency should be treated as a separate modeling problem. The system should determine content in one space and realize it in another, rather than assuming that retrieval or symbolic structure alone will automatically produce idiomatic language.

The proposed architecture also carries risks. The Mentalese-to-control bridge may become a bottleneck. Lexical retrieval may overconstrain output if it is too template-like. Style retrieval may compete with factual or discourse requirements.

Crucially, a historical concern with distributed representations is that FHRR memory may accumulate noise over long compositions (the "noise avalanche"). However, our unit-circle FHRR capacity experiments (summarized in Table 1) demonstrate that while naive flat superposition degrades rapidly due to additive noise, implementing a hierarchical chunking strategy with intermediate nearest-neighbor cleanup effectively breaks the noise cascade.

**Table 1:** Episodic memory capacity ($N_{\text{max}}$) maintaining $\ge 80\%$ recall. Naive flat memory degrades quickly, while hierarchical memory with cleanup mitigates the FHRR noise avalanche, enabling capacity $O(D^18/N_{\text{roles}})$.

| **Dim ($D$)** | **Chunk Size** | **Flat $N_{\text{max}}$** | **Cleanup $N_{\text{max}}$** |
| :---: | :---: | :---: | :---: |
| 1024 | 32 | 49 | 573 |
| 4096 | 128 | 224 | 4,023 |
| 16384 | 256 | 502 | > 131,072 |

By utilizing clean $M_{\text{local}}$ states for within-chunk retrieval, this denoising step completely stabilizes sequence evolution. As shown, capacity scales exponentially with dimension, successfully resolving the immediate episodic memory bottleneck for document-length inputs. Each of the remaining integration issues is empirical and will require large-scale end-to-end ablation to fully validate.

## Limitations

This paper presents an architecture proposal supported by component-level FHRR capacity simulations, rather than an end-to-end empirical validation of the full pipeline. Several claims remain open.

- While our experimental tests resolve the "noise avalanche" for isolated FHRR episodic memory, the suitability of FHRR as a canonical large-scale content representation in an end-to-end language task remains to be tested.
- The degree to which Mamba-3 can serve as a realization controller without carrying too much semantic burden remains uncertain.
- The lexical/style split in retrieval is a design hypothesis.
- The system has not yet established benchmark results on long-form generation, retrieval-grounded reasoning, or literary control.

Accordingly, the primary contribution of this paper is conceptual and architectural. Its full empirical value depends on future implementation and evaluation.

## Conclusion

We proposed Project TRITON v0.5, a Mentalese-centered neuro-symbolic language architecture that combines a Mamba-3 control core, an FHRR reasoning and memory core, and a factorized retrieval fabric for knowledge, lexical realization, and style. The architecture is motivated by three strands of prior work: state-space sequence modeling[^8] [^9], retrieval-augmented generation[^1] [^2] [^3], and external memory for long-form language modeling.[^5] [^6] Its core design choice is to use a single canonical internal representation for content while assigning temporal control to a dedicated state-space backbone. This formulation yields a coherent research program for structured memory, retrieval-grounded generation, and stylistically controlled language production. The proposal now requires full empirical validation.

## References

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