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
import flash.ui.*;
import flash.utils.*;
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
	
	// Embedding the SVN entries file, so we can display the SVN revision number on the screen.
	[Embed(source = "../../../.svn/entries", mimeType="application/octet-stream")]
	private static var svnEntries:Class;
	
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

		_editorView = new EditorView();
		_editorView.y = 90;
		//_editorView.addEventListener( MouseEvent.CLICK, sequenceClickHandler );
		_editorView.history.addEventListener( CustomEvent.ACTIVE_FSEQ_CHANGED, activeFseqChanged );
		addChildAt( _editorView, 0 );
		
		var str:String;
		
		_presets = new ComboBox();
		_presets.addItem( {label:"Custom Presets:",data:""});
		for each( str in Presets.zachArcherSequences() ) {
			_presets.addItem( {label:"       "+str, data:"fseqs/zacharcher/"+str} );
		}
		_presets.addItem( {label:" ",data:""});
		_presets.addItem( {label:"Yamaha FS1R Presets:",data:""});
		for each( str in Presets.fs1rSequences() ) {
			_presets.addItem( {label:"       "+str, data:"fseqs/fs1r/"+str} );
		}
		
		_presets.x = 530;
		_presets.y = 20;
		_presets.width += 100;
		_presets.rowCount = 30;
		_presets.addEventListener( Event.CHANGE, presetChangeHandler, false, 0, true );
		addChild( _presets );
		
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
		
		_speedLabel = new CustomTextView( "SPEED", {color:0xffffff, size:13} );
		_speedLabel.x = _speed.x + _speed.width + 10;
		_speedLabel.y = _speed.y - 4;
		addChild( _speedLabel );
		
		addEventListener( Event.ENTER_FRAME, enterFrameHandler, false, 0, true );
		
		//
		// Buttons
		//
		var btnLabels:Array = ["undo","loadSYX","saveSYX","loadAIFF"];
		var btnFuncs:Array = [undoClick,loadSyxClick,saveSyxClick,loadAudioClick];
		var count:int = 0;
		for each( var label:String in btnLabels ) {
			var btn:BasicButton = new BasicButton( label );
			btn.addEventListener( MouseEvent.CLICK, btnFuncs[count] );
			addChild( btn );
			btn.x = (btn.width + 10) * count;
			count++;
		}
		
		addEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		// Adapted from: http://pixelpracht.wordpress.com/2010/06/02/resource-handling-in-flash-part-one/
		var bytes:ByteArray = new svnEntries;
		var text:String = bytes.toString();
		var lines:Array = text.split( /[\n\r]+/g );
		// SVN revision number is always the 3rd line, for now
		var revision:String = lines[2];
		
		var html:String = "Press [SPACE BAR] to play.\n\n";
		html += "revision #" + revision + " • ";
		html += "<a href=\"http://blog.zacharcher.com/\">blog.zacharcher.com</a>";
		
		var caption:Caption_mc = new Caption_mc();
		caption.tf.htmlText = html;
		caption.x = Const.FRAMES * Const.GRAPH_SCALE_X;
		caption.y = 700;
		addChild( caption );
	}
	
	private function testStuff() :void {
		var loader:AudioFileLoader = new AudioFileLoader();
		
	}
	
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
		stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );

		//presetChangeHandler();	// immediately load a sequence
		_syxLoader = new SyxLoader();
		_syxLoader.addEventListener( CustomEvent.FSEQ_COMPLETE, fseqComplete, false, 0, true );
		_syxLoader.addEventListener( CustomEvent.LOAD_FAILED, loadSyxFailed, false, 0, true );
		_syxLoader.initWithURL( "fseqs/zacharcher/oneTwoThree.syx" );
	}
		
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _player :AudioPlayer;
	private var _syxLoader :SyxLoader;
	private var _audioLoader :AudioFileLoader;
	//private var _seqView :SequenceView;

	private var _editorView :EditorView;

	// Form controls
	private var _presets :ComboBox;
	private var _speed :Slider;
	private var _speedLabel :CustomTextView;
	
	// Audio import
	private var _import :AudioImportView;
	
	// buttons
	private var _undo :BasicButton;
	private var _load :BasicButton;
	private var _save :BasicButton;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get editorView() :EditorView { return _editorView; }
	public function get editorHistory() :EditorHistory { return _editorView.history; }
	public function get activeTool() :ToolButtonView { return _editorView.activeTool; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function enterFrameHandler( e:Event ) :void {
		if( !_player ) {
			//_sweep.visible = false;
		} else {
			//_sweep.visible = true;
			//_sweep.x = _player.frame;
		}
	}
	
	// Editor tells audio _player to update its fseq when a change is made:
	private function activeFseqChanged( e:CustomEvent ) :void {
		if( _player ) {
			_player.formantSequence = _editorView.activeSequence;
		}
	}
	
	private function keyDownHandler( e:KeyboardEvent ) :void {
		/*
		switch( e.charCode ) {
			case Keyboard.SHIFT:
				trace("sHIFT DOWN");
				_isShiftDown = true;
				break;
		}
		*/
	}
	
	private function keyUpHandler( e:KeyboardEvent ) :void {
		switch( e.charCode ) {
			/*
			case Keyboard.SHIFT:
				trace("SHIFT UP");
				_isShiftDown = false;
				break;
			*/
			
			// Space taggles the audio
			case ' '.charCodeAt(0):
				if( !_player ) {
					// If we're in the middle of an import, then don't play anything
					if( _import && !_import.fseqIsReady ) {
						return;
					}
					
					_player = new AudioPlayer();
					speedChangeHandler();
					_player.addEventListener( CustomEvent.PLAYING_FRAME, playingFrame );
					var activeSeq:FormantSequence = _import ? _import.fseq : _editorView.activeSequence;
					_player.play( activeSeq );
				} else {
					stopAudio();
				}
				break;
		}
	}
	
	private function speedChangeHandler( e:Event=null ) :void {
		if( _player ) {
			_player.speedAdjust = Math.pow( 2.0, _speed.value - 2 );
		}
	}
	
	private function undoClick( e:MouseEvent ) :void {
		_editorView.undo();
	}
	
	private function playingFrame( e:CustomEvent ) :void {
		if( _import ) {
			_import.scanGlow( e.data['frame'] );
		} else {
			_editorView.scanGlow( e.data['frame'] );
		}
	}
	
	private function stopTheSound( e:CustomEvent ) :void {
		stopAudio();
	}
	
	//
	// FSEQ PRESETS
	//
	private function presetChangeHandler( e:Event=null ) :void {
		//if( _seqView && _seqView.parent ) _seqView.parent.removeChild( _seqView );
		/*
		if( _player ) {
			_player.stop();
			_player = null;
		}
		*/
		
		// Don't let the dropdown keep the focus
		if( stage ) stage.focus = null;
		
		// Flash components are evil. Index is -1 when launched
		if( _presets.selectedIndex < 0 ) return;
		
		var path:String = String( _presets.value );
		if( path.length==0 ) return;	// Some items are just labels, they have no values
		
		_syxLoader = new SyxLoader();
		_syxLoader.addEventListener( CustomEvent.FSEQ_COMPLETE, fseqComplete, false, 0, true );
		_syxLoader.addEventListener( CustomEvent.LOAD_FAILED, loadSyxFailed, false, 0, true );
		_syxLoader.initWithURL( path );
	}
	
	//
	// .SYX FILES
	//
	private function loadSyxClick( e:MouseEvent ):void {
		stopAudio();
		
		_syxLoader = new SyxLoader();
		_syxLoader.addEventListener( CustomEvent.FSEQ_COMPLETE, fseqComplete, false, 0, true );
		_syxLoader.addEventListener( CustomEvent.LOAD_FAILED, loadSyxFailed, false, 0, true );
		_syxLoader.loadFile();
	}
	
	private function loadSyxFailed( e:CustomEvent ) :void {
		trace("** Load .syx failed, bawwwwwwwww", e.data['error']);
	}
	
	private function saveSyxClick( e:MouseEvent ) :void {
		stopAudio();
		var saver:SyxSaver = new SyxSaver( _editorView.activeSequence, 512 );
	}
	
	//
	// AUDIO FILES: LOAD
	//
	private function loadAudioClick( e:MouseEvent ) :void {
		stopAudio();
		
		_audioLoader = new AudioFileLoader();
		_audioLoader.addEventListener( CustomEvent.LOAD_FAILED, audioLoadFailed, false, 0, true );
		_audioLoader.addEventListener( CustomEvent.LOAD_COMPLETE, audioLoadComplete, false, 0, true );
		_audioLoader.loadFile();
	}
	private function audioLoadFailed( e:CustomEvent ) :void {
		trace("** Audio load failed:", e.data['error']);
	}
	private function audioLoadComplete( e:CustomEvent ) :void {
		_import = new AudioImportView( _audioLoader.parser );
		_import.addEventListener( CustomEvent.FSEQ_COMPLETE, importFseqComplete, false, 0, true );
		_import.addEventListener( CustomEvent.STOP_THE_SOUND, stopTheSound, false, 0, true );
		_import.addEventListener( CustomEvent.CANCEL, importCancel, false, 0, true );
		addChild( _import );
	}
	private function importFseqComplete( e:CustomEvent ) :void {
		_editorView.pushSequence( _import.fseq );
		_import.teardown();
		_import = null;
	}
	private function importCancel( e:CustomEvent ) :void {
		stopAudio();
		_import.teardown();
		_import = null;
	}
	
	private function fseqComplete( e:CustomEvent ) :void {
		var seq:FormantSequence = _syxLoader.formantSequence;
		_editorView.pushSequence( seq );
		
		if( _player ) {
			_player.play( _editorView.activeSequence );
		}
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function stopAudio() :void {
		if( !_player ) return;
		
		_player.stop();
		_player.removeEventListener( CustomEvent.PLAYING_FRAME, playingFrame );
		_player = null;
		_editorView.scanGlow( -100 );	// hide the scanner
	}
}

}

