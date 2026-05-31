// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/ROS/Point"
{
    Properties
    {
        _ColorMin ("Intensity min", Color) = (0, 0, 0, 0)
        _ColorMax ("Intensity max", Color) = (1, 1, 1, 1)
        [Toggle] _ColorIntensity ("Color by intensity", Float) = 0
        [Toggle] _ColorRGB ("Color by RGB", Float) = 0
        [Toggle] _ColorAuto ("Color by auto decoded input", Float) = 0
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
            #pragma multi_compile_local COLOR_INTENSITY COLOR_RGB COLOR_Z COLOR_AUTO

            #include "UnityCG.cginc"
            #include "Assets/RSL/Sensors/Lidar/Materials/Shaders/PointHelper.cginc"


            struct v2f
            {
                float4 pos: SV_POSITION;
                float4 color: COLOR0;
            };

            struct lidardata
            {
                float3 position;
                float intensity;
            };

            StructuredBuffer<float3> _Positions;
            StructuredBuffer<lidardata> _PointData;
            ByteAddressBuffer _PointBytes;

            uniform uint _BaseVertexIndex;
            uniform float _PointSize;
            uniform float4x4 _ObjectToWorld;
            uniform float4 _ColorMin;
            uniform float4 _ColorMax;
            uniform int _PointStep;
            uniform int _ColorOffset;
            uniform float _ColorValueMin;
            uniform float _ColorValueRange;

            v2f vert (uint vertexID: SV_VertexID, uint instanceID: SV_InstanceID)
            {
                v2f o;
                float3 pos = _PointData[instanceID].position;
                // float3 pos = asfloat(_PointBytes.Load3(instanceID * _PointStep));
                float2 uv = _Positions[_BaseVertexIndex + vertexID] * _PointSize;
                uv /= float2(_ScreenParams.x/_ScreenParams.y, 1);
                float4 wpos = mul(_ObjectToWorld, float4(pos, 1.0f));

                o.pos = UnityObjectToClipPos(wpos) + float4(uv,0,0);

                #ifdef COLOR_INTENSITY
                    o.color = lerp(_ColorMin, _ColorMax, _PointData[instanceID].intensity);

                #elif defined(COLOR_RGB)
                    o.color = UnpackRGBA(_PointData[instanceID].intensity);
                #elif defined(COLOR_AUTO)
                    // o.color = getColor(_PointBytes, _ColorOffset, instanceID);
                    float normalizedColor = (getColor(_PointBytes, _PointStep, _ColorOffset, instanceID) - _ColorValueMin) / _ColorValueRange;
                    o.color = lerp(_ColorMin, _ColorMax, normalizedColor); 
                    // o.color = lerp(_ColorMin, _ColorMax, (getColor(_PointBytes, _ColorOffset, instanceID) + 1.0f) * 0.5f);
                #elif defined(COLOR_Z)
                    o.color = lerp(_ColorMin, _ColorMax, (pos.z + 1.0f) * 0.5f);
                #else
                    o.color = float4(1, 0, 1, 1);
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
