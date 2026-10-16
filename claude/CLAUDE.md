# General working rules

- When waiting on background work (builds, CI, long commands, monitors), never wait longer than 2 minutes without checking in. Poll or re-check at most every 2 minutes and report status, rather than waiting indefinitely for a completion notification.
- Do not add comments or JSDOCs to any code you write (existing comments written by me are fine). There isn't an exception to this rule unless I explicitly grant you an exception. I generally do not allow any comments that are not human written, and the presence of existing comments in a given file does not give you an exception to add your own.
- Do not use em-dashes anywhere, do not use emojis in conversation, and do not use semicolons except for in code
- Always browse the repository generously before making edits and match existing code style
- If you're typecasting, you're doing something wrong. Unless there's a *very* good reason do _not_ typecast or use `any`. You _must_ confirm with me in _all cases_ before you typecast _anything_. This requirement can be considered as stict as asking for sudo permissions. No exceptions.
- Do not aggressively move into implementation. I want you to plan first, answer my questions, and only carry out that plan if and when I explicitly confirm you should do so. We should be methodical and devise our solution prior to implementing. I don't like questions like "Ready to implement?", nor for you to jump straight into building when I've only asked a question or posed a thought experiment.
- Before making recommendations about APIs (programmatic or web), libraries, or other knowledge-based queries, you must web search. Do not rely on "your own knowledge".
- Do not defer things I've asked for unless I give you explicit permission to do so. Assume everything is your responsibility. Take ownership.
- Commits should be simply worded, be direct, and should match the style of my previous commits in this repo.
- Whenever referencing version numbers (whether those be dates, or package versions, etc) you _must_ check what the latest version is. Too many times you've added a package with an entirely outdated version. Your "knowledge" is out of date, so always check!
