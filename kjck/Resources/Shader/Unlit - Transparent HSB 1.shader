Shader "Hidden/Unlit/Transparent HSB 1"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
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

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs0;
			
				// Sample the texture
				half4 col = tex2D(_MainTex, IN.texcoord);

				float a = col.a * IN.color.a * clamp( min(factor.x, factor.y), 0.0, 1.0);

				IN.color = IN.color * 2 - 1;

				//色相
				float maxv = max(max(col.r ,col.g) ,col.b);
				float minv = min(min(col.r ,col.g) ,col.b);
				float dv = maxv - minv;
				if(dv > 0)
				{
					float h = (dv - col.r + col.g + col.b - minv) / dv + IN.color.r * 3.0 + 6.0;
					h = h > 6.0 ? h - 6.0 : h;
					h = col.g < col.b ? 6.0 - h : h;

					col.r = h > 3.0 ? 6.0 - h : h;
					h += h > 4.0 ? -4.0 : 2.0;
					col.b = h > 3.0 ? 6.0 - h : h;
					h += h > 4.0 ? -4.0 : 2.0;
					col.g = h > 3.0 ? 6.0 - h : h;

					col = clamp(2.0 - col ,0.0 , 1.0) * dv + minv;

					//饱和度
					col += (col - (col.r + col.g + col.b) / 3.0) * IN.color.g;
				}

				//亮度
				col += (IN.color.b > 0 ? 1 - col : col) * IN.color.b;

				//alpha
				col.a = a;

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
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
