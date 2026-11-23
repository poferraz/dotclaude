# Research behind the configuration

These five papers influenced the project's early design. The repository has no controlled performance comparison for the complete configuration. Its install and export checks cover file behavior.

| Study | What it examined and how it relates |
| --- | --- |
| Gloaguen and colleagues | On the coding tasks studied, repository context files generally did not improve completion and increased inference costs on average. The maintainer chose to keep shared preferences short and move task-specific detail into separate files. [Paper](https://arxiv.org/abs/2602.11988) |
| Cao, Jiang and Xu | Disclosing a downstream financial prediction goal changed the model's intermediate measurements. The study concerns financial predictions. It does not measure the benefit of stating acceptance criteria in a software project. [Paper](https://arxiv.org/abs/2602.09504) |
| Hu, Rostami and Thomason | Persona prompting varied with the task, model and prompt design. The repository experimented with brief descriptions tailored to each agent's job. [Paper](https://arxiv.org/abs/2603.18507) |
| Geng and colleagues | Models struggled to prioritize conflicting instructions, even in formatting tasks. The paper motivated experiments with how constraints were presented. Host permissions remain necessary for controlling tool access. [Paper](https://arxiv.org/abs/2502.15851) |
| Mahmoudi and colleagues | The researchers catalogued problems in systems that integrate LLM inference. Some included skills use structured output to help readers interpret a result. Whether a consumer can parse it depends on its own validation. [Paper](https://arxiv.org/abs/2512.18020) |

If a paper changes a specific design decision, link the original source and describe what should change. [Research update template](../.github/ISSUE_TEMPLATE/research_update.md)
