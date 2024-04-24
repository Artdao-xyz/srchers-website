/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
        colors: {
            'alternative-black': '#24241C',
        },
        fontFamily: {
            'jetbrains-mono':
                "JetBrainsMono, system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif",
        },
        animation: {
            spin: 'spin s linear infinite',
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