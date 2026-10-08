uniform sampler2D u_Tex0;
uniform vec4 u_Color;
uniform float u_Opacity;
varying vec2 v_TexCoord;

void main()
{
    float a = texture2D(u_Tex0, v_TexCoord).a;
    if (a < 0.01)
        discard;

    // Silhueta preta do FBO do banner; intensidade via u_Color/u_Opacity (fade em grupo)
    float alpha = a * u_Color.a * u_Opacity;
    gl_FragColor = vec4(0.0, 0.0, 0.0, alpha);
}
