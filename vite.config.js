import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import glsl from 'vite-plugin-glsl'

export default defineConfig({
    ssr: {
		noExternal: [
			'three-custom-shader-material',
		]
	},
	plugins: [sveltekit(), glsl()]
});
