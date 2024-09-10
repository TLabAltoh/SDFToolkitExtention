/**
* SDF fragment after determined distance
*/

//////////////////////////////////////////////////////////////

#ifdef SDF_UI_STEP_SETUP

#ifdef SDF_UI_AA_SUBPIXEL
float4 delta = half4(0, 0, 0, 0);
#else
float delta = 0;
#endif

#endif // SDF_UI_STEP_SETUP

//////////////////////////////////////////////////////////////

#ifdef SDF_UI_STEP_SHADOW
#ifdef SDF_UI_SHADOW_ENABLED

#ifdef SDF_UI_AA_SUBPIXEL
delta = fwidth(dist) * .5;
#elif defined(SDF_UI_AA_SUPER_SAMPLING) || defined(SDF_UI_AA_FASTER)
delta = fwidth(dist) * .5;
#else
delta = 0;
#endif

#ifdef SDF_UI_AA_SUBPIXEL
float4 alpha = 0, tmp0 = 0, tmp1 = 0;
#else
float alpha = 0, tmp0 = 0, tmp1 = 0;
#endif

tmp0 = 1 - saturaterange(_ShadowBorder - _ShadowBlur - delta, _ShadowBorder + delta, dist);
tmp1 = 1 - smoothstep(_ShadowBorder - _ShadowBlur - delta, _ShadowBorder + delta, dist);
alpha = tmp0 * (1. - _ShadowGaussian) + tmp1 * _ShadowGaussian;

{
	half4 layer0 = _ShadowColor;
	layer0.a *= alpha;
	layer0.a *= (1. - effects.a);
	layer0.rgb *= layer0.a;
	effects = effects + layer0;
}

#endif	// SDF_UI_SHADOW_ENABLED
#endif	// SDF_UI_STEP_SHADOW

//////////////////////////////////////////////////////////////

#ifdef SDF_UI_STEP_SHAPE_OUTLINE

#ifdef SDF_UI_AA_SUBPIXEL
delta = fwidth(dist) * .5;
#elif defined(SDF_UI_AA_SUPER_SAMPLING) || defined(SDF_UI_AA_FASTER)
delta = fwidth(dist) * .5;
#else
delta = 0;
#endif

#ifdef SDF_UI_AA_SUBPIXEL
float4 graphicAlpha = 0, outlineAlpha = 0;
#else
float graphicAlpha = 0, outlineAlpha = 0;
#endif

#if defined(SDF_UI_AA_SUBPIXEL) || defined(SDF_UI_AA_SUPER_SAMPLING) || defined(SDF_UI_AA_FASTER)

outlineAlpha = 1 - saturaterange(_OutlineBorder - delta, _OutlineBorder + delta, dist);
graphicAlpha = 1 - saturaterange(_GraphicBorder - delta, _GraphicBorder + delta, dist);

#else
graphicAlpha = 1 - (dist >= _GraphicBorder);
outlineAlpha = 1 - (dist >= _OutlineBorder);
#endif

{
	half4 layer0 = _OutlineColor; layer0.rgb *= layer0.a;
	half4 layer1 = color; layer1.rgb *= layer1.a;
	half4 layer2 = lerp(layer0, layer1, graphicAlpha);
	effects = layer2 * outlineAlpha;
}

#endif	// SDF_UI_STEP_SHAPE_OUTLINE

//////////////////////////////////////////////////////////////