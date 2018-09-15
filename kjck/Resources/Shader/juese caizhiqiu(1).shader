Shader "Custom/double7" {
    Properties {  
        _MainTex ("Albedo (RGB)", 2D) = "white" {}  
		_MainTint("Color", Color)= (1,1,1,1) 
		_Cut("Cut", Range(0,1)) = 0.5  
    }  
    SubShader {  
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }  
        LOD 200  
        cull off
		Lighting On 
		Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM  
        //#pragma surface surf Lambert alpha   
		#pragma surface surf Lambert alphatest:_Cut 
        sampler2D _MainTex;  
		fixed4 _MainTint;  

        struct Input {  
            float2 uv_MainTex;  
        };  
  
        void surf (Input IN, inout SurfaceOutput o)     
		{    
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _MainTint;  
			o.Albedo = c.rgb;  
			o.Alpha = c.a;  
		}   
  
        ENDCG  
    }  
    FallBack "Diffuse"  
}
