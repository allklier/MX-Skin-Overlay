
uniform float adsk_result_w;
uniform float adsk_result_h;
uniform sampler2D adsk_results_pass4;
uniform int matte_process;
uniform float erode_size;

// Derived from: https://github.com/kajott/GIPS/blob/main/shaders/Blur%2BSharpen/Dilate%2BErode.glsl  (MIT license)

void main(void)
{
  vec2 res   = vec2(adsk_result_w,adsk_result_h);
  vec2 uv    = gl_FragCoord.xy / res.xy;
  vec4 pixel = texture2D(adsk_results_pass4,uv);

  if(matte_process > 0) {
    vec2 res = vec2(adsk_result_w,adsk_result_h);
    vec2 uv  = gl_FragCoord.xy / res.xy;

    vec3 vmin = pixel.rgb;
    vec3 vmax = pixel.rgb;
    float rend = ceil(erode_size * 0.5);

    for(float dist=-floor(erode_size * 0.5);dist <= rend;dist += 1.0) {
      float y = (gl_FragCoord.y + dist) / adsk_result_h;
      vec3 sample = texture2D(adsk_results_pass4,vec2(uv.x,y)).rgb;
      vmin = min(vmin,sample);
      vmax = max(vmax,sample);
    }

    if(matte_process == 1) {
      gl_FragColor = vec4(vmin.rgb,pixel.a);
    } else if(matte_process == 2) {
      gl_FragColor = vec4(vmax.rgb,pixel.a);
    }
  } else {
    gl_FragColor = pixel;
  } 
}

