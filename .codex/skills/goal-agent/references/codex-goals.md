# Codex Goals Notes

- `codex features list` reports `goals` as `under development` and disabled by default.
- `codex exec --enable goals "<prompt>"` enables the goals feature for that child process only.
- `codex features enable goals` persists the feature flag in the user's Codex config, but this project skill does not modify global config by default.
- This skill uses `codex exec --ephemeral` by default so child sessions are not persisted in the normal Codex session store.
- Without `--enable goals`, `/goal ...` is treated as ordinary user text by Codex CLI.
- With `--enable goals`, observed behavior treats `/goal ...` as a goal-oriented request while the text remains visible to the model.
