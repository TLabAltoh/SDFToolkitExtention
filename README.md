# Unity-UI-Rounded-Corners-Extention
This plugin is based on [Unity-UI-Rounded-Corners](https://github.com/kirevdokimov/Unity-UI-Rounded-Corners) created by [kirevdokimov](https://github.com/kirevdokimov). UI components that render based on SDF. Rounded corners, outlines, SDFTexture editor.

## Video
[Here is a demonstration video](https://youtu.be/poQhoVtyI5Y)

## Screenshot
Outlined UI elements  
<img src="Media/quad-corner.png" width="512"></img>  
<img src="Media/quad-corner-component.png" width="512"></img>  
<img src="Media/triangle-corner.png" width="512"></img>  
<img src="Media/triangle-corner-component.png" width="512"></img>  
<img src="Media/custom-shape.png" width="512"></img>  
<img src="Media/custom-shape-component.png" width="512"></img>  
Editor for creating Custom Shapes  
<img src="Media/custom-shape-editor.png" width="512"><img>  

## Requirements
- [SDF Toolkit](https://assetstore.unity.com/packages/tools/utilities/sdf-toolkit-free-50191?locale=ja-JP)
	- This library is used to convert polygon rasterized texture to SDF texture.

## Install
1. Add [SDF Toolkit](https://assetstore.unity.com/packages/tools/utilities/sdf-toolkit-free-50191?locale=ja-JP) to your Unity project from asset store.
2. Clone this repository with the following command
```
git clone https://github.com/TLabAltoh/Unityr-UI-Rounded-Corners-Extension.git
```
4. Place the cloned repository under the Asset directory of the Unity project.

## Create SDF Texture
Select Create ---> SDF Polygon to add a Scriptable Object to the asset. For detailed instructions, please refer to [this video](https://youtu.be/poQhoVtyI5Y)

## Fxaa Support
When creating a Custom Shape, Fxaa is used to reduce aliasing at the boundaries.  
[refarence](https://catlikecoding.com/unity/tutorials/custom-srp/fxaa/)

## Lisence
This repository is MIT licensed.
