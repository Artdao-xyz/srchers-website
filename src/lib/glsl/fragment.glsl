uniform float uTime;
uniform float uPositionFrequency;
uniform float uStrength;
uniform float uWarpFrequency;
uniform float uWarpStrength;

varying vec3 vPosition;
varying float vUpDot;
varying vec2 vUv; // UV coordinates passed from the vertex shader

#include ./includes/simplexNoise2d.glsl
#include ./includes/simplexNoise3d.glsl

float y_smoothstep(float a, float b, float x) {
    float t = clamp((x - a) / (b - a), 0.0, 1.0);
 
    return t * t * (3.0 - (2.0 * t));
}
void main()
{    
    // float color = 1.0;
    // Color
    // float offset = 0.1; // Adjust this value as needed
    // float color = step(0.0, vPosition.y);
    float color = y_smoothstep(0.0, 1.0, vPosition.y * 10.0);

    // add brightness
    // color += 0.5;  

    // Final color
    csm_DiffuseColor = vec4(vec3(color), 1.0);
}