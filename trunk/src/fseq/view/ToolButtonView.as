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
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------

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
	
	private function vowelOpacitySliderChange( e:SliderEvent ) :void {
		updateVowelOpacity();
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function createControls() :void {
		switch( _type ) {
			case VOWEL_DRAW:
				var vs:VowelSelector_mc = new VowelSelector_mc();
				vs.knob.mouseEnabled = vs.knob.mouseChildren = false;
				vs.bg.addEventListener( MouseEvent.MOUSE_DOWN, vowelMouseDown, false, 0, true );
				vs.opacity_slider.addEventListener( SliderEvent.CHANGE, vowelOpacitySliderChange, false, 0, true );
				_controls = vs;
				break;
		}
		
		if( _controls ) {
			AppController.instance.editorView.toolControlsSprite.addChild( _controls );
		}
	}
	
	private function destroyControls() :void {
		if( _controls && _controls.parent ) _controls.parent.removeChild( _controls );
		_controls = null;
	}
	
	private function updateVowelKnob() :void {
		if( !_controls ) return;	// sanity check
		var vs:VowelSelector_mc = VowelSelector_mc(_controls);
		
		// Constrain the knob within the 80x80 rect
		var pt:Point = new Point( _controls.mouseX, _controls.mouseY );
		vs.knob.x = pt.x = Num.clamp( pt.x, 0, 80 );
		vs.knob.y = pt.y = Num.clamp( pt.y, 0, 80 );
	}
	
	private function updateVowelOpacity() :void {
		if( !_controls ) return;	// sanity check
		var vs:VowelSelector_mc = VowelSelector_mc(_controls);
		vs.opacity_tf.text = "Opacity: " + String(int(vs.opacity_slider.value));
	}
}

}

