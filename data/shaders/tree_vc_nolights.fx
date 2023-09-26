//////////////////////////////////////////////////////////////////////////////
//
// Workfile: tree_vc_noLights.fx
// Created by: Plus
//
// simple plant shader (w/ vertex colors)
//
// $Id: tree_vc_noLights.fx,v 1.4 2005/09/06 10:56:14 vano Exp $
//
//////////////////////////////////////////////////////////////////////////////

#include "data/shaders/lib.fx"

// Diffuse texture
texture 		DiffMap0 : DIFFUSE_MAP_0;

// Light direction( world space )
float3 LightDir			 : TMP_LIGHT0_DIR
<
	int Space = SPACE_OBJECT;
>;


// Diffuse color
shared const float2 g_FogTerm		: FOG_TERM		= { 1.0f, 800.0f };
shared const float4 g_PlantColor	: LIGHT_PLANT	= { 1.0f, 1.0f, 1.0f, 1.0f };
shared const float3  g_BendTerm		: TREE_BEND_TERM;
shared const float  g_Transparency	: TRANSPARENCY	= 1.f;


// transformations
row_major float4x4 mFinal	 : TOTAL_MATRIX;
//row_major float4x4 mWorld	 : WORLD_MATRIX;
//float4x4 mInvWorld		 : INV_WORLD_MATRIX;

// declare base diffuse sampler
DECLARE_DIFFUSE_SAMPLER( DiffSampler, DiffMap0 )

// Vertex shader input structure
struct VS_INPUT
{
	float3 Pos	     : POSITION;		// position in object space
	//float3 Normal	     : NORMAL;			// normal in object space
	float2 Tex0	     : TEXCOORD0;		// diffuse texcoords
	float4 VertColor : COLOR0;			// vertex color
};

// Vertex shader output structure (for ps_1_1)
struct VS11_OUTPUT
{
	float4 Pos		     : POSITION;
	float2 Tex0		     : TEXCOORD0;
	float4 VertColor	: COLOR0;		// Vertex color
	float  fog		     : FOG;
};


/**
	Simple diffuse vertex shader for ps_1_1
 */
VS11_OUTPUT PS11_PlantVS( VS_INPUT In )
{
	VS11_OUTPUT Out = ( VS11_OUTPUT )0;

	if( In.Pos.y >= 0.0f )
	{
		In.Pos.xz += g_BendTerm.xy * In.Pos.y;
	}


	// Position ( projected )
	Out.Pos         = mul( float4( In.Pos, 1 ) , mFinal );
	// Texture coordinate
	Out.Tex0	    = In.Tex0;
	// Vertex color
	Out.VertColor   = In.VertColor;       

	// Fog coeff
	Out.fog 	    = VertexFog( Out.Pos.z, g_FogTerm );

	return Out;
}


/**
	Simple diffuse pixel shader for ps_1_1
 */
float4 PS11_PlantPS( VS11_OUTPUT In, uniform float4 plantColor ): COLOR
{
	return tex2D( DiffSampler, In.Tex0 ) * float4( plantColor.xyz, g_Transparency ) * In.VertColor;
//	return tex2D( DiffSampler, In.Tex0 ) * plantColor * In.VertColor;
}


technique TreeTech
<
	string 	Description = "plant shader w/ vertex colors (w/o lighting)";
	bool   	ComputeTangentSpace = false;
	string 	VertexFormat = "VERTEX_XYZNT1";
	bool	Default = true;
>
{
	pass P1
	{
		VertexShader = compile vs_1_1 PS11_PlantVS();
		PixelShader = compile ps_1_1 PS11_PlantPS( g_PlantColor );
		
		//FogEnable        = true;
		//CullMode	     = CCW;
		//FillMode	     = Solid;
		//ZWriteEnable     = true;
		//AlphaBlendEnable = false;
		//AlphaTestEnable  = true;
		//AlphaFunc = GreaterEqual;
		//AlphaRef = 100;
	}
}