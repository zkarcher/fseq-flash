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
		addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
		addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;
	private var _rect :Rectangle;
	private var _bg :Bitmap;
	private var _opViews :Vector.<OperatorView>;
	
	private var _fseq :FormantSequence;
	private var _isMouseOver :Boolean;
	private var _isMouseDown :Boolean;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	// Which graph is this?
	private function get isFreq() :Boolean { return _type == Const.FREQ; }
	private function get isAmp() :Boolean { return _type == Const.AMP; }
	
	public function set fseq( inFseq:FormantSequence ) :void { _fseq = inFseq; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function redraw() :void {
		for each( var opView:OperatorView in _opViews ) {
			opView.redraw( _fseq );
		}
	}
	
	// As the audio plays, display a glowing vertical bar
	public function scanGlow( col:int ) :void {
		var shp:Shape = new Shape();
		with( shp.graphics ) {
			beginFill( 0xffffff, 0.5 );
			drawRect( col*Const.GRAPH_SCALE_X, 0, Const.GRAPH_SCALE_X, _rect.height );
			endFill();
		}
		addChild( shp );
		Tweener.addTween( shp, {alpha:0, time:0.2, transition:"linear", onComplete:removeDisp, onCompleteParams:[shp]});
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function mouseDownHandler( e:MouseEvent ) :void {
		_isMouseDown = true;
		dispatchEvent( new CustomEvent( CustomEvent.EDIT_START, {type:EditType.FREEHAND_DRAW}) );
	}
	
	private function mouseMoveHandler( e:MouseEvent ) :void {
		if( _isMouseDown ) {
			
		} else if( _isMouseOver ) {
			var closestOp:OperatorView = closestOpToMouse();
			hiliteOps( [closestOp] );
		}
	}
	
	private function mouseUpHandler( e:MouseEvent ) :void {
		if( _isMouseDown ) {
			dispatchEvent( new CustomEvent( CustomEvent.EDIT_STOP ) );
		}
		_isMouseDown = false;
	}
	
	private function mouseOverHandler( e:MouseEvent ) :void {
		_isMouseOver = true;
	}
	
	private function mouseOutHandler( e:MouseEvent ) :void {
		_isMouseOver = false;
		
		if( _isMouseDown ) {
			
		} else {
			hiliteOps( null );	// cancel all hilites
		}
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function closestOpToMouse() :OperatorView {
		var frame:int = mouseX / Const.GRAPH_SCALE_X;

		var bestOp:OperatorView = null;
		var bestDistance:Number = 999999;
		for each( var opView:OperatorView in _opViews ) {
			var thisDistance:Number = Math.abs(mouseY - opView.yAtFrame(_fseq, frame));
			if( thisDistance < bestDistance ) {
				bestDistance = thisDistance;
				bestOp = opView;
			}
		}
		
		return bestOp;
	}
	
	private function hiliteOps( liteOps:Array ) :void {
		var opView:OperatorView;
		for each( opView in _opViews ) {
			opView.hilite = false;
		}

		if( liteOps ) {
			for each( opView in liteOps ) {
				opView.hilite = true;
			}
		}
	}
	
	// Tweener callback
	private function removeDisp( disp:DisplayObject ) :void {
		if( disp.parent ) disp.parent.removeChild( disp );
	}
}

}

