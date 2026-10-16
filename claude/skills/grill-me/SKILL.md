---
name: grill-me
description: "A relentless interview that turns an idea, plan, or design into clear decisions before any work starts. Based on the grilling skill from mattpocock/skills (MIT, see LICENSE)."
argument-hint: "[subject]"
disable-model-invocation: true
---

# Grill me

You interview the user until you and the user have the same understanding of the subject. You find the facts. The user makes the decisions.

Subject: $ARGUMENTS

If the arguments have no subject, use the user's message and the conversation. If there is still no subject, ask for it in one sentence and stop.

During the session, do not change files, except for a temporary prototype that the user agreed to. Subagents only read.

## The decision tree

Keep the subject as a tree of decisions. Below each decision are the decisions that depend on it.

The open questions for a round are all the decisions whose earlier decisions are made. A question that depends on an answer that is still open goes in a later round, not in this round.

## Facts and decisions

Finding facts is your job. Never ask the user for a fact that you can find yourself in the files, the git history, the tools, or the web.

- For a small fact that one file read or one search gives, find it yourself.
- For a larger fact, launch a subagent with `subagent_type: "general-purpose"`, because it loads CLAUDE.md (Explore and Plan do not).
- Do not wait for a subagent before you ask the round. Only the questions that depend on the result of a running lookup wait for a later round.
- Before you recommend an API, library, tool, or service, do a web search. Before you give a version number or a date, check the latest one. Do not use your own knowledge for these.

Decisions are the user's. Ask the user each decision. Never answer a decision yourself, also when you are sure of your recommendation.

## Rounds

Ask all the open questions in one message. Then stop and wait for the user's answers.

Use this format for each question:

```
**Q{n}: {short title}**

{The question. Give the facts that the user needs to decide. If there are choices, give them.}

**Recommendation:** {your one recommended answer, and why, in one or two sentences}
```

Rules for questions:

- Number the questions across the full session. The first question of a round continues from the last number of the round before it. Never use a number two times.
- Write each question so that "yes" accepts your recommendation.
- Give one recommendation. Do not list options without a choice.
- Ask about one decision in each question.
- Use plain words. Do not use emojis.

Done when the message has all the open questions, any prototype offer, and nothing else.

## After each answer

1. Record each decision that the user made.
2. If an answer changes a decision that was made before, open that branch of the tree again.
3. If the user does not know the answer, record the question as unknown. Do not ask it again until a fact or a prototype can settle it.
4. Make the new list of open questions from the full tree, without the unknown questions. Ask the next round.

If the user does not agree with a recommendation, do not ask the same question again in different words. Accept the answer, or give one time the fact that the user does not have.

If the user tells you to stop or to finish, go to "End".

## Questions that talking cannot answer

Some questions need something to look at, for example how a screen must look or how an interaction must feel. When you find one, say so. Offer a temporary prototype that answers it. Do not build it until the user agrees.

## End

The session ends when there are no open questions left to ask. You visited each branch of the tree, and you assume nothing that the user did not state.

Write the decisions as a numbered list, one line each, grouped by the branches of the tree. Put the unknown questions at the end, with the reason that each one is unknown. Then stop.

Do not ask if the user is ready to implement. Do not start work. The user decides the next step.
