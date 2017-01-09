Shader "UL/MapAlpha" {
	Properties {
		_Color ("Main Color",Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", Range (0,1)) = 0.5
	}

//	SubShader {
//		Tags {
//		"Queue"="AlphaTest" 
//		"IgnoreProjector"="True" 
//		"RenderType"="TransparentCutout"
//		}
//		LOD 200
//
//        Pass {
//        	Tags { "LightMode" = "Vertex" }
//
//        	ZTest LEqual
//        	//AlphaTest Greater
//        	AlphaTest Greater [_Cutoff]
//
//            Material {
//                Diffuse [_Color]
//                Ambient [_Color]
//            }
//            Lighting On
//            BindChannels {
//				Bind "Vertex", vertex
//				Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
//				Bind "texcoord", texcoord1 // main uses 1st uv
//			}
//			
//			SetTexture [unity_Lightmap] {
//				matrix [unity_LightmapMatrix]
//				combine texture
//			}
//            
//            SetTexture [_MainTex] {
//				Combine texture * primary DOUBLE, texture * primary
//			} 
//        }

        // Lightmapped, encoded as dLDR
//		Pass {
//			Tags { "LightMode" = "VertexLM" }
//			AlphaTest Greater [_Cutoff]
//			Lighting Off
//			BindChannels {
//				Bind "Vertex", vertex
//				Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
//				Bind "texcoord", texcoord1 // main uses 1st uv
//			}
//			
//			SetTexture [unity_Lightmap] {
//				matrix [unity_LightmapMatrix]
//				combine texture
//			}
//			SetTexture [_MainTex] {
//				combine texture * previous DOUBLE, constant // UNITY_OPAQUE_ALPHA_FFP
//			}
//		}
//		
        
//	} 

	SubShader {
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert alphatest:_Cutoff

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}

	FallBack "Diffuse"
}
