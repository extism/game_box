// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  theme: {
    fontFamily: {
      display: [
        "originalsregular",
        "Helvetica", 
        "Arial", 
        "sans-serif"
      ],
      sans: [ 
        "dm_monomedium",
        "Helvetica", 
        "Arial", 
        "sans-serif"
      ]
    },
    extend: {
      colors: { 
        primary: '#A26CFF',
        secondary: '#C7B9E0',
        dark:'#170124', 
        success: '#6CFF9E',
        info: '#0EA5E9', 
        warning: '#FB923C', 
        error: '#DC2626'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
