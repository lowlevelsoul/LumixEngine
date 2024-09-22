#include "pipelines/common.hlsli"

struct Output {
	float2 uv : TEXCOORD0;
	float4 position : SV_POSITION;
};

cbuffer Data : register(b4) {
	uint input;
	uint output;
};

[numthreads(16, 16, 1)]
void main(uint3 thread_id : SV_DispatchThreadID) {
	float4 v = bindless_textures[input][thread_id.xy];
	v = float4(ACESFilm(v.rgb), 1);
	bindless_rw_textures[output][thread_id.xy] = v;
}