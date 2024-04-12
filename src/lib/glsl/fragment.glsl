precision highp float;

// varying vec2 vTexCoord;
varying vec2 vUv; // UV coordinates passed from the vertex shader


// uniform float u_random_reverse;
// uniform float u_contrast;
// uniform float r_noise_texture;
// uniform vec2 u_resolution;
// uniform vec2 u_shader_seed;
// uniform vec2 u_esqueje;
// uniform vec2 r_texture;
// uniform sampler2D u_color;
// uniform sampler2D u_border;

// float adjustContrast(float color, float value) {
//   return 0.5 + (1.0 + value) * (color - 0.5);
// }
// vec2 adjustContrast(vec2 color, float value) {
//   return 0.5 + (1.0 + value) * (color - 0.5);
// }
// vec3 adjustContrast(vec3 color, float value) {
//   return 0.5 + (1.0 + value) * (color - 0.5);
// }
// float adjustBrightness(float color, float value) {
//   return color + value;
// }
// vec3 adjustBrightness(vec3 color, float value) {
//   return color + value;
// }
// vec3 adjustExposure(vec3 color, float value) {
//   return (1.0 + value) * color;
// }
// float map(float value, float min1, float max1, float min2, float max2) {
//   return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
// }

// vec3 smooth_rectangle(float edge, float edge2, vec2 uv) {
	
// 	vec2 bottom_left = smoothstep(vec2(edge), vec2(edge2), vec2(uv));  
// 	vec2 top_right = smoothstep(vec2(edge), vec2(edge2),  1.0 - vec2(uv)); 
	
// 	vec3 rect = vec3(bottom_left.x * bottom_left.y * top_right.x * top_right.y);

// 	return rect;
// }

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; 
}
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 permute(vec3 x) {
  return mod289(((x * 34.0) + 1.0) * x); 
}
float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.57731269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);

    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
// float snoise_seeded(vec2 v) {

//     v += u_shader_seed;

//     const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
//                         0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
//                         -0.57731269189626,  // -1.0 + 2.0 * C.x
//                         0.024390243902439); // 1.0 / 41.0
//     vec2 i  = floor(v + dot(v, C.yy) );
//     vec2 x0 = v -   i + dot(i, C.xx);

//     vec2 i1;

//     i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

//     vec4 x12 = x0.xyxy + C.xxzz;
//     x12.xy -= i1;

//     i = mod289(i); // Avoid truncation effects in permutation
//     vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
//     + i.x + vec3(0.0, i1.x, 1.0 ));

//     vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
//     m = m*m ;
//     m = m*m ;

//     vec3 x = 2.0 * fract(p * C.www) - 1.0;
//     vec3 h = abs(x) - 0.5;
//     vec3 ox = floor(x + 0.5);
//     vec3 a0 = x - ox;

//     m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

//     vec3 g;
//     g.x  = a0.x  * x0.x  + h.x  * x0.y;
//     g.yz = a0.yz * x12.xz + h.yz * x12.yw;
//     return 130.0 * dot(m, g);
// }
// float fbm(vec2 uv, float period) {

//     float value = float(0.0);
//     float amplitud = 0.5;


//     for (int i = 0; i < 3; i++) {
//         value += amplitud * snoise(uv * period);
//         uv *= 2.0;
//         amplitud *= 0.5;
//     }
//     return value;
// }
// float fbm_seeded(vec2 uv, float period) {

//     float value = float(0.0);
//     float amplitud = 0.5;

//     for (int i = 0; i < 3; i++) {
//         value += amplitud * snoise_seeded(uv * period);
//         uv *= 2.0;
//         amplitud *= 0.5;
//     }
//     return value;
// }

// vec2 curl( vec2 p, float period){
//     const float e = .1;
//     vec2 dx = vec2( e   , 0.0 );
//     vec2 dy = vec2( 0.0 , e   );

//     vec2 p_x0 = vec2(snoise( p * period - dx ));
//     vec2 p_x1 = vec2(snoise( p * period + dx ));
//     vec2 p_y0 = vec2(snoise( p * period - dy ));
//     vec2 p_y1 = vec2(snoise( p * period+ dy ));

//     float x = p_x1.y + p_x0.y;
//     float y = p_y1.x - p_y0.x;

//     const float divisor = 1.0 / ( 2.0 * e );
//     return normalize( vec2(x , y) * divisor );
// }

// vec2 displace(vec2 displace_texture, vec2 weight) {
// 	vec2 uv = vTexCoord;

//   uv.r += displace_texture.r * weight.r;
//   uv.g += displace_texture.g * weight.g;

//   return uv;
// }
// vec2 noisify_edges(vec2 uv, float amplitud, float grain) { 

//   float noise = snoise(uv / grain);
//   uv.x += noise * amplitud ;
//   uv.y += noise * amplitud ;

//   return uv;
// }

// vec3 normalify(vec3 texture, float brightness, float contrast) {

//   vec3 rect = smooth_rectangle(0.0, 0.005, vTexCoord);

//   texture *= rect;
//   float p = texture.r;
//   float h1 = texture.g;
//   float v1 = texture.b;
//   vec2 normal = p - vec2(h1, v1);
  
//   normal *= 1.0;
//   normal += 0.5;
//   normal = adjustContrast(normal, u_contrast);
//   float length_vector = length(normal);
//   normal /= vec2(length_vector);

//   vec3 color = vec3(normal, 1.0);
//   color.r = map(color.r, -1.0, 1.0, 0.0, 1.0);
//   color.g = map(color.g, -1.0, 1.0, 0.0, 1.0);
//   color.b = map(color.b, -1.0, 0.0, 0.5, 1.0);

//   float mono = 0.21 * color.r + 0.71 * color.g + 0.07 * color.b ;
//   color = vec3(mono);

//   color = adjustExposure(color, brightness);

//   color = adjustContrast(color, contrast);



//   return color;
// }

// float in_uv_grid(vec2 uv, float tile_x, float tile_y){

//   float ramp_x = fract(uv.r * tile_x);
//   float ramp_y = fract(uv.g * tile_y);

//   float map = ramp_x * ramp_y;

//   return map;
// }




// vec3 n_noise_stitches(float tile_x, float tile_y, float period1, float weight){
  
//   vec2 s = 1.0/u_resolution.xy;
//   vec2 uv = vTexCoord;
//   vec2 uv_right = vTexCoord + s * vec2(1.0, 0.0);
//   vec2 uv_up = vTexCoord + s * vec2(0.0, 1.0);

//   float nn = fbm(uv, r_noise_texture);
//   float nn_right = fbm(uv_right, r_noise_texture);
//   float nn_up = fbm(uv_up, r_noise_texture);

//   uv = displace(vec2(nn), vec2(0.015));
//   uv_right = displace(vec2(nn_right), vec2(0.015));
//   uv_up = displace(vec2(nn_up), vec2(0.015));

//   float map_ = in_uv_grid(uv, tile_x, tile_y);
//   uv = displace(vec2(map_), vec2(weight));

//   float map_right = in_uv_grid(uv_right, tile_x, tile_y);
//   uv_right = displace(vec2(map_right), vec2(weight));

//   float map_up = in_uv_grid(uv_up, tile_x, tile_y);
//   uv_up = displace(vec2(map_up), vec2(weight));

//   float noise = snoise(uv * period1);
//   float noise_right = snoise(uv_right * period1);
//   float noise_up = snoise(uv_up * period1);

//   float n = fbm(uv, 1.);
//   float n_right = fbm(uv_right, 1.);
//   float n_up = fbm(uv_up, 1.);

//   vec3 color = vec3(noise, noise_right, noise_up);

//   return color;
// }


// vec3 n_plastic_noise(){
//   vec2 uv = vTexCoord;
//   vec2 s = 1.0/u_resolution.xy;
//   vec2 uv_right = vTexCoord + s * vec2(1.0, 0);
//   vec2 uv_up = vTexCoord + s * vec2(0, 1.0);

//   vec2 disp = vec2(snoise_seeded(uv * 50.0));
//  	uv = sin((uv + u_shader_seed) * 3.5 + 5.0) + disp * 0.01;

//   vec2 disp_right = vec2(snoise_seeded(uv_right * 50.0));
//  	uv_right = sin((uv_right + u_shader_seed) * 3.5 + 5.0) + disp_right * 0.01;

//   vec2 disp_up = vec2(snoise_seeded(uv_up * 50.0));
//  	uv_up = sin((uv_up + u_shader_seed) * 3.5 + 5.0) + disp_up * 0.01;

//   float noise = snoise_seeded(uv * 3.0);
//   float noise_right = snoise_seeded(uv_right * 3.0);
//   float noise_up = snoise_seeded(uv_up* 3.0);
  
//   vec3 color = vec3(noise, noise_right, noise_up);

//   return color;
// }

// vec3 n_input_texture(sampler2D texture) {
//   vec2 s = 1.0/u_resolution.xy;
//   vec2 uv = vTexCoord;
//   vec2 uv_right = vTexCoord + s * vec2(1.0, 0);
//   vec2 uv_up = vTexCoord + s * vec2(0, 1.0);

//   vec3 input_texture = texture2D(texture, uv).rgb;
//   vec3 input_texture_right = texture2D(texture, uv_right).rgb;
//   vec3 input_texture_up = texture2D(texture, uv_up).rgb;

//   vec3 color = vec3(input_texture.r, input_texture_right.r, input_texture_up.r);

//   return color;
// }

void main() {

    // vec2 input_uv = vTexCoord;
    //   input_uv.y = 1.0 - input_uv.y;

    float noise = snoise(vUv);

    //   vec3 color = vec3(1.0);
    //   vec3 border = texture2D(u_border, input_uv).rgb;

    //   border = adjustContrast(border, 0.75);

    //   vec2 curl_noise_map = curl(input_uv, 4.0);
    //   vec2 uv_disp = displace(vec2(curl_noise_map), vec2(0.08, -0.08));
    //   float curl_noise = fbm_seeded(uv_disp.rg, u_esqueje.x);
    //   uv_disp = displace(vec2(curl_noise) , vec2(1.002, -1.002));
    //   uv_disp = displace(vec2(curl_noise), vec2(-0.2, -0.02));
    //   float curl_noise_map2 = (1.0 + snoise_seeded(uv_disp.rg * u_esqueje.y)) / 2.0;

    //   vec3 theColor = texture2D(u_color, vec2(curl_noise_map2)).rgb;

    //   vec3 tex_normals = n_noise_stitches(r_texture.x, r_texture.y, 20.0, 0.1);
    //   vec3 tex_normalify = normalify(tex_normals, 0., -0.3);
    //   vec3 tex_color = tex_normalify;

    //   vec3 plastic_normals = n_plastic_noise();
    //   vec3 plastic_normalify = normalify(plastic_normals, 0.0, -0.6);
    //   vec3 plastic_color = plastic_normalify;
    //   color = adjustExposure(color, 0.5);

    //   color *= theColor;
    //   color += border;
    //   color = adjustExposure(color, 1.40);
    //   color = adjustBrightness(color, 0.80);
    //   color *= tex_color * plastic_color;
    //   color = adjustContrast(color, -0.4);
    //   color = mix(color, 1.0 - color, u_random_reverse);

    gl_FragColor = vec4(vec3(noise), 1.0);
//   gl_FragColor = vec4(color, 1.0);
}