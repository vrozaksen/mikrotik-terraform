module.exports = {
  // parserPreset adds `!` (breaking-change marker) support to the default
  // header pattern: `release(scope)!: subject` would otherwise fail with
  // empty type + empty subject because the default regex requires `:`
  // immediately after the scope.
  parserPreset: {
    parserOpts: {
      headerPattern: /^(\w+)(?:\(([\w$.\-* ]+)\))?(!)?: (.+)$/,
      headerCorrespondence: ["type", "scope", "breaking", "subject"],
    },
  },
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "perf",
        "test",
        "build",
        "ci",
        "chore",
        "revert",
      ],
    ],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "scope-case": [2, "always", "lower-case"],
    "subject-case": [1, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
    "header-max-length": [2, "always", 100],
    "body-leading-blank": [2, "always"],
    "body-max-line-length": [2, "always", 100],
    "footer-leading-blank": [2, "always"],
    "footer-max-line-length": [2, "always", 100],
  },
};
