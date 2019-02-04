# Green Screen Depth Shader

Green screen depth shader. Works with Reshade 3.1.1 and newer. This is a fork of [Valeour's GreenScreenDepth.fx](https://github.com/Valeour/green-screen-depth). This version here has been merged with some code of Reshade's DisplayDepth.fx shader.

## [Download](https://github.com/orm-fux/green-screen-depth/releases/download/v1.0/reshade-greenscreen.zip)

![Dark Souls 3 Example](https://raw.githubusercontent.com/orm-fux/green-screen-depth/master/green-screen-sample.png)


Contains two adjustable values iretcly related to the green screen:
- Green screen color - Doesn't have to be green
- Depth cut off - This is how far away from the camera until the green screen kicks in.

Please ensure that ```RESHADE_DEPTH_INPUT_IS_REVERSED``` is not enabled in settings, or it will cause the shader to work incorrectly.

To install, simply place the GreenScreenDepth.fx in your shader folder of the game you installed Reshade on.
