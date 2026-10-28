const compactionThreshold = 250000;
const compactionBuffer = 20000;

function capInputBudgets(editor, models) {
  for (const model of models) {
    if (model.limit.context <= 0) continue;

    editor.update(model.providerID, model.id, (draft) => {
      // OpenCode subtracts its compaction buffer from the model's input limit.
      draft.limit.input = Math.min(
        draft.limit.input ?? Infinity,
        compactionThreshold + compactionBuffer,
      );
    });
  }
}

export default {
  id: "dotfiles.compaction-budget",
  async setup(context) {
    if (context.model) {
      await context.model.transform((editor) => capInputBudgets(editor, editor.list()));
      return;
    }

    await context.catalog.transform((editor) => {
      for (const provider of editor.provider.list()) {
        capInputBudgets(editor.model, provider.models.values());
      }
    });
  },
};
