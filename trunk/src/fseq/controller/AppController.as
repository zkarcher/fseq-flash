package fseq.controller {

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
import fseq.audio.*;
import fseq.events.*;
import fseq.model.*;
import fseq.net.*;
import fseq.view.*;

public class AppController extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	private static var _instance:AppController;
	
	public static function get instance():AppController
	{
		return initialize();
	}
	
	public static function initialize():AppController
	{
		if (_instance == null){
			_instance = new AppController();
		}
		return _instance;
	}
	
	public function AppController() {
		super();
		if( _instance != null ) throw new Error("Error:AppController already initialised.");
		if( _instance == null ) _instance = this;
		
		/*
		_seq = new FormantSequence();
		
		// Testing: Play some random crap
		for( var f:int=0; f<512; f++ ) {
			_seq.pitch().frame(f).semitone = 12;	// 110hz
			for( var o:int=0; o<8; o++ ) {
				_seq.voiced(o).frame(f).amp = Rand.float();
				_seq.voiced(o).frame(f).semitone = Rand.int( 12*7 );
				_seq.unvoiced(o).frame(f).amp = Rand.float();
				_seq.unvoiced(o).frame(f).semitone = Rand.int( 12*7 );
			}
		}
		*/
		
		_loader = new SyxLoader();
		_loader.addEventListener( CustomEvent.LOAD_COMPLETE, loadComplete, false, 0, true );
		_loader.addEventListener( CustomEvent.LOAD_FAILED, loadFailed, false, 0, true );
		_loader.initWithURL("p01 - ShoobyDo.syx");
		//_loader.initWithURL("freqtest.syx");
		
		addEventListener( Event.ENTER_FRAME, initEnterFrame );
	}
	
	// Set up mouse listeners and whatever else we need the stage for
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ENTER_FRAME, initEnterFrame );

		stage.addEventListener( MouseEvent.CLICK, clickHandler );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _seq :FormantSequence;
	private var _player :AudioPlayer;
	private var _loader :SyxLoader;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function clickHandler( e:MouseEvent ) :void {
		if( !_player ) {
			_player = new AudioPlayer();
			_player.play( _seq );
		} else {
			_player.stop();
			_player = null;
		}
	}
	
	private function loadFailed( e:CustomEvent ) :void {
		trace("** Load failed, bawwwwwwwww", e.data['error']);
	}
	
	private function loadComplete( e:CustomEvent ) :void {
		_seq = _loader.formantSequence;
		addChild( new SequenceView( Const.FREQ, _seq ));
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

