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
	private var _channels :int = 0;
	private var _bitDepth :int = 0;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	// Return true if parse succeeds, false otherwise
	public override function parse( ba:ByteArray ) :Boolean {
		_ba = ba;
		
		var sr:Number = 0;
		
		_ba.endian = Endian.BIG_ENDIAN;
		_ba.position = 0;
		
		for( var chunk:int=0; chunk<100; chunk++ ) {	// Sanity check: avoid infinite while() loop
			if( _ba.bytesAvailable == 0 ) break;
			
			var chunkId:String = _ba.readUTFBytes(4);	// 4 byte string
			var chunkSize:uint = _ba.readUnsignedInt();	// 32-bit
			switch( chunkId ) {
				case "FORM":
					var aiffCode:String = _ba.readUTFBytes(4);
					if( aiffCode != "AIFF" && aiffCode != "AIFC" ) {
						// Then it's the file size
						_ba.position -= 4;
						var fileSize:uint = _ba.readUnsignedInt();
						aiffCode = _ba.readUTFBytes(4);
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
					
					_channels = _ba.readUnsignedShort();
					_frameCount = _ba.readUnsignedInt();
					_bitDepth = _ba.readUnsignedShort();	// aka "sample size"
					
					// We're not going to use sample rate, so it doesn't matter if we convert the 80-bit float to AS3 Number
					sr = 44100;
					var srBytes:ByteArray = new ByteArray();
					_ba.readBytes( srBytes, 0, 10 );
					
					break;
					
					
				case "SSND":
					// This is the sound data
					if( !_channels || !_bitDepth || !_frameCount ) {
						_error = "Sound data appeared before COMM chunk. Can't parse this file.";
						return false;
					}
					
					// Block-aligned data: Some AIFF sound data will be left- (and maybe right-) padded with sound data
					// that should not be read.
					var offset:uint = _ba.readUnsignedInt();	// 32-bit
					var blockSize:uint = _ba.readUnsignedInt();	// 32-bit
					_sampleDataStart = _ba.position + offset;
					trace("Sample data starts at:", _sampleDataStart);
					_ba.position += chunkSize;	// Skip to the next chunk
					
					break;
					
					
				// Things we're not going to parse:
				case "FVER":	// format version
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
					_ba.position += chunkSize;	
					break;
					
					
				default:
					//_error = "Can't parse whatever this chunk is: " + chunkId + " at position " + _ba.position.toString();
					trace("** I don't know what this chunk is, attempting to skip:", chunkId, _ba.position.toString());
					_ba.position += chunkSize;
					return false;
			}
		}
		
		if( _channels && _bitDepth ) {
			_isParsed = true;	// Victory!
			trace(">> AIFFParser is parsed:", _channels, _bitDepth);
			return true;
		}
		
		// Failed.
		_error = ["Incomplete parse, missing info: Channels:",_channels,"Sample rate:",sr,"Bit depth:",_bitDepth].join(",");
		trace("** Incomplete parse, missing info:", _channels, sr, _bitDepth);
		return false;
	}
	
	public override function getMonoSamples( atFrame:int, count:int ) :Vector.<Number> {
		var out:Vector.<Number> = new Vector.<Number>( count, true );

		// Move to where the sample data is stored
		_ba.position = _sampleDataStart + (atFrame * _channels * (_bitDepth/8));
		
		for( var i:int=0; i<count; i++ ) {
			var samp_f:Number = 0;
			var maxIncomingSample :Number = Number( 0x7fffffff >> (32-_bitDepth) );
			for( var c:int=0; c<_channels; c++ ) {
				var samp_i:int;
				switch( _bitDepth ) {
					case 8:		samp_i = _ba.readByte(); break;
					case 16:	samp_i = _ba.readShort(); break;
					case 24:	
						samp_i = (_ba.readByte() << 16);
						samp_i |= _ba.readShort();
						break;
					case 32:
						samp_i = _ba.readInt();
						break;
					default:
						trace("** I have some terrible bit depth that I can't read:", _bitDepth);
						return null;
				}
				
				// Scale the samp_i down, betweer 0f..1f
				samp_f += Number(samp_i) / maxIncomingSample;
			}
			
			// Normalize the sound based on channel count
			out[i] = samp_f / _channels;
		}
		
		return out;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

