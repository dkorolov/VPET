﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/*
-----------------------------------------------------------------------------
This source file is part of VPET - Virtual Production Editing Tool
http://vpet.research.animationsinstitut.de/
http://github.com/FilmakademieRnd/VPET

Copyright (c) 2016 Filmakademie Baden-Wuerttemberg, Institute of Animation

This project has been realized in the scope of the EU funded project Dreamspace
under grant agreement no 610005.
http://dreamspaceproject.eu/

This program is free software; you can redistribute it and/or modify it under
the terms of the MIT License as published by the Open Source Initiative.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the MIT License for more details.

You should have received a copy of the MIT License along with
this program; if not go to
https://opensource.org/licenses/MIT
-----------------------------------------------------------------------------
*/

Shader "Hidden/OutlineEffect" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
			LOD 200
			ZTest Off
			ZWrite Off
			Cull Off
			Lighting Off
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#pragma noshadow nofog
			#pragma target 3.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _OutlineSource;

			struct v2f {
			   float4 position : SV_POSITION;
			   float2 uv : TEXCOORD0;
			};
			
			v2f vert(appdata_img v)
			{
			   	v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				
			   	return o;
			}

			float _LineThicknessX;
			float _LineThicknessY;
			float _LineIntensity;
			uniform float4 _MainTex_TexelSize;

			half4 frag (v2f input) : COLOR
			{	
				float2 uv = input.uv;

				half4 originalPixel = tex2D(_MainTex,input.uv);
				half4 outlineSource = tex2D(_OutlineSource, uv);
								
				half h = .95;
				half4 outline = 0;
				bool hasOutline = false;

				half4 sample1 = tex2D(_OutlineSource, uv + float2(_LineThicknessX,0.0) * _MainTex_TexelSize.x * 1000.0f);
				half4 sample2 = tex2D(_OutlineSource, uv + float2(-_LineThicknessX,0.0) * _MainTex_TexelSize.x * 1000.0f);
				half4 sample3 = tex2D(_OutlineSource, uv + float2(.0,_LineThicknessY) * _MainTex_TexelSize.y * 1000.0f);
				half4 sample4 = tex2D(_OutlineSource, uv + float2(.0,-_LineThicknessY) * _MainTex_TexelSize.y * 1000.0f);
				
				if(outlineSource.a > h)
				{
					if (sample1.a < h || sample2.a < h || sample3.a < h || sample4.a < h)
					{
						outline = half4(outlineSource.rgb, 1.0) * _LineIntensity;
						hasOutline = true;
					}
				}			
									
				if (hasOutline)
					return originalPixel + outline;
				else
					return originalPixel;

			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}