/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
        fontFamily: {
            'jetbrains-mono':
                "JetBrainsMono, system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif",
        },
        animation: {
            spin: 'spin 30s linear infinite',
        },
        keyframes: {
            pulse: {
                '0%, 100%': {
                  opacity: 1
                },
                '50%': {
                  opacity: 0.25
                },
              }
        }
    }
  },
  plugins: []
};