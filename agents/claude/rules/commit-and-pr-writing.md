## Commit messages and pull request descriptions

- NEVER add a `Co-Authored-By: Claude ...` trailer to a commit message.
- NEVER add the `🤖 Generated with [Claude Code]` footer to a pull request body.
- End both on the last line of real content: no attribution boilerplate.
- Keep them self-contained. A reviewer should not need the conversation that produced the change, so do not reference the session, the iterations it took, or how the approach was arrived at. Describe the code as it now stands and why.

### Wrapping

Punctuation and where to break a line are covered by the writing style rules. What is specific here is which of the two is wrapped at all.

- Wrap commit message bodies conventionally.
- Do NOT wrap pull request descriptions. Write each paragraph as one continuous line and let the renderer wrap it: hard breaks fight GitHub's markdown renderer and make later edits to the description noisy.
- When a commit message doubles as the pull request body, unwrapped wins. The PR rendering is what matters, so do not keep the wrapping on the grounds that it is also a commit message.
- Headings, list items and genuinely short sentences stay on their own lines. Only paragraph-internal breaks are joined. Watch for punctuation that only parsed as a line break once joined, such as a comma standing in for a break mid-clause.
