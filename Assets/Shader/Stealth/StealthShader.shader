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
        //���̒n�_�̃����_�����O���ʂ��L���b�V��
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
            sampler2D _GrabPassTexture; //GrabPass�ŕۑ����ꂽ�e�N�X�`���̊i�[��
            float _ShiftLevel;
            float _RimLevel;
            float4 _MixColor;

            v2f vert(appdata v)
            {
                v2f o;
                //���_��MVP�s��ϊ�
                o.vertex = UnityObjectToClipPos(v.vertex); 
                //�N���b�v���W����X�N���[�����W���v�Z
                o.screenPosition = ComputeScreenPos(o.vertex); 
                //���_�����[���h���W�ŃL���b�V��
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
                //�@�������[���h���W�n�ɕϊ�
                o.normal = UnityObjectToWorldNormal(v.normal); 
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //�����x�N�g�����v�Z
                float3 toEye = normalize(_WorldSpaceCameraPos - i.worldPos); 
                //�����x�N�g���Ɩ@���̓��ς��烊�����x���v�Z
                float rim = dot(i.normal, toEye); 
                //�������x�𒲐�
                rim = pow(rim, _RimLevel);

                //�X�N���[�����W����T���v�����O����̂�tex2Dproj���g�p
                //�������x���Ⴂ�قǃT���v�����O�ʒu���V�t�g�����Ȃ�
                float4 color = tex2Dproj(_GrabPassTexture, i.screenPosition + (1 - rim) * _ShiftLevel);

                //�w�i�Ɗ��S�������Ȃ��悤�ɐF��������
                return color * _MixColor * rim; 
            }
            ENDCG
        }
    }
}
