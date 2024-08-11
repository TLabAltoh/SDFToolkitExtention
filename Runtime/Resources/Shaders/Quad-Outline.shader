Shader "UI/SDF/Quad/Outline" {
    Properties{
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}
        [HideInInspector] _Color("Tint", Color) = (1,1,1,1)
        [HideInInspector] _StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask("Color Mask", Float) = 15
        [HideInInspector] _UseUIAlphaClip("Use Alpha Clip", Float) = 0

        [HideInInspector] _RectSize("RectSize", Vector) = (0, 0, 0, 0)
        [HideInInspector] _Padding("Padding", Float) = 0
        [HideInInspector] _OuterUV("_OuterUV", Vector) = (0, 0, 0, 0)

        _Radius("Radius", Vector) = (0, 0, 0, 0)

        _OnionWidth("Onion Width", Float) = 0

        _ShadowWidth("Shadow Width", Float) = 0
        _ShadowBlur("Shadow Blur", Float) = 0
        _ShadowPower("Shadow Power", Float) = 0
        _ShadowColor("Shadow Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _ShadowOffset("Shadow Offset", Vector) = (0.0, 0.0, 0.0, 1.0)

        _OutlineWidth("Outline Width", Float) = 0
        _OutlineColor("Outline Color", Color) = (0.0, 0.0, 0.0, 1.0)
    }

    SubShader{
        Tags {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Stencil {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }
        Cull Off
        ZWrite Off
        Lighting Off
        ZTest[unity_GUIZTestMode]
        ColorMask[_ColorMask]
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

        Pass {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"
            #include "SDFUtils.cginc"
            #include "ShaderSetup.cginc"

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local _ SDF_UI_ONION

            #pragma shader_feature_local _ SDF_UI_FASTER_AA
            #pragma shader_feature_local _ SDF_UI_SUPER_SAMPLING_AA
            #pragma shader_feature_local _ SDF_UI_SUBPIXEL_AA

            #pragma shader_feature_local _ SDF_UI_OUTLINE_INSIDE
            #pragma shader_feature_local _ SDF_UI_OUTLINE_OUTSIDE

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            float4 _Radius;
            float4 _RectSize;

            float _Padding;
            float4 _OuterUV;

            float _OnionWidth;

            float _ShadowWidth;
            float _ShadowBlur;
            float _ShadowPower;
            float4 _ShadowColor;
            float4 _ShadowOffset;

            float _OutlineWidth;
            float4 _OutlineColor;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float4 _ClipRect;
            fixed4 _TextureSampleAdd;

            fixed4 frag(v2f i) : SV_Target{

                float2 normalizedPadding = float2(_Padding / _RectSize.x, _Padding / _RectSize.y);

                i.uv = i.uv * (1 + normalizedPadding * 2) - normalizedPadding;

                float2 texSample;
                texSample.x = (1. - i.uv.x) * _OuterUV.x + i.uv.x * _OuterUV.z;
                texSample.y = (1. - i.uv.y) * _OuterUV.y + i.uv.y * _OuterUV.w;

                half4 color = (tex2D(_MainTex, TRANSFORM_TEX(texSample, _MainTex)) + _TextureSampleAdd) * _Color;

                float2 halfSize = _RectSize * .5;
                float2 p = (i.uv - .5) * (halfSize + _OnionWidth) * 2;
                float2 sp = (i.uv - .5 - _ShadowOffset.xy) * (halfSize + _OnionWidth) * 2;

#ifdef SDF_UI_SUPER_SAMPLING_AA
                float2x2 j = JACOBIAN(p);
                float dist = 0.25 * (
                    sdRoundedBox(p + mul(j, float2( 1,  1) * 0.25), halfSize, _Radius) +
                    sdRoundedBox(p + mul(j, float2( 1, -1) * 0.25), halfSize, _Radius) +
                    sdRoundedBox(p + mul(j, float2(-1,  1) * 0.25), halfSize, _Radius) +
                    sdRoundedBox(p + mul(j, float2(-1, -1) * 0.25), halfSize, _Radius));

                j = JACOBIAN(sp);
                float sdist = 0.25 * (
                    sdRoundedBox(sp + mul(j, float2( 1,  1) * 0.25), halfSize, _Radius) +
                    sdRoundedBox(sp + mul(j, float2( 1, -1) * 0.25), halfSize, _Radius) +
                    sdRoundedBox(sp + mul(j, float2(-1,  1) * 0.25), halfSize, _Radius) +
                    sdRoundedBox(sp + mul(j, float2(-1, -1) * 0.25), halfSize, _Radius));
#elif SDF_UI_SUBPIXEL_AA
                float2x2 j = JACOBIAN(p);
                float r = sdRoundedBox(p + mul(j, float2(-0.333, 0)), halfSize, _Radius);
                float g = sdRoundedBox(p, halfSize, _Radius);
                float b = sdRoundedBox(p + mul(j, float2( 0.333, 0)), halfSize, _Radius);
                float4 dist = half4(r, g, b, (r + g + b) / 3.);

                j = JACOBIAN(sp);
                r = sdRoundedBox(sp + mul(j, float2(-0.333, 0)), halfSize, _Radius);
                g = sdRoundedBox(sp, halfSize, _Radius);
                b = sdRoundedBox(sp + mul(j, float2( 0.333, 0)), halfSize, _Radius);
                float4 sdist = half4(r, g, b, (r + g + b) / 3.);
#else
                float dist = sdRoundedBox(p, halfSize, _Radius);
                float sdist = sdRoundedBox(sp, halfSize, _Radius);
#endif

#ifdef SDF_UI_ONION
                dist = abs(dist) - _OnionWidth;
                sdist = abs(sdist) - _OnionWidth;
#endif

#ifdef SDF_UI_SUBPIXEL_AA
                float4 delta = fwidth(dist), sdelta = fwidth(sdist);
#elif defined(SDF_UI_SUPER_SAMPLING_AA) || defined(SDF_UI_FASTER_AA)
                float delta = fwidth(dist), sdelta = fwidth(sdist);
#else
                float delta = 0, sdelta = 0;
#endif

#ifdef SDF_UI_SUBPIXEL_AA
                float4 graphicAlpha = 0, outlineAlpha = 0, shadowAlpha = 0;
#else
                float graphicAlpha = 0, outlineAlpha = 0, shadowAlpha = 0;
#endif

#ifdef SDF_UI_OUTLINE_INSIDE
                graphicAlpha = 1 - smoothstep(-_OutlineWidth, -_OutlineWidth + delta, dist);
                outlineAlpha = 1 - smoothstep(0, delta, dist);
                shadowAlpha = 1 - smoothstep(_ShadowWidth - _ShadowBlur, _ShadowWidth + sdelta, sdist);
#elif SDF_UI_OUTLINE_OUTSIDE
                outlineAlpha = 1 - smoothstep(_OutlineWidth, _OutlineWidth + delta, dist);
                graphicAlpha = 1 - smoothstep(0, delta, dist);
                shadowAlpha = 1 - smoothstep(_OutlineWidth + _ShadowWidth - _ShadowBlur, _OutlineWidth + _ShadowWidth + sdelta, sdist);
#endif

#ifdef SDF_UI_SUBPIXEL_AA
                half4 lerp0 = lerp(
                    half4(lerp(half3(1, 1, 1), _OutlineColor.rgb, outlineAlpha.rgb), outlineAlpha.a * _OutlineColor.a),   // crop image by outline area
                    color,
                    graphicAlpha    // override with graphic alpha
                );

                half4 effects = lerp(
                    half4(_ShadowColor.rgb, shadowAlpha.a * pow(shadowAlpha.a, _ShadowPower) * _ShadowColor.a),
                    lerp0,
                    lerp0.a // override
                );
#else
                half4 lerp0 = lerp(
                    half4(_OutlineColor.rgb, outlineAlpha * _OutlineColor.a),   // crop image by outline area
                    half4(color.rgb, color.a),
                    graphicAlpha    // override with graphic alpha
                );

                half4 effects = lerp(
                    half4(_ShadowColor.rgb, shadowAlpha * pow(shadowAlpha, _ShadowPower) * _ShadowColor.a),
                    lerp0,
                    lerp0.a // override
                );
#endif

                effects *= i.color;

                half t = effects.a - 0.001;

#ifdef UNITY_UI_CLIP_RECT
                effects.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
#endif

#ifdef UNITY_UI_ALPHACLIP
                clip(effects.a - 0.001 > 0.0 ? 1 : -1);
#endif

                return effects;
            }

            ENDCG
        }
    }
}