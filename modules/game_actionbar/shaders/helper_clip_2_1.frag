uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;
uniform float u_Opacity;
uniform vec4 u_Color;
uniform vec2 u_Resolution;
uniform vec4 u_DestRect;

vec2 localUV()
{
    if (u_DestRect.z < 0.5 || u_DestRect.w < 0.5)
        return v_TexCoord;
    vec2 frag = vec2(gl_FragCoord.x, u_Resolution.y - gl_FragCoord.y);
    return (frag - u_DestRect.xy) / u_DestRect.zw;
}

void main()
{
    vec2 uv = localUV();
    if (uv.x + uv.y <= 1.0)
        discard;
    gl_FragColor = texture2D(u_Tex0, v_TexCoord) * u_Color;
    gl_FragColor.a *= u_Opacity;
}
