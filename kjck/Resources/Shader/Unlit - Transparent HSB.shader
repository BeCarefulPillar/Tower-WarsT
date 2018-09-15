Shader "Unlit/Transparent HSB"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}

		// required for UI.Mask
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		_ColorMask("Color Mask", Float) = 15
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
		
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Offset -1, -1
		Blend SrcAlpha OneMinusSrcAlpha

		// required for UI.Mask
		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}
		ColorMask[_ColorMask]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
				
			#include "UnityCG.cginc"
	
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
	
			sampler2D _MainTex;
			float4 _MainTex_ST;
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);

				float a = col.a * i.color.a;
				i.color = i.color * 2 - 1;

				//色相
				float maxv = max(max(col.r ,col.g) ,col.b);
				float minv = min(min(col.r ,col.g) ,col.b);
				float dv = maxv - minv;

				if(dv > 0)
				{
					//float h = (maxv - col.r + col.g - minv + col.b - minv) / dv + i.color.r * 3.0;
					float h = (dv - col.r + col.g + col.b - minv) / dv + i.color.r * 3.0 + 6.0;

					h = h > 6.0 ? h - 6.0 : h;
					h = col.g < col.b ? 6.0 - h : h;

					//h = h - (((int)h) / 6.0) * 6.0;
					//if(h < 0) h += 6.0;

					col.r = h > 3.0 ? 6.0 - h : h;
					h += h > 4.0 ? -4.0 : 2.0;
					col.b = h > 3.0 ? 6.0 - h : h;
					h += h > 4.0 ? -4.0 : 2.0;
					col.g = h > 3.0 ? 6.0 - h : h;

					col = clamp(2.0 - col ,0.0 , 1.0) * dv + minv;

					//饱和度
					col += (col - (col.r + col.g + col.b) / 3.0) * i.color.g;
				}

				//亮度
				col += (i.color.b > 0 ? 1 - col : col) * i.color.b;

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
