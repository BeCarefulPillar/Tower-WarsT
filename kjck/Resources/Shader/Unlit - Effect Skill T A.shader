Shader "Unlit/Effect Skill T A"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
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

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
				
			#include "UnityCG.cginc"

			float _H = 0.0;
			float _S = 0.0;
			float _B = 0.0;
			float _Width = 0.0;
			float2 _Center = float2(0.0 ,0.0);
			float2 _Size = float2(1.0 ,1.0);
			half4 _Color = half4(1.0 ,1.0, 1.0 ,1.0);
	
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
				float2 pos : TEXCOORD1;
				fixed4 color : COLOR;
			};
	
			sampler2D _MainTex;
			float4 _MainTex_ST;
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.pos = v.vertex.xy;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;

				float a = col.a;

				//色相

				//饱和度
				col += (col - (col.r + col.g + col.b) / 3.0) * _S;

				//亮度
				col += _B > 0 ? (1 - col) * _B : col * _B;

				_Size = max(float2(1 ,1) ,_Size);
				float2 vec = (i.pos - _Center)  / _Size;
				float dis = sqrt(vec.x * vec.x + vec.y * vec.y);
				float value = max(1 - abs(dis - 1) * (sqrt(_Size.x * _Size.x * vec.x * vec.x  + _Size.y * _Size.y * vec.y * vec.y) / dis) / _Width, 0);

				col += (_Color - col) * value * _Color.a;

				//恢复透明度
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
