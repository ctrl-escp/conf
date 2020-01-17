module.exports = {
//   extends: ["eslint:recommended", "prettier"],
//   plugins: ["prettier"],
  env: {
    es6: true,
    browser: true
  },
  parser: "babel-eslint",
  rules: {
    semi: [2, "always"],
    "no-mixed-spaces-and-tabs": [1, "smart-tabs"],
    // indent: [1, 4, { SwitchCase: 1, ignoreComments: true }],
    "no-unused-vars": [1, { "vars": "all", "args": "after-used", "ignoreRestSiblings": false }]
  }
};
