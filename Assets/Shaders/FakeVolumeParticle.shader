Shader "Custom/Fake Volume Particle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightRange ("LightRange", Range(1, 64)) = 1
        _LightPower ("LightPower", Range(1, 32)) = 4
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent" 
            "LightMode"="ForwardBase" 
        }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 uv : TEXCOORD0;
                fixed4 vtx_color : COLOR0;
                fixed4 light_color : COLOR1;
            };

            sampler2D _MainTex;
            float _LightRange;
            float _LightPower;

            v2f vert (appdata v)
            {
                v2f o;

                float4 pos = mul( unity_ObjectToWorld, v.vertex );
                float dist = distance( pos, float3( unity_4LightPosX0[0], unity_4LightPosY0[0], unity_4LightPosZ0[0] ));
                float rate = 1.0 - pow( smoothstep( 0, _LightRange, dist ), _LightPower );

                o.vertex = mul( UNITY_MATRIX_VP, pos );
                o.uv = v.uv;
                o.vtx_color = v.color;
                o.light_color = fixed4( unity_LightColor[0].rgb, 0 ) * rate;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D( _MainTex, i.uv );
                return tex * i.vtx_color + (i.light_color * (1.0 - tex.a * tex.a));
            }
            ENDCG
        }
    }
}


