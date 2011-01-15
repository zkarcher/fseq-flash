package fseq.model {

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

public class EditorHistory extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function EditorHistory() {
		_history = new Vector.<FormantSequence>();
		
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _history :Vector.<FormantSequence>;
	private var _activeIndex :int = -1;
	private var _edit :FormantSequence = null;	// <-- being edited in realtime
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get activeSequence() :FormantSequence {
		if( _edit ) return _edit;
		if( _history.length > 0 && _activeIndex >= 0 ) return _history[_activeIndex];
		return null;
	}
	
	public function get editSource() :FormantSequence {
		return _history[_activeIndex];
	}
	
	public function get edit() :FormantSequence { return _edit; }
	public function set edit( fs:FormantSequence ) :void { _edit = fs; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function pushSequence( fseq:FormantSequence ) :void {
		popLaterEdits();
		_history.push( fseq );
		_activeIndex = _history.length - 1;
	}
	
	public function editStart() :void {
		popLaterEdits();
		_edit = _history[_activeIndex].clone();
	}
	
	public function editStop() :void {
		_history.push( _edit );
		_activeIndex = _history.length-1;
		_edit = null;
	}
	
	public function undo() :void {
		_activeIndex = Math.max( 0, _activeIndex-1 );
	}
	public function redo() :void {
		_activeIndex = Math.min( _activeIndex+1, _history.length-1 );
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function popLaterEdits() :void {
		// Remove any history that is above the _activeIndex level
		if( _history.length > _activeIndex+1 ) {
			_history.splice( _activeIndex+1, 999999 );
		}
	}
	
}

}

