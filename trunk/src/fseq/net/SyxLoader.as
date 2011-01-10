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
import fseq.model.*;
import fseq.net.*;

public class SyxLoader extends BaseLoader
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function SyxLoader() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get formantSequence() :FormantSequence { return _seq; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	private var _seq :FormantSequence;
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	protected override function handleLoaderComplete() :void {
		var ba:ByteArray = ByteArray(_urlLoader.data);
		ba.position = 0;
		
		// This file format is specified in the FS1RE2.PDF file available on the intertubes
		// See page 37 for the header.
		// See page 40 for the Fseq parameters.
		// Also, examining .syx files with hex editors helped a lot.
		
		assertEquals( ba.readUnsignedByte(), 0xf0, "Exclusive Status" );
		assertEquals( ba.readUnsignedByte(), 0x43, "Yamaha ID" );

		var deviceNumber:uint = ba.readUnsignedByte();
		trace("Device number:", deviceNumber);

		assertEquals( ba.readUnsignedByte(), 0x5e, "Model ID" );

		var expectedByteCount:uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();

		var address:uint = (((ba.readUnsignedByte() << 7) | ba.readUnsignedByte()) << 7) | ba.readUnsignedByte();	// 21-bit number
		
		// The next 8 bytes are the name, in ASCII format
		var title:String = ba.readUTFBytes( 8 );
		trace("title is", title);
		
		// The next 8 bytes are "reserved", so they're unimportant to us
		ba.position += 8;
		
		var loopStart :uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// 00-7F each
		var loopEnd :uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// 00-7F each
		var loopMode :uint = ba.readUnsignedByte();	// 0:one way, 1:round
		var speedAdjust :uint = ba.readUnsignedByte();	// 00-7F
		var velSensitivity :uint = ba.readUnsignedByte();	// 00-07
		var pitchMode :uint = ba.readUnsignedByte();	// 0:pitch, 1:non-pitch
		var noteAssign :uint = ba.readUnsignedByte();	// 00-7F
		var pitchTuning :uint = ba.readUnsignedByte();	// 00-7F, corresponds to -63..63
		var seqDelay :uint = ba.readUnsignedByte();	// "00-63" (is this actually 00-3F?)
		var dataFormat :uint = ba.readUnsignedByte();	// 00-03, corresponds to 128,256,384,512 frames
		
		// The next two bynes are reserved, skip them
		ba.position += 2;
		
		var validDataEndStep :uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// 00-7F each
		
		// Now it's time to read the frames.
		var totalFrames:int = (dataFormat+1) * 128;
		
		// We'll store the frame values in these Vectors:
		var pitch:Vector.<uint> = new Vector.<uint>( totalFrames, true );
		var voicedFreq:Array = [];
		var voicedLevel:Array = [];
		var unvoicedFreq:Array = [];
		var unvoicedLevel:Array = [];
		// Create a vector for each voiced/unvoiced operator
		for( var v:int=0; v<8; v++ ) {
			voicedFreq.push( new Vector.<uint>( totalFrames, true ));
			voicedLevel.push( new Vector.<uint>( totalFrames, true ));
			unvoicedFreq.push( new Vector.<uint>( totalFrames, true ));
			unvoicedLevel.push( new Vector.<uint>( totalFrames, true ));
		}
		
		for( var f:int=0; f<totalFrames; f++ ) {
			// Read the pitch
			pitch[f] = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// both 00-7f? Really?
			
			// voiced freqs: high bytes first
			var i:int = 0;
			for( i=0; i<8; i++ ) { 
				voicedFreq[i][f] = ba.readUnsignedByte() << 7;	// 00-7F
			}
			// voiced freqs: low bytes
			for( i=0; i<8; i++ ) {
				voicedFreq[i][f] |= ba.readUnsignedByte();	// 00-7F
			}
			// voiced level
			for( i=0; i<8; i++ ) {
				voicedLevel[i][f] = ba.readUnsignedByte();	// 00-7F
			}
			// unvoiced freqs: high bytes first
			for( i=0; i<8; i++ ) { 
				unvoicedFreq[i][f] = ba.readUnsignedByte() << 7;	// 00-7F
			}
			// unvoiced freqs: low bytes
			for( i=0; i<8; i++ ) {
				unvoicedFreq[i][f] |= ba.readUnsignedByte();	// 00-7F
			}
			// unvoiced level
			for( i=0; i<8; i++ ) {
				unvoicedLevel[i][f] = ba.readUnsignedByte();	// 00-7F
			}
		}
		
		var expectedChecksum :uint = ba.readUnsignedByte();
		//var checksum :uint = byteCount + address + OTHER STUFF;
		
		assertEquals( ba.readUnsignedByte(), 0xF7, "End of exclusive data" );
		
		var bytesRead:uint = ba.position;
		assertEquals( bytesRead, expectedByteCount, "Bytes read vs expected byte count" );
		// TODO: Why don't these match?...
		
		// Now let's evaluate that checksum
		ba.position = 4;
		var check:uint = 0x0;
		// Don't read the "end of exclusive data" byte
		for( var b:int=4; b<bytesRead-1; b++ ) {
			check += ba.readUnsignedByte();
		}
		assertEquals( check & 0x7f, 0x0, "Low 7 bytes of checksum should be zero" );
		
		// Make a formant sequence with this stuff
		_seq = new FormantSequence();
		_seq.initWithBytes( pitch, voicedFreq, voicedLevel, unvoicedFreq, unvoicedLevel );
	}
	
	private function assertEquals( a:uint, b:uint, description:String=null ) :uint {
		if( a != b ) {
			trace("** SyxLoader: failed assertion:", description, a, b);
		}
		return a;
	}
	
}

}

