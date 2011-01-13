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
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.view.*;

public class GraphView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function GraphView( type:String ) {
		_type = type;
		
		_rect = new Rectangle( 0, 0, Const.FRAMES * Const.GRAPH_SCALE_X, isFreq ? Const.GRAPH_FREQ_HEIGHT : Const.GRAPH_AMP_HEIGHT );
		scrollRect = _rect;
		
		_bg = new Bitmap( new BitmapData( _rect.width, _rect.height, false, 0x0 ), PixelSnapping.ALWAYS, false );
		addChild( _bg );
		
		_opViews = new Vector.<OperatorView>();
		var i:int;
		for( i=0; i<Const.VOICED_OPS; i++ ) {
			_opViews.push( new OperatorView( Const.VOICED, i, _rect ));
		}
		for( i=0; i<Const.UNVOICED_OPS; i++ ) {
			_opViews.push( new OperatorView( Const.UNVOICED, i, _rect ));
		}
		
		// Add all the opViews to the canvas
		for each( var opView:OperatorView in _opViews ) {
			addChild( opView );
		}
		
		addEventListener( Event.ENTER_FRAME, initEnterFrame );
	}
	
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
		stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;
	private var _rect :Rectangle;
	private var _bg :Bitmap;
	private var _opViews :Vector.<OperatorView>;
	
	private var _isMouseDown :Boolean;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	// Which graph is this?
	private function get isFreq() :Boolean { return _type == Const.FREQ; }
	private function get isAmp() :Boolean { return _type == Const.AMP; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function redraw( fseq:FormantSequence ) :void {
		for each( var opView:OperatorView in _opViews ) {
			opView.redraw( fseq );
		}
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function mouseDownHandler( e:MouseEvent ) :void {
		
	}
	
	private function mouseMoveHandler( e:MouseEvent ) :void {
		
	}
	
	private function mouseUpHandler( e:MouseEvent ) :void {
		
	}
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

