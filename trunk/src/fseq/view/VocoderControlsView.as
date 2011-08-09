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

public class VocoderControlsView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function VocoderControlsView( inId:int, inRect:Rectangle ) {
		// Preserve the frequencies from one import to the next
		if( !_freqs ) _freqs = new <Number>[55,110,220,440, 880,1760,2640,3520];
		if( !_sines ) {
			_sines = new Vector.<Point>( 8, true );
			for( var i:int=0; i<8; i++ ) {
				_sines[i] = new Point(60,0);
			}
		}
		
		_id = inId;
		_rect = inRect;
		
		// Apply the happy voiced operator colors
		var color:uint = Const.color( Const.VOICED, _id );
		ColorUtil.screen( this, color );
		
		_freqHandle = new Handle_mc();
		_freqHandle.y = GraphView.freqToY( _rect.height, _freqs[_id] );
		
		for each( var handle:Sprite in [_freqHandle] ) {
			addChild( handle );			
			handle.buttonMode = handle.useHandCursor = true;
			handle.tabEnabled = false;
			
			handle.addEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true );
		}
		
		addEventListener( Event.ENTER_FRAME, initEnterFrame );
	}
	
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;	// wait for the stage
		
		stage.addEventListener( MouseEvent.MOUSE_MOVE, stageMouseMove, false, 0, true );
		stage.addEventListener( MouseEvent.MOUSE_UP, stageMouseUp, false, 0, true );
	}
	
	public function destroy() :void {
		if( stage ) {
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stageMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, stageMouseUp );
		}
		if( parent ) parent.removeChild( this );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private static var _freqs :Vector.<Number>;
	private static var _sines :Vector.<Point>;
	
	private var _id :int;
	private var _rect :Rectangle;
	
	private var _freqHandle :Handle_mc;
	private var _sineHandle :Handle_mc;
	
	private var _mouseDownObject :Sprite = null;
	private var _mouseOffset :Point;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get id() :int { return _id; }
	public function get freqY() :Number { return _freqHandle.y };
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function handleMouseDown( e:MouseEvent ) :void {
		_mouseDownObject = Sprite(e.currentTarget);
		if( _mouseDownObject == _freqHandle ) {
			_mouseDownObject.startDrag( false, new Rectangle( 0, _rect.y, 0, _rect.height ) );	// Confine to left edge
		}
	}
	
	private function stageMouseMove( e:MouseEvent ) :void {
		if( !_mouseDownObject ) return;
		
		// Dispatch something
		if( _mouseDownObject == _freqHandle ) {
			_freqs[_id] = GraphView.yToFreq( _rect.height, _freqHandle.y );	// store the freq for later
		}
		dispatchEvent( new CustomEvent( CustomEvent.VOCODER_CONTROLS_UPDATE ));
	}
	
	private function stageMouseUp( e:MouseEvent ) :void {
		if( !_mouseDownObject ) return;
		
		_mouseDownObject.stopDrag();
		_mouseDownObject = null;
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

