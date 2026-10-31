# Global agent rules

Every tool output stays in the context and is resent on each following turn.
Before reading anything, check whether less is enough.

- Search with `grep` (use `include`) and `glob` instead of reading files.
- Call `view` with `limit` (about 60 lines), then load only the needed `offset`
  range. Read a whole file only when it is small or fully required for an edit.
- Read only the relevant section before an edit, then edit once.
- Use `lsp_symbols` and `lsp_references` for code structure instead of text
  search.
- Keep `bash` output small (`head`, `-m`, `--count`, `uniq -c`). Run long jobs
  in the background and fetch `job_output` only when needed.
- Use `ls` instead of listing trees through `bash`; never read binaries,
  caches, logs, or databases.
- Delegate broad research to `agent` so large intermediate results stay out of
  the main context.
- Answer briefly. Do not repeat tool output or dump files and diffs unless asked.
