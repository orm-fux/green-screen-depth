///////////////////////////////////////////////////////
// Combination of Resahde's DisplayDepth.fx and Valeaour's GreenScreenDepth.fx
// (https://github.com/Valeour/green-screen-depth). Allows to define an in-game
// green screen by making everything that is farther away than a certain 
// distance be in a preset color. Default is a "green screen" color.
///////////////////////////////////////////////////////

#include "Reshade.fxh"

#if __RESHADE__ < 30101
	#define __DISPLAYDEPTH_UI_FAR_PLANE_DEFAULT__ 1000.0
	#define __DISPLAYDEPTH_UI_UPSIDE_DOWN_DEFAULT__ 0
	#define __DISPLAYDEPTH_UI_REVERSED_DEFAULT__ 0
	#define __DISPLAYDEPTH_UI_LOGARITHMIC_DEFAULT__ 0
#else
	#define __DISPLAYDEPTH_UI_FAR_PLANE_DEFAULT__ 1000.0
	#define __DISPLAYDEPTH_UI_UPSIDE_DOWN_DEFAULT__ 0
	#define __DISPLAYDEPTH_UI_REVERSED_DEFAULT__ 0
	#define __DISPLAYDEPTH_UI_LOGARITHMIC_DEFAULT__ 0
#endif

uniform bool bUIUsePreprocessorDefs <
	ui_label = "Use Preprocessor Definitions";
	ui_tooltip = "Enable this to override the values from\n"
	             "'Depth Input Settings' with the\n"
	             "preprocessor definitions. If all is set\n"
	             "up correctly, no difference should be\n"
	             "noticed.";
> = false;

uniform float fUIFarPlane <
	ui_type = "drag";
	ui_label = "Far Plane";
	ui_tooltip = "RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=<value>\n"
	             "Changing this value is not necessary in most cases.";
	ui_min = 0.0; ui_max = 1000.0;
	ui_step = 0.1;
> = __DISPLAYDEPTH_UI_FAR_PLANE_DEFAULT__;

uniform int iUIUpsideDown <
	ui_type = "combo";
	ui_label = "";
	ui_items = "RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=0\0RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=1\0";
> = __DISPLAYDEPTH_UI_UPSIDE_DOWN_DEFAULT__;

uniform int iUIReversed <
	ui_type = "combo";
	ui_label = "";
	ui_items = "RESHADE_DEPTH_INPUT_IS_REVERSED=0\0RESHADE_DEPTH_INPUT_IS_REVERSED=1\0";
> = __DISPLAYDEPTH_UI_REVERSED_DEFAULT__;

uniform int iUILogarithmic <
	ui_type = "combo";
	ui_label = "";
	ui_items = "RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=0\0RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=1\0";
	ui_tooltip = "Change this setting if the displayed surface normals have stripes in them";
> = __DISPLAYDEPTH_UI_LOGARITHMIC_DEFAULT__;

uniform float fDepthCutoff <
	ui_label = "Depth Cutoff";
	ui_tooltip = "Change this setting to adjust the distance in which the\ngreen screen is placed from the camera.";
>
= 0.1;

uniform float3 f3GreenScreenColor <
	ui_label = "Green Screen Color";
	ui_tooltip = "The color fo the green screen.";
> = float3(0, 1, 0);

float GetDepth(float2 texcoord)
{
	//Return the depth value as defined in the preprocessor definitions
	if(bUIUsePreprocessorDefs)
	{
		return ReShade::GetLinearizedDepth(texcoord);
	}

	//Calculate the depth value as defined by the user
	//RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN
	if(iUIUpsideDown)
	{
		texcoord.y = 1.0 - texcoord.y;
	}

	float depth = tex2Dlod(ReShade::DepthBuffer, float4(texcoord, 0, 0)).x;
	//RESHADE_DEPTH_INPUT_IS_LOGARITHMIC
	if(iUILogarithmic)
	{
		const float C = 0.01;
		depth = (exp(depth * log(C + 1.0)) - 1.0) / C;
	}
	//RESHADE_DEPTH_INPUT_IS_REVERSED
	if(iUIReversed)
	{
		depth = 1.0 - depth;
	}

	const float N = 1.0;
	return depth /= fUIFarPlane - depth * (fUIFarPlane - N);
}

void PS_GreenScreen(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	float depth = GetDepth(texcoord).r;
	
	if (depth > fDepthCutoff) {
		color = f3GreenScreenColor;
	} else {
		color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	}
}

technique GreenScreen <
	ui_tooltip = "This shader emulates a green screen. Everything\n"
				 "farther away than a configured distance is rendered\n"
				 "with the same color. The green screen color itself\n
				 "can be configured, too.\n"
				 "\n"
                 "It should work by default. If the green screen is not\n" 
				 "displayed, change the options for *_IS_REVERSED\n"
                 "and *_IS_LOGARITHMIC in the variable editor\n"
                 "until this happens.\n"
                 "\n"
                 "When the right settings are found click\n"
                 "'Edit global preprocessor definitions'\n"
                 "(Variable editor in the 'Home' tab)\n"
                 "and put them in there.\n";
>
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_GreenScreen;
	}
}
