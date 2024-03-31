
uniform float adsk_result_w;
uniform float adsk_result_h;
uniform sampler2D adsk_results_pass2;
uniform float blur_value;

void main(void)
{
  vec2 res = vec2(adsk_result_w,adsk_result_h);
  vec2 uv  = gl_FragCoord.xy / res.xy;

  int blur_value_int = int(blur_value);

  vec3 col = vec3(0.0);
  float energy = 0.0;

  for(int y = -blur_value_int; y <= blur_value_int; y++) {
    vec2 current = vec2(uv.x,uv.y+float(y)/res.y);
    vec3 sample = texture2D(adsk_results_pass2,current).rgb;

    float pass = 1.0 - (abs(float(y)) / blur_value);
    energy += pass;
    col += sample * pass;
  }

  if(energy > 0.0) {
    gl_FragColor = vec4((col/energy).rgb,texture2D(adsk_results_pass2,uv).a);
  } else {
    gl_FragColor = texture2D(adsk_results_pass2,uv);
  }
}

