// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MetaMonkeys/ShabonDama"
{
	Properties
	{
		_HeaderMainTexturesGradientTexture("Gradient Texture", 2D) = "white" {}
		_GradientDistortionTexture("Gradient Distortion Texture", 2D) = "white" {}
		_NormalTexture("Normal Texture", 2D) = "white" {}
		[Header(Lighting)]_albedo("albedo", Range( 0 , 1)) = 0
		_smoothness("smoothness", Range( 0 , 1)) = 0
		_specular("specular", Range( 0 , 1)) = 0
		[Header(Brightness)]_opacity("opacity", Range( 0 , 0.5)) = 0
		_fresnelpower("fresnel power", Float) = 0
		_emissionintensity("emission intensity", Float) = 0
		[Header(Iridescent)]_iridescenttiling("iridescent tiling", Float) = 0
		_iridescentdistortionintensity("iridescent distortion intensity", Float) = 0
		_iridescentdistortiontiling("iridescent distortion tiling", Float) = 0
		[Header(Normal)]_normaltiling("normal tiling", Float) = 0
		_normalscrollspeed("normal scroll speed", Float) = 0
		_normalintensity("normal intensity", Float) = 0
		[Header(Vertex Noise)]_vertexnoisespeed("vertex noise speed", Float) = 0
		_vertexnoisescale("vertex noise scale", Float) = 0
		_vertexnoiseintensity("vertex noise intensity", Float) = 0
		[Header(Flashing)][Toggle(_FLASHING_ON)] _flashing("flashing ?", Float) = 0
		_flashingspeed("flashing speed", Float) = 0
		_flashingmin("flashing min", Range( 0 , 1)) = 0
		_flashingrandomrange("flashing random range", Range( 0 , 20)) = 0
		[Header(Emission Scroll)][Toggle]_emissionscroll("emission scroll", Float) = 0
		_emissionscrollspeed("emission scroll speed", Float) = 0
		_emissionscrollmin("emission scroll min", Range( 0 , 1)) = 0
		_emissionscrollwidth("emission scroll width", Float) = 0
		[Header(Glitch)][Toggle(_GLITCH_ON)] _glitch("glitch ?", Float) = 0
		_glitchfrequency("glitch frequency", Float) = 0
		_glitchdirection("glitch direction", Vector) = (1,0,1,0)
		_glitchintensity("glitch intensity", Range( 0 , 1)) = 0
		_glitchlength("glitch length", Range( 0 , 1)) = 0
		_glitchrandomrange("glitch random range", Range( 0 , 20)) = 0
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma shader_feature_local _GLITCH_ON
		#pragma shader_feature_local _FLASHING_ON
		#pragma surface surf StandardSpecular alpha:fade keepalpha noshadow exclude_path:deferred vertex:vertexDataFunc 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 uv3_texcoord3;
			float4 vertexColor : COLOR;
		};

		uniform float _vertexnoisespeed;
		uniform float _vertexnoisescale;
		uniform float _vertexnoiseintensity;
		uniform float _glitchrandomrange;
		uniform float _glitchfrequency;
		uniform float _glitchlength;
		uniform float3 _glitchdirection;
		uniform float _glitchintensity;
		sampler2D _NormalTexture;
		uniform float _normaltiling;
		uniform float _normalscrollspeed;
		uniform float _normalintensity;
		uniform float _albedo;
		sampler2D _HeaderMainTexturesGradientTexture;
		uniform float _iridescenttiling;
		sampler2D _GradientDistortionTexture;
		uniform float _iridescentdistortiontiling;
		uniform float _iridescentdistortionintensity;
		uniform float _fresnelpower;
		uniform float _opacity;
		uniform float _emissionintensity;
		uniform float _flashingspeed;
		uniform float _flashingrandomrange;
		uniform float _flashingmin;
		uniform float _emissionscrollspeed;
		uniform float _emissionscrollwidth;
		uniform float _emissionscrollmin;
		uniform float _emissionscroll;
		uniform float _specular;
		uniform float _smoothness;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		inline float3 TriplanarSampling214( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSampling223( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float4 TriplanarSampling215( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime124 = _Time.y * ( _vertexnoisespeed * 0.1 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float simplePerlin3D221 = snoise( ( mulTime124 + ase_worldPos )*_vertexnoisescale );
			simplePerlin3D221 = simplePerlin3D221*0.5 + 0.5;
			float3 ase_vertexNormal = v.normal.xyz;
			float Simplex3dNoise304 = simplePerlin3D221;
			float temp_output_344_0 = ( v.texcoord2.w * _glitchrandomrange );
			float mulTime319 = _Time.y * _glitchfrequency;
			float3 objToViewDir311 = mul( UNITY_MATRIX_IT_MV, float4( _glitchdirection, 0 ) ).xyz;
			float3 VertexGlitch315 = ( ( (-1.0 + (frac( ( ( Simplex3dNoise304 * 0.8 ) + _Time.y + temp_output_344_0 ) ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * ( 1.0 - step( sin( ( mulTime319 + temp_output_344_0 ) ) , ( 1.0 - _glitchlength ) ) ) ) * objToViewDir311 );
			#ifdef _GLITCH_ON
				float3 staticSwitch350 = ( VertexGlitch315 * _glitchintensity );
			#else
				float3 staticSwitch350 = float3( 0,0,0 );
			#endif
			v.vertex.xyz += ( ( simplePerlin3D221 * _vertexnoiseintensity * ase_vertexNormal * 0.1 * v.texcoord2.xyz.z ) + staticSwitch350 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 temp_cast_0 = (_normaltiling).xx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float4 ase_vertexTangent = mul( unity_WorldToObject, float4( ase_worldTangent, 0 ) );
			ase_vertexTangent = normalize( ase_vertexTangent );
			float3 ase_vertexBitangent = mul( unity_WorldToObject, float4( ase_worldBitangent, 0 ) );
			ase_vertexBitangent = normalize( ase_vertexBitangent );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float3x3 objectToTangent = float3x3(ase_vertexTangent.xyz, ase_vertexBitangent, ase_vertexNormal);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 break256 = ase_vertex3Pos;
			float mulTime250 = _Time.y * ( _normalscrollspeed * 0.1 );
			float3 appendResult255 = (float3(break256.x , break256.y , ( break256.z + mulTime250 )));
			float3 triplanar214 = TriplanarSampling214( _NormalTexture, appendResult255, ase_vertexNormal, 1.0, temp_cast_0, _normalintensity, 0 );
			float3 tanTriplanarNormal214 = mul( objectToTangent, triplanar214 );
			float3 normal240 = tanTriplanarNormal214;
			o.Normal = normal240;
			float3 temp_cast_1 = (_albedo).xxx;
			o.Albedo = temp_cast_1;
			float2 temp_cast_2 = (_iridescenttiling).xx;
			float2 temp_cast_3 = (_iridescentdistortiontiling).xx;
			float3 break257 = ase_vertex3Pos;
			float3 appendResult259 = (float3(break257.x , break257.y , ( break257.z + i.uv3_texcoord3.xy.x )));
			float4 triplanar223 = TriplanarSampling223( _GradientDistortionTexture, appendResult259, ase_vertexNormal, 1.0, temp_cast_3, 1.0, 0 );
			float4 triplanar215 = TriplanarSampling215( _HeaderMainTexturesGradientTexture, saturate( ( ( triplanar223 * _iridescentdistortionintensity ) + i.uv3_texcoord3.xy.y ) ).xyz, ase_vertexNormal, 1.0, temp_cast_2, 1.0, 0 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV84 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode84 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV84, _fresnelpower ) );
			float temp_output_90_0 = ( saturate( fresnelNode84 ) + _opacity );
			float mulTime273 = _Time.y * _flashingspeed;
			float2 temp_cast_6 = (( mulTime273 + ( i.uv3_texcoord3.w * _flashingrandomrange ) )).xx;
			float simplePerlin2D272 = snoise( temp_cast_6 );
			simplePerlin2D272 = simplePerlin2D272*0.5 + 0.5;
			#ifdef _FLASHING_ON
				float staticSwitch283 = (_flashingmin + (simplePerlin2D272 - 0.0) * (1.0 - _flashingmin) / (1.0 - 0.0));
			#else
				float staticSwitch283 = 1.0;
			#endif
			float mulTime286 = _Time.y * _emissionscrollspeed;
			float lerpResult353 = lerp( 1.0 , (_emissionscrollmin + (( 1.0 - abs( ( ( mulTime286 + ( ase_worldPos.y * _emissionscrollwidth ) ) % 1.0 ) ) ) - 0.0) * (1.0 - _emissionscrollmin) / (1.0 - 0.0)) , _emissionscroll);
			o.Emission = ( triplanar215 * temp_output_90_0 * _emissionintensity * i.vertexColor * staticSwitch283 * lerpResult353 ).xyz;
			float3 temp_cast_8 = (_specular).xxx;
			o.Specular = temp_cast_8;
			o.Smoothness = _smoothness;
			o.Alpha = ( temp_output_90_0 * i.vertexColor.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;346;1366.113,792.4804;Inherit;False;2104.331;1083.688;Comment;22;312;321;318;324;320;311;313;327;332;309;338;315;305;339;340;325;319;342;344;345;343;349;vertex glitch noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;299;-1530.545,790.5128;Inherit;False;1544.669;527.9202;Comment;11;289;293;290;286;287;295;294;297;298;296;291;emission scroll;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;282;-1249.078,207.7991;Inherit;False;1240.516;432.8802;Comment;9;272;280;279;274;273;275;277;347;348;flasing;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;268;-1508.05,1422.552;Inherit;False;2484.44;705.14;Comment;19;118;213;117;222;221;264;263;127;262;119;91;86;126;124;125;90;84;85;304;vertex offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;267;-1995.146,-1248.396;Inherit;False;2122.625;729.6367;Comment;13;225;105;223;259;258;247;257;228;227;226;215;229;355;triplanar main;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;266;-1630.479,-403.0977;Inherit;False;1660.836;478.9;Comment;11;252;256;255;254;214;250;240;248;251;265;356;normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;219;876.3498,-227.8885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1286.341,-152.3995;Float;False;True;-1;6;ASEMaterialInspector;0;0;StandardSpecular;MetaMonkeys/ShabonDama;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;612.853,-325.0949;Inherit;True;6;6;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;1047.87,-273.605;Inherit;False;240;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;220;349.6294,-257.9363;Inherit;False;Property;_emissionintensity;emission intensity;8;0;Create;True;0;0;0;False;0;False;0;1.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;252;-1353.679,-138.7977;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;256;-1156.679,-170.7977;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;255;-848.6794,-203.7977;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;-992.6794,-110.7977;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;250;-1221.679,-262.7977;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;240;-193.6429,-160.6817;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-1580.479,-353.0977;Inherit;False;Property;_normalscrollspeed;normal scroll speed;13;0;Create;True;0;0;0;False;0;False;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-1361.036,-323.4756;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-775.3169,-1036.387;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;259;-1478.245,-1154.624;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;258;-1567.245,-1020.624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;247;-1945.146,-1198.396;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;257;-1756.813,-1159.007;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;227;-1505.686,-870.5863;Inherit;False;Property;_iridescentdistortiontiling;iridescent distortion tiling;11;0;Create;True;0;0;0;False;0;False;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;226;-992.4636,-918.4415;Inherit;False;Property;_iridescentdistortionintensity;iridescent distortion intensity;10;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;90.54791,1851.161;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;84;-307.1723,1878.428;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;587.5811,1671.269;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-832.051,1737.042;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;124;-1085.05,1807.042;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;126;-1092.05,1667.042;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;86;-488.4009,1976.105;Inherit;False;Property;_fresnelpower;fresnel power;7;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-1192.945,1826.872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-1336.945,1954.872;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;221;-460.5929,1609.778;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;222;-677.9922,1738.475;Inherit;False;Property;_vertexnoisescale;vertex noise scale;16;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;245.4756,1785.788;Inherit;False;Constant;_Float13;Float 13;17;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;854.8734,102.173;Inherit;False;Property;_smoothness;smoothness;4;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;848.4196,-98.037;Inherit;False;Property;_albedo;albedo;3;1;[Header];Create;True;1;Lighting;0;0;False;0;False;0;0.492;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;872.5126,1.327061;Inherit;False;Property;_specular;specular;5;0;Create;True;0;0;0;False;0;False;0;0.395;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-1462.05,1853.042;Inherit;False;Property;_vertexnoisespeed;vertex noise speed;15;1;[Header];Create;True;1;Vertex Noise;0;0;False;0;False;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-847.2793,-40.19767;Inherit;False;Property;_normaltiling;normal tiling;12;1;[Header];Create;True;1;Normal;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;303.118,1883.018;Inherit;False;Property;_opacity;opacity;6;1;[Header];Create;True;1;Brightness;0;0;False;0;False;0;0.15;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;269;304.7884,-76.00879;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;942.2566,294.9502;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;272;-489.9045,284.9096;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;280;-215.5619,389.3725;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;274;-725.4285,257.799;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;273;-973.4284,258.799;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;-565.8847,526.6793;Inherit;False;Property;_flashingmin;flashing min;20;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;277;-1199.078,271.8346;Inherit;False;Property;_flashingspeed;flashing speed;19;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-73.79434,133.1949;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;289;-889.2499,896.4331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;293;-709.2499,1064.433;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;290;-713.2499,856.4331;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;286;-1234.545,840.5128;Inherit;False;1;0;FLOAT;0.43;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;287;-1415.397,957.6832;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-1082.217,1015.719;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;294;-492.1599,1016.499;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-491.9654,894.5898;Inherit;False;Property;_emissionscrollmin;emission scroll min;24;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-1430.125,1120.798;Inherit;False;Property;_emissionscrollwidth;emission scroll width;25;0;Create;True;0;0;0;False;0;False;0;0.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-442.5081,1506.111;Inherit;False;Simplex3dNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;318;2383.649,1431.601;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;324;2853.649,1452.601;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;320;2616.649,1445.601;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;311;2327.995,1259.825;Inherit;False;Object;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;313;2936.616,1078.944;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;2759.795,1066.645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;332;2572.4,1029.709;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;338;2375.977,1032.283;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;3246.444,1160.926;Inherit;False;VertexGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;2338.174,879.4804;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;319;1930.935,1534.901;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;342;2205.812,1499.497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;514.9664,1472.552;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;118;198.4686,1535.809;Inherit;False;Property;_vertexnoiseintensity;vertex noise intensity;17;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;119;203.4674,1623.887;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;-847.2402,394.8371;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;312;2094.994,1267.925;Inherit;False;Property;_glitchdirection;glitch direction;28;0;Create;True;0;0;0;False;0;False;1,0,1;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;309;1910.039,1012.929;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;305;1603.113,988.458;Inherit;False;304;Simplex3dNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;340;2024.174,872.4804;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;325;1912.38,1445.248;Inherit;False;Property;_glitchfrequency;glitch frequency;27;0;Create;True;0;0;0;False;0;False;0;2.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;2063.661,1624.169;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;345;1789.661,1787.169;Inherit;False;Property;_glitchrandomrange;glitch random range;31;0;Create;True;0;0;0;False;0;False;0;20;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;321;2149.649,1757.601;Inherit;False;Property;_glitchlength;glitch length;30;0;Create;True;0;0;0;False;0;False;0;0.053;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;349;2446.856,1701.029;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;670.451,567.0717;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;317;501.7758,529.1689;Inherit;False;315;VertexGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;329;403.7482,618.9885;Inherit;False;Property;_glitchintensity;glitch intensity;29;0;Create;True;0;0;0;False;0;False;0;0.124;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;331;1167.545,592.8989;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-1165.88,529.6188;Inherit;False;Property;_flashingrandomrange;flashing random range;21;0;Create;True;0;0;0;False;0;False;0;17.4;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;297;-192.8764,869.2269;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-197.0803,667.962;Inherit;False;Constant;_Float2;Float 2;31;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;350;870.4336,610.7289;Inherit;False;Property;_glitch;glitch ?;26;0;Create;True;0;0;0;False;1;Header(Glitch);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;353;152.0383,561.1159;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;283;117.8792,244.6525;Inherit;False;Property;_flashing;flashing ?;18;0;Create;True;0;0;0;False;1;Header(Flashing);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-1480.545,856.5128;Inherit;False;Property;_emissionscrollspeed;emission scroll speed;23;0;Create;True;1;;0;0;False;0;False;0;-0.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;55.92694,837.9223;Inherit;False;Property;_emissionscroll;emission scroll;22;2;[Header];[Toggle];Create;True;1;Emission Scroll;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;262;-9.925367,1637.666;Inherit;False;2;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;343;1760.172,1607.412;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;275;-1103.924,345.1549;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;105;-839.8068,-782.4926;Inherit;False;2;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;355;-473.8959,-828.0605;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;-594.5662,-969.9232;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TriplanarNode;223;-1292.927,-1111.437;Inherit;True;Spherical;Object;False;Gradient Distortion Texture;_GradientDistortionTexture;white;1;None;Mid Texture 3;_MidTexture3;white;-1;None;Bot Texture 3;_BotTexture3;white;-1;None;Triplanar Sampler;World;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;214;-644.4249,-253.4197;Inherit;True;Spherical;Object;True;Normal Texture;_NormalTexture;white;2;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;228;-481.1253,-634.7593;Inherit;False;Property;_iridescenttiling;iridescent tiling;9;1;[Header];Create;True;1;Iridescent;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;215;-258.7061,-817.5659;Inherit;True;Spherical;Object;False;Gradient Texture;_HeaderMainTexturesGradientTexture;white;0;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;356;-879.2563,-320.7436;Inherit;False;Property;_normalintensity;normal intensity;14;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
WireConnection;0;0;71;0
WireConnection;0;1;241;0
WireConnection;0;2;152;0
WireConnection;0;3;87;0
WireConnection;0;4;78;0
WireConnection;0;9;270;0
WireConnection;0;11;331;0
WireConnection;152;0;215;0
WireConnection;152;1;90;0
WireConnection;152;2;220;0
WireConnection;152;3;269;0
WireConnection;152;4;283;0
WireConnection;152;5;353;0
WireConnection;256;0;252;0
WireConnection;255;0;256;0
WireConnection;255;1;256;1
WireConnection;255;2;254;0
WireConnection;254;0;256;2
WireConnection;254;1;250;0
WireConnection;250;0;265;0
WireConnection;240;0;214;0
WireConnection;265;0;251;0
WireConnection;225;0;223;0
WireConnection;225;1;226;0
WireConnection;259;0;257;0
WireConnection;259;1;257;1
WireConnection;259;2;258;0
WireConnection;258;0;257;2
WireConnection;258;1;105;1
WireConnection;257;0;247;0
WireConnection;85;0;84;0
WireConnection;84;3;86;0
WireConnection;90;0;85;0
WireConnection;90;1;91;0
WireConnection;125;0;124;0
WireConnection;125;1;126;0
WireConnection;124;0;263;0
WireConnection;263;0;127;0
WireConnection;263;1;264;0
WireConnection;221;0;125;0
WireConnection;221;1;222;0
WireConnection;270;0;90;0
WireConnection;270;1;269;4
WireConnection;272;0;274;0
WireConnection;280;0;272;0
WireConnection;280;3;279;0
WireConnection;274;0;273;0
WireConnection;274;1;347;0
WireConnection;273;0;277;0
WireConnection;289;0;286;0
WireConnection;289;1;295;0
WireConnection;293;0;290;0
WireConnection;290;0;289;0
WireConnection;286;0;291;0
WireConnection;295;0;287;2
WireConnection;295;1;296;0
WireConnection;294;0;293;0
WireConnection;304;0;221;0
WireConnection;318;0;342;0
WireConnection;324;0;320;0
WireConnection;320;0;318;0
WireConnection;320;1;349;0
WireConnection;311;0;312;0
WireConnection;313;0;327;0
WireConnection;313;1;311;0
WireConnection;327;0;332;0
WireConnection;327;1;324;0
WireConnection;332;0;338;0
WireConnection;338;0;339;0
WireConnection;315;0;313;0
WireConnection;339;0;309;0
WireConnection;339;1;340;0
WireConnection;339;2;344;0
WireConnection;319;0;325;0
WireConnection;342;0;319;0
WireConnection;342;1;344;0
WireConnection;117;0;221;0
WireConnection;117;1;118;0
WireConnection;117;2;119;0
WireConnection;117;3;213;0
WireConnection;117;4;262;3
WireConnection;347;0;275;4
WireConnection;347;1;348;0
WireConnection;309;0;305;0
WireConnection;344;0;343;4
WireConnection;344;1;345;0
WireConnection;349;0;321;0
WireConnection;330;0;317;0
WireConnection;330;1;329;0
WireConnection;331;0;117;0
WireConnection;331;1;350;0
WireConnection;297;0;294;0
WireConnection;297;3;298;0
WireConnection;350;0;330;0
WireConnection;353;0;352;0
WireConnection;353;1;297;0
WireConnection;353;2;354;0
WireConnection;283;1;284;0
WireConnection;283;0;280;0
WireConnection;355;0;229;0
WireConnection;229;0;225;0
WireConnection;229;1;105;2
WireConnection;223;9;259;0
WireConnection;223;3;227;0
WireConnection;214;9;255;0
WireConnection;214;8;356;0
WireConnection;214;3;248;0
WireConnection;215;9;355;0
WireConnection;215;3;228;0
ASEEND*/
//CHKSM=86E6C2DD0E13FBFBC7D9B88B46B5B841BEDE0F2B