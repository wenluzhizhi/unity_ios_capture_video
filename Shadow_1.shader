Shader "Custom/Shadow_1" {
	Properties{
	   _Color("MainColor",Color)=(1,1,1,1)
	   _RimStrenth("Strenth",Range(0,12))=1
	    _IntersectPower("344",Range(0,3))=1
	}
	Subshader{


	      tags{"Queue"="Transparent" "RenderType" = "Transparent"}
	      ZWrite off
          Cull off
          Blend SrcAlpha OneMinusSrcAlpha
          pass{

            
           
              CGPROGRAM
              #pragma vertex vert
              #pragma fragment frag
              #include "unitycg.cginc"
              float _RimStrenth;
              fixed4 _Color;
             float  _IntersectPower;
              sampler2D _CameraDepthTexture;


              struct a2v{
                  float4 vertex:POSITION;
                  float4 normal:NORMAL;
              };

              struct v2f{

                   float4 pos:SV_POSITION;
                   float3 worldNormal:TEXCOORD0;
                   float3 worldViewDir:TEXCOORD1;

                   float4 screenPos : TEXCOORD2;
              };


              v2f vert(a2v v){

                 v2f o;
                 o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
                 o.worldNormal=normalize(mul(v.normal,_Object2World).xyz);
                 float3 worldVertexPos=mul(_Object2World,v.vertex).xyz;
                 o.worldViewDir=normalize(_WorldSpaceCameraPos.xyz-worldVertexPos);



                 o.screenPos = ComputeScreenPos(o.pos);

	            COMPUTE_EYEDEPTH(o.screenPos.z);

                 
                 

                 return o;

              }

              fixed4 frag(v2f i):SV_Target{


                 float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
	             float partZ = i.screenPos.z;

	             float diff = sceneZ - partZ;
	             float intersect = (1 - diff) * _IntersectPower;



                 fixed4 col;
                 float dotV=1- abs(dot(i.worldNormal,i.worldViewDir))*_RimStrenth;

                 float vd=max(dotV,intersect);
                 col=_Color*vd;
                 return col;
              }



              ENDCG
          }
	}
}
