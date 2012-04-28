package fseq.view {

/**
 *	Class description.
 *
 *	@langversion ActionScript 3.0
 *	@playerversion Flash 10.0
 *
 *	@author Zach Archer
 *	@since  20110108
 */

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import fl.events.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.view.*;

public class ToolButtonView extends ToolButton_mc
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	// Editor tools
	public static const FREEHAND :String = "freehand";
	public static const LINE :String = "line";
	public static const TRANSPOSE :String = "transpose";
	public static const VOWEL_DRAW :String = "vowel_draw";
	public static const FUNC_DRAW :String = "func_draw";
	public static const ALL_TOOLS :Array = [FREEHAND,LINE,TRANSPOSE,VOWEL_DRAW,FUNC_DRAW];
	
	// Vowel drawing
	private static const FREQ_1 :String = "FREQ_1";
	private static const FREQ_2 :String = "FREQ_2";
	private static const FREQ_3 :String = "FREQ_3";
	private static const VOWEL_PRESSURE :String = "VOWEL_PRESSURE";
	
	// Function drawing
	public static const SAW :String = "saw";
	public static const SQUARE :String = "square";
	public static const SINE :String = "sine";
	public static const TRIANGLE :String = "triangle";
	public static const OCEAN :String = "ocean";
	public static const NOISE :String = "noise";
	public static const ALL_FUNC_SHAPES :Array = [SAW,SQUARE,SINE,TRIANGLE,OCEAN,NOISE];
	
	// Function drawing tool: sets these keys in the _params object
	private static const FUNC_SHAPE :String = "FUNC_SHAPE";
	private static const FUNC_WIDTH :String = "FUNC_WIDTH";
	private static const FUNC_PRESSURE :String = "FUNC_PRESSURE";
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function ToolButtonView( inType:String ) {
		_type = inType;
		gotoAndStop( _type );
		useHandCursor = buttonMode = true;
		
		addEventListener( Event.ADDED_TO_STAGE, addedToStage );
	}
	
	private function addedToStage( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
		
		stage.addEventListener( MouseEvent.MOUSE_MOVE, stageMouseMove );
		stage.addEventListener( MouseEvent.MOUSE_UP, stageMouseUp );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;
	private var _isActive :Boolean = false;
	
	private var _controls :Sprite;
	private var _isMouseDown :Boolean = false;
	
	private var _params :Object = {};
	
	private var _funcNoise :Vector.<Number>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get type() :String { return _type; }
	public function get isActive() :Boolean { return _isActive; }
	
	public function set hilite( b:Boolean ) :void {
		_isActive = b;
		if( _isActive ) {
			transform.colorTransform = new ColorTransform();
			createControls();
		} else {
			transform.colorTransform = new ColorTransform( 0.4, 0.4, 0.4, 1, 0,0,0,0 );	// darker grey
			destroyControls();
		}
	}
	
	// Edit types: FREEHAND tool type -> EDIT_FREEHAND_DRAW, etc.
	public function get editType() :String { return EditType.typeForTool(_type); }
	
	// Vowel drawing
	// Reverse-engineered from: http://www.tuninst.net/HumanVoice/snd-hear/snd-hear.htm#IPA-vow-diagram-cardinal-vow
	public function get freq1() :Number { return _params[FREQ_1]; }
	public function get freq2() :Number { return _params[FREQ_2]; }
	public function get freq3() :Number { return _params[FREQ_3]; }
	public function get vowelPressure() :Number { return _params[VOWEL_PRESSURE]; }	// 0..100
	
	// Function drawing
	public function get funcShape() :String { return _params[FUNC_SHAPE]; }
	public function get funcWidth() :int { return _params[FUNC_WIDTH]; }	// 1..512, always 2^n
	public function get funcPressure() :Number { return _params[FUNC_PRESSURE]; }	// 0..100
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	public function resetFuncNoise() :void {
		_funcNoise = new Vector.<Number>( Const.FRAMES, true );
		for( var i:int=0; i<Const.FRAMES; i++ ) {
			_funcNoise[i] = Math.random();
		}
	}
	
	// All functions must move from 0..1
	public function funcValueAt( p:int ) :Number {
		var phase:Number = (p % funcWidth) / Number(funcWidth);	// 0..1, then it wraps around
		
		switch( funcShape ) {
			case SAW:	
				return phase;
				
			case SQUARE:
				return (phase<0.5) ? 0 : 1;
				
			case TRIANGLE:
				var t:Number = phase * 2.0;	// t = 0..2, then it wraps
				return (t < 1.0) ? t : (2.0-t);
				
			case SINE:
				return ((-Math.cos( phase*Math.PI*2 )) + 1) / 2;
				
			case OCEAN:
				// Hmm. Quadratic shaping?
				var quad:Number = ((phase-0.5)*2);
				quad *= quad;
				return 1.0 - quad;
				
			case NOISE:
				var idx:int = int( Math.floor( Number(p) / funcWidth ));
				return _funcNoise[idx];
		}
		
		trace("** funcValueAt: I have no shape", funcShape, p);
		return 0;
	}

	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	// VOWEL_DRAW
	private function vowelMouseDown( e:MouseEvent ) :void {
		_isMouseDown = true;
		updateVowelKnob();
	}
	
	private function stageMouseMove( e:MouseEvent ) :void {
		if( !_isMouseDown ) return;	// We're not being dragged, so we don't care
		
		switch( _type ) {
			case VOWEL_DRAW:	updateVowelKnob(); break;
		}
	}

	private function stageMouseUp( e:MouseEvent ) :void {
		_isMouseDown = false;
	}
	
	private function vowelPressureSliderChange( e:SliderEvent ) :void {
		updateVowelPressure();
	}
	
	private function functionShapeClick( e:MouseEvent ) :void {
		for each( var shape:String in ALL_FUNC_SHAPES ) {
			if( _controls[shape] && (_controls[shape] == e.currentTarget) ) {
				_params[FUNC_SHAPE] = shape;
			}
		}
		updateFuncShape();
	}

	private function funcWidthSliderChange( e:SliderEvent ) :void {
		updateFuncWidth();
	}

	private function funcPressureSliderChange( e:SliderEvent ) :void {
		updateFuncPressure();
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function createControls() :void {
		if( !_controls ) {
			switch( _type ) {
				case VOWEL_DRAW:
					var vs:VowelSelector_mc = new VowelSelector_mc();
					vs.knob.mouseEnabled = vs.knob.mouseChildren = false;
					vs.bg.addEventListener( MouseEvent.MOUSE_DOWN, vowelMouseDown, false, 0, true );
					vs.pressure_slider.addEventListener( SliderEvent.CHANGE, vowelPressureSliderChange, false, 0, true );
					_controls = vs;
					updateVowelKnob();
					updateVowelPressure();
					break;
					
				case FUNC_DRAW:
					var fs:FuncSelector_mc = new FuncSelector_mc();
					
					// All func_buttons: stop on the correct shapes
					for each( var shape:String in ALL_FUNC_SHAPES ) {
						fs[shape].gotoAndStop( shape );
						fs[shape].addEventListener( MouseEvent.CLICK, functionShapeClick, false, 0, true );
					}
					fs.width_slider.addEventListener( SliderEvent.CHANGE, funcWidthSliderChange, false, 0, true );
					fs.pressure_slider.addEventListener( SliderEvent.CHANGE, funcPressureSliderChange, false, 0, true );
					_controls = fs;
					
					_params[FUNC_SHAPE] = ALL_FUNC_SHAPES[0];
					updateFuncShape();
					updateFuncWidth();
					updateFuncPressure();
					
					break;
			}
		}
		
		if( _controls ) {
			AppController.instance.editorView.toolControlsSprite.addChild( _controls );
		}
	}
	
	private function destroyControls() :void {
		// Remove from parent, but don't delete the controls.
		if( _controls && _controls.parent ) _controls.parent.removeChild( _controls );
	}
	
	private function updateVowelKnob() :void {
		if( !_controls ) return;	// sanity check
		var vs:VowelSelector_mc = VowelSelector_mc(_controls);
		
		// Constrain the knob within the 80x80 rect
		var pt:Point = new Point( _controls.mouseX, _controls.mouseY );
		vs.knob.x = pt.x = Num.clamp( pt.x, 0, 80 );
		vs.knob.y = pt.y = Num.clamp( pt.y, 0, 80 );
		
		// The position of the knob controls the formant frequencies
		_params[FREQ_1] = Num.interpolate( 240, 920, pt.y / 80.0 );
		_params[FREQ_2] = Num.interpolate( 2300, 700, pt.x / 80.0 );
		
		// Freq 3 is weird. Upper-left corner is 3100 or so. Moving CCW around the grid: W=2500, SW=2450, S=2500, SE=2450, NE=2250.
		// Let's take the direction of the knob from the center, and interpolate over these values.
		var rads:Number = Math.atan2( -(pt.y-40.0), pt.x-40.0 );
		rads = Num.wrap( rads, Math.PI*2 );	// 0...PI*2
		
		var f3s:Array = [2350,2450,2800,3100,2500,2450,2500,2450,2350];
		var region:Number = (rads / (Math.PI*2)) * 8.0;
		_params[FREQ_3] = Num.interpolate( f3s[Math.floor(region)], f3s[Math.ceil(region)], region % 1.0 );
		
		//trace("freqs:", _params[FREQ_1], _params[FREQ_2], _params[FREQ_3]);
	}
	
	private function updateVowelPressure() :void {
		if( !_controls ) return;	// sanity check
		var vs:VowelSelector_mc = VowelSelector_mc(_controls);
		vs.pressure_tf.text = "Pressure: " + String(int(vs.pressure_slider.value)) + "%";
		_params[VOWEL_PRESSURE] = vs.pressure_slider.value;
	}
	
	// Function drawing: Update the controls
	private function updateFuncShape() :void {
		if( !_controls ) return;	// sanity check
		var fs:FuncSelector_mc = FuncSelector_mc(_controls);
		// Assuming that _params[FUNC_SHAPE] is already set
		for each( var shape:String in ALL_FUNC_SHAPES ) {
			if( shape == _params[FUNC_SHAPE] ) {
				fs[shape].transform.colorTransform = new ColorTransform();	// No color change
			} else {
				fs[shape].transform.colorTransform = new ColorTransform( 0.3,0.3,0.3,1, 0,0,0,0 );	// Darker grey
			}
		}
	}
	
	private function updateFuncWidth() :void {
		if( !_controls ) return;	// sanity check
		var fs:FuncSelector_mc = FuncSelector_mc(_controls);
		var w:int = int( Math.pow( 2.0, fs.width_slider.value ));
		fs.width_tf.text = "Width: " + String(w);
		_params[FUNC_WIDTH] = w;
	}

	private function updateFuncPressure() :void {
		if( !_controls ) return;	// sanity check
		var fs:FuncSelector_mc = FuncSelector_mc(_controls);
		fs.pressure_tf.text = "Pressure: " + String(int(fs.pressure_slider.value)) + "%";
		_params[FUNC_PRESSURE] = fs.pressure_slider.value;
	}
}

}

