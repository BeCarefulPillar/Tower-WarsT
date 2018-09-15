Shader "Hidden/Unlit/Merge8 1"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex1 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex2 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex3 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex4 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex5 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex6 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex7 ("Base (RGB), Alpha (A)", 2D) = "black" {}
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _tex1;
			sampler2D _tex2;
			sampler2D _tex3;
			sampler2D _tex4;
			sampler2D _tex5;
			sampler2D _tex6;
			sampler2D _tex7;
			float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
			float2 _ClipArgs0 = float2(1000.0, 1000.0);

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				// Softness factor
				float2 factor = _ClipArgs0 - abs(IN.worldPos) * _ClipArgs0;
			
				// Sample the texture
				half4 col;
				float x = IN.texcoord.x;
				IN.texcoord.x = frac(IN.texcoord.x);
				if(x < 1)
				{
					col = tex2D( _MainTex, IN.texcoord);
				}
				else if(x < 2)
				{
					col = tex2D( _tex1, IN.texcoord);
				}
				else if(x < 3)
				{
					col = tex2D( _tex2, IN.texcoord);
				}
				else if(x < 4)
				{
					col = tex2D( _tex3, IN.texcoord);
				}
				else if(x < 5)
				{
					col = tex2D( _tex4, IN.texcoord);
				}
				else if(x < 6)
				{
					col = tex2D( _tex5, IN.texcoord);
				}
				else if(x < 7)
				{
					col = tex2D( _tex6, IN.texcoord);
				}
				else
				{
					col = tex2D( _tex7, IN.texcoord);
				}
				col *= IN.color;
				col.a *= saturate(min(factor.x, factor.y));
				return col;
			}
			ENDCG
		}
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_tex0]
			{
				Combine Texture * Primary
			}
		}
	}
}
