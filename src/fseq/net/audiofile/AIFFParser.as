package fseq.net.audiofile {

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
import flash.utils.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.view.*;

public class AIFFParser extends BaseParser
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function AIFFParser() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _sampleDataStart :uint;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	// Return true if parse succeeds, false otherwise
	public override function parse( ba:ByteArray ) :Boolean {
		var channels:int = 0;
		var sr:Number = 0;
		var bitDepth:int = 0;
		var frameCount:uint = 0;
		
		ba.endian = Endian.BIG_ENDIAN;
		ba.position = 0;
		
		for( var chunk:int=0; chunk<100; chunk++ ) {	// Sanity check: avoid infinite while() loop
			if( ba.bytesAvailable == 0 ) break;
			
			var chunkId:String = ba.readUTFBytes(4);	// 4 byte string
			var chunkSize:uint = ba.readUnsignedInt();	// 32-bit
			switch( chunkId ) {
				case "FORM":
					var aiffCode:String = ba.readUTFBytes(4);
					if( aiffCode != "AIFF" && aiffCode != "AIFC" ) {
						// Then it's the file size
						ba.position -= 4;
						var fileSize:uint = ba.readUnsignedInt();
						aiffCode = ba.readUTFBytes(4);
						if( aiffCode != "AIFF" && aiffCode != "AIFC" ) {
							// Still not an AIFF? Then error out
							_error = "FORM does not precede AIFF: "+aiffCode;
							return false;
						}
					}
					break;
				
				case "COMM":
					if( chunkSize != 18 ) {
						_error = "COMM chunk is not size 18: " + chunkSize.toString();
						return false;
					}
					
					channels = ba.readUnsignedShort();
					frameCount = ba.readUnsignedInt();
					var sampSize:uint = ba.readUnsignedShort();
					bitDepth = sampSize / channels;
					
					// We're not going to use sample rate, so it doesn't matter if we convert the 80-bit float to AS3 Number
					sr = 44100;
					var srBytes:ByteArray = new ByteArray();
					ba.readBytes( srBytes, 0, 10 );
					
					break;
					
					
				case "SSND":
					// This is the sound data
					if( !channels || !bitDepth || !frameCount ) {
						_error = "Sound data appeared before COMM chunk. Can't parse this file.";
						return false;
					}
					
					// Block-aligned data: Some AIFF sound data will be left- (and maybe right-) padded with sound data
					// that should not be read.
					var offset:uint = ba.readUnsignedInt();	// 32-bit
					var blockSize:uint = ba.readUnsignedInt();	// 32-bit
					_sampleDataStart = ba.position + offset;
					trace("Sample data starts at:", _sampleDataStart);
					ba.position += chunkSize;	// Skip to the next chunk
					
					break;
					
					
				// Things we're not going to parse:
				case "MARK":	// markers
				case "INST":	// instrument data
				case "MIDI":	// midi data
				case "AESD":	// recording-related
				case "APPL":	// application-specific data
				case "COMT":	// comments
				case "NAME":	// name
				case "AUTH":	// author
				case "(c) ":	// copyright
				case "ANNO":	// annotation
					// skip over these chunks
					ba.position += chunkSize;	
					break;
					
					
				default:
					_error = "Can't parse whatever this chunk is: " + chunkId + " at position " + ba.position.toString();
					trace("** Did we get any other data?", channels, sr, bitDepth);
					return false;
			}
		}
		
		if( channels && bitDepth ) {
			_isParsed = true;	// Victory!
			return true;
		}
		
		// Failed.
		_error = ["Incomplete parse, missing info: Channels:",channels,"Sample rate:",sr,"Bit depth:",bitDepth].join(",");
		trace("** Incomplete parse, missing info:", channels, sr, bitDepth);
		return false;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

