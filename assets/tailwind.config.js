// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  safelist: [
    'max-w-xs',
    'max-w-sm',
    'max-w-md',
    'max-w-lg',
    'max-w-xl',
    'max-w-2xl',
    'max-w-3xl',
    'max-w-4xl',
    'max-w-5xl'
  ],
  theme: {
    fontSize: {
      xs: '.69rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.18rem',
      xl: '1.25rem',
      '2xl': '1.38rem',
      '3xl': '1.953rem',
      '4xl': '2.441rem',
      '5xl': '3.052rem',
      '6xl': '3.88rem',
    },
    fontFamily: {
      display: [
        "originalsregular",
        "Helvetica", 
        "Arial", 
        "sans-serif"
      ],
      sans: [ 
        "Helvetica", 
        "Arial", 
        "sans-serif"
      ],
      mono: [ 
        "dm_monomedium",
         "ui-monospace", 
         "SFMono-Regular", 
         "Menlo", 
         "Monaco", 
         "Consolas", 
         "Liberation Mono", 
         "Courier New", 
         "monospace"
      ]
    },
    extend: {
      colors: { 
        primary: {  
          light: '#e3d2ff',
          DEFAULT: '#A26CFF',
          dark: '#8905e8'
        },
        secondary: {  
          light: '#e3dcef',
          DEFAULT: '#C7B9E0',
          dark: '#988b9e'
        },
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
