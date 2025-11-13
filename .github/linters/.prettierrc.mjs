/**
 * @see https://prettier.io/docs/configuration
 * @typedef {import('prettier-plugin-multiline-arrays').MultilineArrayOptions} MultilineOptions
 *
 * @typedef {import('prettier').Config} PrettierOptions
 * @type {PrettierOptions & MultilineOptions}
 */
export default {
  arrowParens: 'always',
  bracketSpacing: true,
  endOfLine: 'lf',
  htmlWhitespaceSensitivity: 'css',
  insertPragma: false, // consider true
  singleAttributePerLine: false,
  bracketSameLine: false,
  jsxSingleQuote: true,
  printWidth: 120,
  proseWrap: 'preserve',
  quoteProps: 'as-needed',
  requirePragma: false, // consider true
  semi: true,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'none',
  useTabs: false,
  vueIndentScriptAndStyle: true,
  embeddedLanguageFormatting: 'auto',
  experimentalTernaries: true,
  experimentalOperatorPosition: 'end',
  plugins: ['prettier-plugin-multiline-arrays']
};
