module.exports = {
  parser: "babel-eslint",

  extends: [
    "plugin:react/recommended",
    "plugin:prettier/recommended",
    "prettier/react",
    "prettier/standard",
  ],

  parserOptions: {
    ecmaVersion: 2018,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },

  plugins: ["prettier"],

  env: {
    browser: true,
  },

  globals: {
    Rails: true,
  },

  settings: {
    "react": {
      "createClass": "createReactClass", // Regex for Component Factory to use,
                                         // default to "createReactClass"
      "pragma": "React",  // Pragma to use, default to "React"
      "version": "detect"
    }
  },

  overrides: [
    {
      files: ['**/*.ts', '**/*.tsx'],

      parser: '@typescript-eslint/parser',

      extends: [
        "plugin:react/recommended",
        "plugin:@typescript-eslint/recommended",
        "plugin:prettier/recommended",
        "prettier/react",
        "prettier/standard",
        "prettier/@typescript-eslint"
      ],

      parserOptions: {
        ecmaVersion: 2018,
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },

        // typescript-eslint specific options
        project: "./tsconfig.json",
        //tsconfigRootDir: projectRootPath,
        warnOnUnsupportedTypeScriptVersion: true,
      },

      plugins: ['@typescript-eslint'],

      rules: {
        // These ESLint rules are known to cause issues with typescript-eslint
        // See https://github.com/typescript-eslint/typescript-eslint/blob/master/packages/eslint-plugin/src/configs/recommended.json
        camelcase: 'off',
        indent: 'off',
        'no-array-constructor': 'off',
        'no-unused-vars': 'off',

        '@typescript-eslint/no-angle-bracket-type-assertion': 'warn',
        '@typescript-eslint/no-array-constructor': 'warn',
        '@typescript-eslint/no-namespace': 'error',
        '@typescript-eslint/no-unused-vars': [
          'warn',
          {
            args: 'none',
            ignoreRestSiblings: true,
          }
        ],
        '@typescript-eslint/explicit-function-return-type': 'off',

        'react/prop-types': 'off'
      }
    }
  ]
}
