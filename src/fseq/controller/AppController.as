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
import fl.controls.*;
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
		
		_presets = new ComboBox();
		for each( var str:String in Presets.fs1rSequences() ) {
			_presets.addItem( {label:str, data:str} );
		}
		_presets.x = 530;
		_presets.y = 20;
		_presets.width += 100;
		_presets.rowCount = 30;
		_presets.addEventListener( Event.CHANGE, presetChangeHandler, false, 0, true );
		addChild( _presets );
		presetChangeHandler();	// immediately load a sequence
		
		_speed = new Slider();
		_speed.minimum = 0;
		_speed.maximum = 4;
		_speed.value = 2;
		_speed.snapInterval = 0.05;
		_speed.liveDragging = true;
		_speed.setSize( 200, 40 );
		_speed.addEventListener( Event.CHANGE, speedChangeHandler, false, 0, true );
		_speed.x = 530;
		_speed.y = 60;
		addChild( _speed );
		
		_sweep = new Shape();
		with( _sweep.graphics ) {
			beginFill( 0xffff00, 0.8 );
			drawRect( 0, 0, 2, 512 );
			endFill();
		}
		addChild( _sweep );
		addEventListener( Event.ENTER_FRAME, enterFrameHandler, false, 0, true );
	}
		
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _seq :FormantSequence;
	private var _player :AudioPlayer;
	private var _loader :SyxLoader;
	private var _seqView :SequenceView;
	private var _sweep :Shape;

	// Form controls
	private var _presets :ComboBox;
	private var _speed :Slider;

	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function sequenceClickHandler( e:MouseEvent ) :void {
		if( !_player ) {
			_player = new AudioPlayer();
			speedChangeHandler();
			_player.play( _seq );
		} else {
			_player.stop();
			_player = null;
		}
	}
	
	private function speedChangeHandler( e:Event=null ) :void {
		if( _player ) {
			_player.speedAdjust = Math.pow( 2.0, _speed.value - 2 );
		}
	}
	
	private function presetChangeHandler( e:Event=null ) :void {
		if( _seqView && _seqView.parent ) _seqView.parent.removeChild( _seqView );
		if( _player ) {
			_player.stop();
			_player = null;
		}
		
		// Flash components are evil. Index is -1 when launched
		var idx:int = Math.max( 0, _presets.selectedIndex );
		var path:String = Presets.pathToFS1RSequenceId( idx );
		
		_loader = new SyxLoader();
		_loader.addEventListener( CustomEvent.LOAD_COMPLETE, loadComplete, false, 0, true );
		_loader.addEventListener( CustomEvent.LOAD_FAILED, loadFailed, false, 0, true );
		_loader.initWithURL( path );
	}
	
	private function loadFailed( e:CustomEvent ) :void {
		trace("** Load failed, bawwwwwwwww", e.data['error']);
	}
	
	private function loadComplete( e:CustomEvent ) :void {
		_seq = _loader.formantSequence;
		_seqView = new SequenceView( Const.FREQ, _seq );
		_seqView.addEventListener( MouseEvent.CLICK, sequenceClickHandler, false, 0, true );
		addChildAt( _seqView, 0 );
	}
	
	private function enterFrameHandler( e:Event ) :void {
		if( !_player ) {
			_sweep.visible = false;
		} else {
			_sweep.visible = true;
			_sweep.x = _player.frame;
		}
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}
