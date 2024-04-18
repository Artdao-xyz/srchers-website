/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
        fontFamily: {
            'reglo':
                "Reglo, system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif",
        },
    }
  },
  plugins: []
};