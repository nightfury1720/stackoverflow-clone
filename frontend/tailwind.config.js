/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'so-blue': '#0a95ff',
        'so-orange': '#f48225',
        'so-black': '#232629',
        'so-light': '#f1f2f3',
        'so-border': '#d6d9dc',
        'so-green': '#5eba7d',
      },
    },
  },
  plugins: [],
}

