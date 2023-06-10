Shader "MyShader/RimLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _RimColor ("RimColor", Color) = (1,1,1,1)
        _RimPower("RimPower", float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _RimColor;
            half _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4x4 modelMatrix = unity_ObjectToWorld;
                // �@���x�N�g���̌v�Z
                o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                // ���������̃x�N�g���̌v�Z
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(modelMatrix, v.vertex).xyz);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                // ��̃x�N�g���������ɋ߂��������G�~�b�V��������������
                half rim = 1.0 - abs(dot(i.viewDir, i.normalDir));
                fixed3 emission = _RimColor.rgb * pow(rim, _RimPower) * _RimPower;
                col.rgb += emission;
                col = fixed4(col.rgb, 1.0);

                return col;
            }
            ENDCG
        }
    }
}