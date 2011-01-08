package com.zacharcher.color
{

import flash.display.*;
import flash.geom.*;

public class ColorUtil extends Object
{
	
	public function ColorUtil()
	{
		trace("** ColorUtil: Static class, do not instantiate");
	}
	
	// All colors display as color:uint
	public static function tint( disp:DisplayObject, color:uint ) :void {
		var c:Object = rgb(color);
		disp.transform.colorTransform = new ColorTransform( 0,0,0,1, c['r'],c['g'],c['b'],0 );
	}
	
	// Colors are screened with color:uint (all colors become brighter)
	public static function screen( disp:DisplayObject, color:uint ) :void {
		var c:Object = rgb(color);
		disp.transform.colorTransform = new ColorTransform( 
			(255-c['r'])/255, (255-c['g'])/255, (255-c['b'])/255, 1, 
			c['r'],c['g'],c['b'],0 
		);
	}
	
	public static function brightness( disp:DisplayObject, bright:Number ) :void {
		disp.transform.colorTransform = new ColorTransform( bright,bright,bright,1, 0,0,0,0 );
	}
	
	public static function rgb( color:uint ) :Object {
		return {
			r: (color & 0xff0000) >> 16,
		 	g: (color & 0x00ff00) >> 8,
			b: (color & 0x0000ff)
		};
	}
	
}

}

