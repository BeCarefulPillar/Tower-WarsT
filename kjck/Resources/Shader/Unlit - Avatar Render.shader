Shader "Unlit/Avatar Render"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_Range ("Range", Range(0,0.5)) = 0.35
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
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Range;
	
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
			};
	
			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col = tex2D(_MainTex, IN.texcoord);

				float2 temp = IN.texcoord - float2(0.5, 0.5);
				float r = 0.35;
				if (abs(temp.x) > _Range && abs(temp.y) > _Range)
				{
					float dis = distance(temp, float2(temp.x > 0 ? _Range : -_Range, temp.y > 0 ? _Range : -_Range));
					if (dis > 0.5 - _Range)
					{
						col.a = saturate((0.52 - _Range - dis) / 0.02);
					}
				}
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
