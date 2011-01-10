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
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.net.*;

public class BaseLoader extends EventDispatcher
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function BaseLoader() {
		super();
	}
	
	public function initWithURL( urlStr:String ) :void {
		_urlLoader = new URLLoader();
		with( _urlLoader ) {
			dataFormat = URLLoaderDataFormat.BINARY;
			addEventListener( IOErrorEvent.IO_ERROR, loaderIOError, false, 0, true );
			addEventListener( SecurityErrorEvent.SECURITY_ERROR, loaderSecurityError, false, 0, true );
			addEventListener( Event.COMPLETE, loaderComplete, false, 0, true );
		}
		
		var req:URLRequest = new URLRequest( urlStr );
		_urlLoader.load( req );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	protected var _urlLoader :URLLoader;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	protected function loaderIOError( e:IOErrorEvent ) :void {
		trace("** BaseLoader: IO Error...", e );
		dispatchEvent( new CustomEvent( CustomEvent.LOAD_FAILED, {error:e} ));
	}
	
	protected function loaderSecurityError( e:SecurityErrorEvent ) :void {
		trace("** BaseLoader: Security error...", e );
		dispatchEvent( new CustomEvent( CustomEvent.LOAD_FAILED, {error:e} ));
	}
	
	protected function loaderComplete( e:Event ) :void {
		trace("BaseLoader: load complete!");
		handleLoaderComplete();
		dispatchEvent( new CustomEvent( CustomEvent.LOAD_COMPLETE ));
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	protected function handleLoaderComplete() :void {
		// Extend me!
	}
	
}

}

