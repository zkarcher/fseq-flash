package fseq.net {

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
import flash.net.*;
import flash.utils.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.net.*;
import fseq.net.audiofile.*;

public class AudioFileLoader extends BaseLoader
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function AudioFileLoader() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _file :FileReference;
	private var _parser :BaseParser;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get parser() :BaseParser { return _parser; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function loadFile() :void {
		_file = new FileReference();
		_file.addEventListener( Event.SELECT, fileSelected, false, 0, true );
		_file.addEventListener( Event.COMPLETE, fileReferenceLoaded, false, 0, true );
		var filter:FileFilter = new FileFilter(".AIFF files","*.aif;*.aiff");
		_file.browse( [filter] );
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function fileSelected( e:Event ) :void {
		_file.load();
	}
	
	private function fileReferenceLoaded( e:Event ) :void {
		parseAudio( _file.data );
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	/*
	protected override function handleLoaderComplete() :void {
		readByteArray( _urlLoader.data );
	}
	*/
	
	private function parseAudio( ba:ByteArray ) :void {
		// AIF?
		_parser = new AIFFParser();
		_parser.parse( ba );
		
		if( !_parser.isParsed ) {
			dispatchEvent( new CustomEvent( CustomEvent.LOAD_FAILED, {error:_parser.error} ));
		} else {
			dispatchEvent( new CustomEvent( CustomEvent.LOAD_COMPLETE ));
		}
	}
	
}

}

