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
				
		_opViews = new Vector.<OperatorView>();
		var i:int;
		for( i=0; i<Const.VOICED_OPS; i++ ) {
			_opViews.push( new OperatorView( Const.VOICED, i, _rect ));
		}
		for( i=0; i<Const.UNVOICED_OPS; i++ ) {
			_opViews.unshift( new OperatorView( Const.UNVOICED, i, _rect ));
		}
		_opViews.push( new OperatorView( Const.PITCH, 0, _rect ));
		
		// Add all the opViews to the canvas
		for each( var opView:OperatorView in _opViews ) {
			addChild( opView );
		}
		
		_bg = new Bitmap( new BitmapData( _rect.width, _rect.height, false, 0x0 ), PixelSnapping.ALWAYS, false );
		addChildAt( _bg, 0 );
		
		addEventListener( Event.ENTER_FRAME, initEnterFrame );
	}
	
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		mouseChildren = false;
		
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
	
	private var _hiliteOpViews :Array;
	private var _editOps :Array;
	private var _editOpViews :Array;
	private var _editType :String;
	private var _firstMouseLoc :Point;	// Retain the "origin" of the edit, so we can draw lines from a starting point, etc.
	private var _lastMouseLoc :Point;
	
	private var _scan :Bitmap;
	
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
	public static function freqToY( useHeight:Number, freq:Number ) :Number {
		return useHeight * (1-(freq/Const.HIGHEST_FREQ_IN_LINEAR_VIEW));
	}
	
	public static function yToFreq( useHeight:Number, inY:Number ) :Number {
		return (1-(inY/useHeight)) * Const.HIGHEST_FREQ_IN_LINEAR_VIEW;
	}
	
	public function redrawAll() :void {
		for each( var opView:OperatorView in _opViews ) {
			redrawOpView( opView );
		}
	}
	
	public function redrawOpView( opView:OperatorView, leftFrame:int=-1, rightFrame:int=-1 ) {
		// Set defaults
		if( leftFrame==-1 ) leftFrame = 0;
		if( rightFrame==-1 ) rightFrame = Const.FRAMES - 1;

		opView.redraw( _fseq, leftFrame, rightFrame );
	}
	
	// As the audio plays, display a glowing vertical bar
	public function scanGlow( col:int ) :void {
		if( !_scan ) {
			_scan = new Bitmap( new BitmapData( Math.ceil(Const.GRAPH_SCALE_X), _rect.height, false, 0xffff00 ));
			_scan.alpha = 0.5;
			addChild( _scan );
		}
		
		_scan.x = Const.GRAPH_SCALE_X * col;
	}
	
	// Set with arrays of Booleans
	public function setEditableOps( isPitchOn:Boolean, voiced:Array, unvoiced:Array ) :void {
		for each( var opView:OperatorView in _opViews ) {
			switch( opView.type ) {
				case Const.VOICED:		opView.isEditable = voiced[opView.id]; break;
				case Const.UNVOICED:	opView.isEditable = unvoiced[opView.id]; break;
				case Const.PITCH:		opView.isEditable = isPitchOn; break;
			}
		}
	}
	
	public function yToFreq( inY:Number ) :Number {
		return (1 - (inY / _rect.height)) * 7000.0;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function mouseDownHandler( e:MouseEvent ) :void {
		// Dispatch the event FIRST so the editor clones the Fseq
		var activeTool:ToolButtonView = AppController.instance.activeTool;
		_editType = activeTool.editType;
		dispatchEvent( new CustomEvent( CustomEvent.EDIT_START, {type:_editType}) );

		_isMouseDown = true;
		
		_editOps = [];
		_editOpViews = [];
		var opView:OperatorView;
		// Some tools (freehand & line drawing) only affect 1 operator a time.
		var opCount:String = EditType.editOpCount(_editType);
		if( opCount == EditType.SINGLE_OP ) {
			for each( opView in _hiliteOpViews ) {
				_editOps.push( opView.operatorInSequence(_fseq) );
				_editOpViews.push( opView );
			}
		} else if( opCount == EditType.MULTI_OP ) {
			for each( opView in _opViews ) {
				if( opView.isEditable ) {
					_editOps.push( opView.operatorInSequence(_fseq) );
					_editOpViews.push( opView );
				}
			}
		}
		
		_firstMouseLoc = _lastMouseLoc = new Point( mouseX, mouseY );
		performEditStep();
	}
	
	private function mouseMoveHandler( e:MouseEvent ) :void {
		if( _isMouseDown ) {
			performEditStep();
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
		var frame:int = Num.clamp( mouseX / Const.GRAPH_SCALE_X, 0, Const.FRAMES-1 );

		var bestOp:OperatorView = null;
		var bestDistance:Number = 999999;
		for each( var opView:OperatorView in _opViews ) {
			if( !opView.isEditable ) continue;
			var thisDistance:Number = Math.abs(mouseY - opView.yAtFrame(_fseq, frame));
			if( thisDistance < bestDistance ) {
				bestDistance = thisDistance;
				bestOp = opView;
			}
		}
		
		return bestOp;
	}
	
	private function hiliteOps( liteOpViews:Array ) :void {
		var opView:OperatorView;
		for each( opView in _opViews ) {
			if( opView.isEditable ) {
				opView.hilite = false;
			}
		}

		if( liteOpViews ) {
			for each( opView in liteOpViews ) {
				opView.hilite = true;
			}
		}
		_hiliteOpViews = liteOpViews || [];
	}
	
	private function performEditStep() :void {
		var f:int, i:int, leftFreq:Number, rightFreq:Number;
		var op:Operator, opAtStart:Operator;
		var opView:OperatorView;
		
		var history:EditorHistory = AppController.instance.editorHistory;
		var firstMouseFrame:int = Num.clamp( _firstMouseLoc.x / Const.GRAPH_SCALE_X, 0, Const.FRAMES-1 );
		var lastMouseFrame:int = Num.clamp( _lastMouseLoc.x / Const.GRAPH_SCALE_X, 0, Const.FRAMES-1 );
		var mouseFrame:int = Num.clamp( mouseX / Const.GRAPH_SCALE_X, 0, Const.FRAMES-1 );
		var leftFrame:int = Math.min( lastMouseFrame, mouseFrame );
		var rightFrame:int = Math.max( lastMouseFrame, mouseFrame );
		
		switch( _editType ) {
			case EditType.EDIT_FREEHAND_DRAW:
				for each( op in _editOps ) {
					if( leftFrame == rightFrame ) {
						op.frame(leftFrame).freq = yToFreq( mouseY );
					} else {
						for( f=leftFrame; f<=rightFrame; f++ ) {
							leftFreq = yToFreq( (leftFrame==lastMouseFrame) ? _lastMouseLoc.y : mouseY );
							rightFreq = yToFreq( (rightFrame==lastMouseFrame) ? _lastMouseLoc.y : mouseY );
							op.frame(f).freq = Num.interpolate( leftFreq, rightFreq, Number(f-leftFrame)/(rightFrame-leftFrame) );
						}
					}
				}
				break;
				
			case EditType.EDIT_LINE_DRAW:
				// Let's be super-lazy. Clone the _editAtStart data, then just draw a line from the _firstMouseLoc to the new location.				
				for each( op in _editOps ) {
					if( op.isVoiced ) {
						opAtStart = history.editAtStart.voiced( op.index );
					} else if( op.isUnvoiced ) {
						opAtStart = history.editAtStart.unvoiced( op.index );
					} else if( op.isPitch ) {
						opAtStart = history.editAtStart.pitch();
					}
					
					// Clone the _editAtStart data.
					for( f=0; f<Const.FRAMES; f++ ) {
						op.frame(f).freq = opAtStart.frame(f).freq;
						//op.frame(f).amp = opAtStart.frame(f).amp;
					}
					
					// Now draw a line
					if( firstMouseFrame <= mouseFrame ) {
						leftFrame = firstMouseFrame;
						leftFreq = yToFreq( _firstMouseLoc.y );
						rightFrame = mouseFrame;
						rightFreq = yToFreq( mouseY );
					} else {
						rightFrame = firstMouseFrame;
						rightFreq = yToFreq( _firstMouseLoc.y );
						leftFrame = mouseFrame;
						leftFreq = yToFreq( mouseY );
					}
					
					for( f=leftFrame; f<=rightFrame; f++ ) {
						op.frame(f).freq = Num.interpolate( leftFreq, rightFreq, Number(f-leftFrame)/(rightFrame-leftFrame) );
					}
				}
				
				break;
				
			case EditType.EDIT_TRANSPOSE:
				var startFreq:Number = yToFreq( _firstMouseLoc.y );
				var newFreq:Number = yToFreq( mouseY );
				var diff:Number = (newFreq - startFreq) / 2;	// Slower motion :P
				
				for each( op in _editOps ) {
					if( op.isVoiced ) {
						opAtStart = history.editAtStart.voiced( op.index );
					} else if( op.isUnvoiced ) {
						opAtStart = history.editAtStart.unvoiced( op.index );
					} else if( op.isPitch ) {
						opAtStart = history.editAtStart.pitch();
					}
					
					for( f=0; f<Const.FRAMES; f++ ) {
						op.frame(f).freq = Num.clamp( opAtStart.frame(f).freq + diff, 20.0, 12000.0 );
					}
				}

				break;
		}
		
		_lastMouseLoc = new Point( mouseX, mouseY );
		
		// Redraw the changed areas
		for each( opView in _editOpViews ) {
			//redrawOpView( opView, leftFrame, rightFrame );
			
			// Always redraw the whole thing :P
			redrawOpView( opView );
		}
	}
	
	// Tweener callback
	private function removeDisp( disp:DisplayObject ) :void {
		if( disp.parent ) disp.parent.removeChild( disp );
	}
}

}

