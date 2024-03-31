uniform float adsk_result_w;
uniform float adsk_result_h;
uniform sampler2D input1;

uniform float opacity;
uniform int gamma;
uniform bool show_boundary;

uniform float skin_hue;
uniform float tolerance;
uniform float low_threshold;

vec3 adsk_rgb2hsv(vec3 rgb);

vec3 overlay_skin;
vec3 overlay_high;
vec3 overlay_low;

// Source: code from Abel Milanese
vec3 rec709_lin(vec3 rgb)
{
    //Rec709 to Lin
    // x<.081 ? x/4.5 : pow((x+.099)/1.099, 1.0/.45)
    vec3 color = rgb;

    if (color.r < 0.081)
        color.r = color.r / 4.5;
    else
        color.r = pow((color.r+0.099)/1.099, 1.0/0.45);

    if (color.g < 0.081)
        color.g = color.g / 4.5;
    else
        color.g = pow((color.g+0.099)/1.099, 1.0/0.45);

    if (color.b < -0.081)
        color.b = color.b / 4.5;
    else
        color.b = pow((color.b+0.099)/1.099, 1.0/0.45);

    return color;
}

vec3 lin_rec709(vec3 rgb)
{
    //Lin to Rec709
    // x > 0.018 ? (1.099 * pow(x, 0.45) - 0.099) : x*4.5
    vec3 color = rgb;

    if (color.r >= 0.018)
        color.r = (1.099 * pow(color.r, 0.45) - 0.099);
    else
        color.r = color.r*4.5;

    if (color.g >= 0.018)
        color.g = (1.099 * pow(color.g, 0.45) - 0.099);
    else
        color.g = color.g*4.5;

    if (color.b >= 0.018)
        color.b = (1.099 * pow(color.b, 0.45) - 0.099);
    else
        color.b = color.b*4.5;

    return color;
}

void main(void)
{
  vec2 res = vec2(adsk_result_w,adsk_result_h);
  vec2 uv  = gl_FragCoord.xy / res.xy;
  vec4 in1 = texture2D(input1,uv);
  vec3 hsv = adsk_rgb2hsv(vec3(in1.r,in1.g,in1.b));
  vec4 rgb = in1;

  if(hsv.r < low_threshold || hsv.g < low_threshold || hsv.b < low_threshold) {
    gl_FragColor = rgb;
    return;
  }

  float offset = min(abs(hsv.r-skin_hue),1.0-abs(hsv.r-skin_hue));

  if(gamma == 1) {
    // video color space
    rgb = vec4(rec709_lin(in1.rgb),in1.a);
    overlay_skin = vec3(1.0,0.537,0.537);
    overlay_high = vec3(1.0,1.0,0.403);
    overlay_low  = vec3(0.403,0.403,1.0);
  } 
  else {
    // in linear space
    overlay_skin = vec3(0.462,0.414,0.411);
    overlay_high = vec3(0.484,0.477,0.389);
    overlay_low  = vec3(0.368,0.373,0.457);
  }

  // handle wrap-around
  if(offset < tolerance / 100.0) {
    // within tolerance range
    rgb = mix(vec4(overlay_skin,1.0),rgb,opacity/100.0);
  }
  else if(show_boundary && offset < 3.0*tolerance / 100.0) 
  {
    // within twice tolerance range
    if(hsv.r < skin_hue && abs(hsv.r - skin_hue) < 0.5) { 
      rgb = mix(vec4(overlay_low,1.0),rgb,opacity/100.0);
    } 
    else {
      rgb = mix(vec4(overlay_high,1.0),rgb,opacity/100.0);
    }
  }

  if(gamma == 1) {
    rgb = vec4(lin_rec709(rgb.rgb),rgb.a);
  }

  gl_FragColor = rgb;
}
