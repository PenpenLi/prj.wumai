Shader "UL/Extrusion" {
	Properties {
//		_ColorTint ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
//		_Amount ("Extrusion Amount", Range(-0.5, 0.5)) = 0.01
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		
		// surf - which surface function.
		// CustomLambert - which lighting model to use.
		// vertex:myvert - use custom vertex modification function.
		// finalcolor:mycolor - use custom final color modification function.
		// addshadow - generate a shadow caster pass. Because we modify the vertex position, the shder needs special shadows handling.
		// exclude_path:deferred/exclude_path:prepas - do not generate passes for deferred/legacy deferred rendering path.
		// nometa - do not generate a “meta” pass (that’s used by lightmapping & dynamic global illumination to extract surface information).
		#pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor
		#pragma target 3.0
		
//		fixed4 _ColorTint;
		sampler2D _MainTex;
//		half _Amount;
		
		struct Input {
			float2 uv_MainTex;
		};
		
		void myvert (inout appdata_full v) {
			v.vertex.xyz += v.normal * 0.02;
		}
		
		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Alpha = tex.a;
//			o.Normal = UnpackNormal(tex2D(_MainTex, IN.uv_MainTex));
		}
		
		half4 LightingCustomLambert (SurfaceOutput s, half3 lightDir, half atten) {
//			half NdotL = dot(s.Normal, lightDir);
//			half4 c;
//			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
//			c.a = s.Alpha;
//			return c;

			half4 c = half4(1,1,1,1);  
            c.rgb = s.Albedo;  
            c.a = s.Alpha;  
            return c;  
		}
		
		void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
//			color *= _ColorTint;
		}
		
		ENDCG
	}
	FallBack "Diffuse"
}
