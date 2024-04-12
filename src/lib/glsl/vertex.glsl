varying vec2 vUv; // Declare varying variable to pass UV coordinates to the fragment shader

void main() {

	vUv = uv;
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}