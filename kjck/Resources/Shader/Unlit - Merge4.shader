Shader "Unlit/Merge4"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex1 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex2 ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_tex3 ("Base (RGB), Alpha (A)", 2D) = "black" {}
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
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _tex1;
			sampler2D _tex2;
			sampler2D _tex3;
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col;
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
				else
				{
					col = tex2D( _tex3, IN.texcoord);
				}
				return col * IN.color;
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
			Offset -1, -1
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
