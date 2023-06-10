Shader "MyShader/StealthShader"
{
    Properties
    {
        _MixColor("Mix Color", Color) = (1, 1, 1, 1)
        _ShiftLevel("Shift", Range(0.0, 1.0)) = 0
        _RimLevel("RimLevel", Range(0.0, 10.0)) = 0
    }
        SubShader
    {
        Tags { "RenderType" = "Transparent" }
        LOD 100
        //この地点のレンダリング結果をキャッシュ
        GrabPass { "_GrabPassTexture" } 

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPosition : TEXCOORD1;
                float3 normal: TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GrabPassTexture; //GrabPassで保存されたテクスチャの格納先
            float _ShiftLevel;
            float _RimLevel;
            float4 _MixColor;

            v2f vert(appdata v)
            {
                v2f o;
                //頂点をMVP行列変換
                o.vertex = UnityObjectToClipPos(v.vertex); 
                //クリップ座標からスクリーン座標を計算
                o.screenPosition = ComputeScreenPos(o.vertex); 
                //頂点をワールド座標でキャッシュ
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
                //法線をワールド座標系に変換
                o.normal = UnityObjectToWorldNormal(v.normal); 
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //視線ベクトルを計算
                float3 toEye = normalize(_WorldSpaceCameraPos - i.worldPos); 
                //視線ベクトルと法線の内積からリム強度を計算
                float rim = dot(i.normal, toEye); 
                //リム強度を調整
                rim = pow(rim, _RimLevel);

                //スクリーン座標からサンプリングするのでtex2Dprojを使用
                //リム強度が低いほどサンプリング位置をシフトさせない
                float4 color = tex2Dproj(_GrabPassTexture, i.screenPosition + (1 - rim) * _ShiftLevel);

                //背景と完全同化しないように色を混ぜる
                return color * _MixColor * rim; 
            }
            ENDCG
        }
    }
}
