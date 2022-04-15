Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
    float  Time;
    float  Scale;
    float2 Resolution;
    float4 Background;
};
#define N_COLORS 5.

#define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))


float3 irri(float hue)
{
    return 0.5+0.5*cos(9.*hue+float3(0., 23., 21.));
}

#define T Time

float2 line_(in float2 p, in float2 a, in float2 b)
{
    float2 ba = b-a;
    float2 pa = p-a;
    float h = clamp(dot(pa, ba)/dot(ba, ba), 0., 1.);
    return float2(length(pa-h*ba), h);
}


float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
    float2 uv = float2(tex.x, tex.y);
    float3 sum = (float3)0.;
    float valence = 0;
    for(float i = 0.; i<N_COLORS; i++) {
        float id = rcp(N_COLORS)+i/N_COLORS*0.75;
        float2 start = float2(id, 0.0);
        float2 end = float2(id, 1.0);
        float2 blend = 2.2;
        float2 d = line_(uv, start, end);
        float w = 1./pow(d.x,blend);
        float3 colA = irri(id+T*0.1) / (0.002 + dot(d,d)) * d.y*length(end-start) * 0.3;
        sum += w*colA;
        valence += w;
    }
    sum /= valence;
    float4 col = float4(sum, 1.) * 0.2 + shaderTexture.Sample(samplerState, tex);
    return col;
}