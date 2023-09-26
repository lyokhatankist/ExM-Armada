//////////////////////////////////////////////////////////////////////////////
//
// Workfile: specular.fx
// Created by: Vano
//
// simple per-vertex specular hightlight shader
//
//////////////////////////////////////////////////////////////////////////////

#include "data/shaders/lib.fx"

// Diffuse texture
texture 		DiffMap0 : DIFFUSE_MAP_0;

// viewer position (object space)
float4	objectViewPos	: VIEW_POS
<
	int 	Space = SPACE_OBJECT;
	bool    Editable = false;
>;

// Light direction( world space )
float3 LightDir			 : TMP_LIGHT0_DIR
<
	int Space = SPACE_OBJECT;
>;

// Diffuse color
shared const float4 g_Ambient		: LIGHT_AMBIENT		= { 0.2f, 0.2f, 0.2f, 1.0f };
shared const float4 g_Diffuse		: LIGHT_DIFFUSE		= { 1.0f, 1.0f, 1.0f, 1.0f };
shared const float3 g_Specular		: LIGHT_SPECULAR 	= { 1.0f, 1.0f, 1.0f };
shared const float2 g_FogTerm		: FOG_TERM			= { 1.0f, 800.0f };
shared const float  g_Transparency	: TRANSPARENCY		= 1.f;

// transformations
row_major float4x4 	mFinal		: TOTAL_MATRIX;
//float4x4 			mWorld		: WORLD_MATRIX;
//float4x4 			mInvWorld	: INV_WORLD_MATRIX;

// declare base diffuse sampler
DECLARE_DIFFUSE_SAMPLER( DiffSampler, DiffMap0 )

// Material specular power
static	int		MaterialSpecularPower	= 8;

// Vertex shader input structure
struct VS_INPUT
{
	float3 Pos	     : POSITION;		// position in object space
	float3 Normal	 : NORMAL;			// normal in object space
	float2 Tex0	     : TEXCOORD0;		// diffuse texcoords
};

// Vertex shader output structure (for ps_1_1)
struct VS11_OUTPUT
{
	float4 Pos		     : POSITION;
	float2 Tex0		     : TEXCOORD0;
	float4 Clr           : COLOR0;
	float4 Spec			 : COLOR1;
	float  fog			 : FOG;
};

/**
	Simple specular vertex shader for ps_1_1
 */
VS11_OUTPUT PS11_DiffuseVS( VS_INPUT In, uniform float4 diffuse, uniform float3 specular )
{
	VS11_OUTPUT Out = ( VS11_OUTPUT )0;

	// Position ( projected )
	Out.Pos					= mul( float4( In.Pos, 1 ) , mFinal );
	// Texture coordinate
	Out.Tex0				= In.Tex0;
	// Light color    
	Out.Clr					= saturate( dot( In.Normal , -LightDir ) ) * diffuse;       
	// Fog coeff
	Out.fog 				= VertexFog( Out.Pos.z, g_FogTerm );
	// Calculate view vector in object space
	float3 objectViewDir	= normalize( objectViewPos - In.Pos );
	// Calculate R
	float3 R				= normalize( reflect( objectViewDir, In.Normal ) );
	// Specular color
	Out.Spec				= float4( specular * pow( max( 0, dot( R, -objectViewDir ) ), MaterialSpecularPower ), 1.f ); 

	return Out;
}

/**
	Simple diffuse pixel shader for ps_1_1
 */
float4 PS11_DiffusePS( VS11_OUTPUT In, uniform float4 ambient ): COLOR
{
	// Diffuse color
	float4 Diff		= tex2D( DiffSampler, In.Tex0 );
	// Resulting color
	float3 Res		= Diff * ( In.Clr + ambient ) + In.Spec * Diff.a ;  
	return  float4( Res, g_Transparency );
}

technique Test1
<
	string 	Description			= "simple specular shader";
	bool   	ComputeTangentSpace = false;
	string 	VertexFormat		= "VERTEX_XYZNT1";
	bool	Default				= true;
	bool   UseAlpha				= false;
>
{
	pass P1
	{
		VertexShader	 = compile vs_1_1 PS11_DiffuseVS( g_Diffuse, g_Specular );
		PixelShader		 = compile ps_1_1 PS11_DiffusePS( g_Ambient );
		
		//FogEnable        = true;
		//CullMode	     = CCW;
		//FillMode	     = Solid;
		//ZWriteEnable     = true;
		//AlphaBlendEnable = false;
		//AlphaTestEnable  = true;
		//AlphaFunc		 = GreaterEqual;
		//AlphaRef		 = 100;
	}
}