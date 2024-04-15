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

void main()
{    
    // Color
    float color = smoothstep(-1.0, -1.0, vPosition.y);

    // Final color
    csm_DiffuseColor = vec4(vec3(color), 1.0);
}