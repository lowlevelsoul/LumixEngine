//@surface
//@include "pipelines/common.hlsli"
//@texture_slot "Albedo", "textures/common/white.tga"

struct VSOutput {
	float2 uv : TEXCOORD0;
	float3 pos_ws : TEXCOORD1;
	float3 normal : TEXCOORD2;
	float4 position : SV_POSITION;
};

#define ATTR(X) TEXCOORD##X
cbuffer Model : register(b4) {
	float4x4 u_model;
};

cbuffer Drawcall2 : register(b5) {
	uint u_gbuffer_depth;
};

struct Input {
	float3 position : TEXCOORD0;
	#ifdef UV0_ATTR
		float2 uv : ATTR(UV0_ATTR);
	#endif
	float3 normal : ATTR(NORMAL_ATTR);
};

VSOutput mainVS(Input input) {
	VSOutput output;
	#ifdef UV0_ATTR
		output.uv = input.uv;
	#else
		output.uv = 0;
	#endif
	float4 p = mul(float4(input.position, 1), mul(u_model, Global_view));
	output.pos_ws = p.xyz;
	output.normal = input.normal;
	output.position = mul(p, Global_projection_no_jitter);
	return output;
}

float4 mainPS(VSOutput input) : SV_TARGET {
	float2 screen_uv = input.position.xy / Global_framebuffer_size;
	float3 pos_ws = getPositionWS(u_gbuffer_depth, screen_uv);
	float4 albedo = sampleBindless(LinearSampler, t_albedo, input.uv);
	#ifdef ALPHA_CUTOUT
		if (albedo.a < 0.5) discard;
	#endif
	float d = dot(Global_light_dir.xyz, input.normal);
	float4 o_color;
	o_color.rgb = albedo.rgb * saturate(max(0, -d) + 0.25 * max(0, d) + 0.25);
	o_color.a = 1;
	if(length(pos_ws) < length(input.pos_ws)) o_color.rgb *= 0.25;
	return o_color;
}