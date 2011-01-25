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
import fseq.view.*;

public class SyxSaver extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function SyxSaver( fseq:FormantSequence, frameCount:int ) {
		var i:int;
		var op:int;
		
		// Build a ByteArray of the data we're going to save. This is basically the inverse of SyxLoader.handleLoaderComplete ;)
		var ba:ByteArray = new ByteArray();
		
		var ar:Array = [0xf0,0x43,0x00,0x5e,0x10];
		// I'm not sure what this byte signifies exactly:
		switch( frameCount ) {
			case 128: 	ar.push(0x19); break;
			default:	ar.push(0x64); break;
		}
		ar = ar.concat( [0x60,0x0,0x0] );
		for( i=0; i<ar.length; i++ ) {
			ba.writeByte( ar[i] );
		}
		
		// Title: 8 bytes
		for( i=0; i<8; i++ ) {
			// Pad title with trailing spaces
			ba.writeByte( (fseq.title+"        ").charCodeAt( i ) );
		}
		// Reserved: 8 bytes after title
		for( i=0; i<8; i++ ) {
			ba.writeByte( 0x0 );
		}
		
		write14BitWord( ba, fseq.loopStart );
		write14BitWord( ba, fseq.loopEnd );
		ba.writeByte( fseq.loopMode==Const.ONE_WAY ? 0x0 : 0x1 );
		ba.writeByte( fseq.speedAdjust );
		ba.writeByte( fseq.velSensitivity );
		ba.writeByte( fseq.pitchMode==Const.FSEQ_PITCH ? 0x0 : 0x1 );
		ba.writeByte( fseq.noteAssign );
		ba.writeByte( fseq.pitchTuning );
		ba.writeByte( fseq.seqDelay );
		ba.writeByte( frameCount/128 - 1 );	// 0==128 frames, 3==512 frames
		
		// Next 2 bytes are reserved, skip them
		ba.writeByte( 0x0 );
		ba.writeByte( 0x0 );
		
		// valid data end step
		if( frameCount==128 ) {
			ba.writeByte( 0x0 );
			ba.writeByte( 0x7f );
		} else if( frameCount==512 ) {
			ba.writeByte( 0x03 );
			ba.writeByte( 0x78 );
		}
		
		// Write the fseq frame data
		var readFrame:int = 0;
		for( var f:int=0; f<frameCount; f++ ) {	// Every frame:
			var fq:int;

			// Write the pitch first
			write14BitWord( ba, fseq.pitch().frame(readFrame).freqToSyx() );
			
			// Voiced: hi freq bytes, low freq bytes, then level.
			for( op=0; op<8; op++ ) {	// hi bytes
				fq = fseq.voiced(op).frame(readFrame).freqToSyx();
				ba.writeByte( (fq>>7) & 0x7f );
			}
			for( op=0; op<8; op++ ) {	// lo bytes
				fq = fseq.voiced(op).frame(readFrame).freqToSyx();
				ba.writeByte( fq & 0x7f );
			}
			for( op=0; op<8; op++ ) {
				ba.writeByte( fseq.voiced(op).frame(readFrame).ampToSyx() );
			}
			
			// Unvoiced frames: same as voiced
			for( op=0; op<8; op++ ) {	// hi bytes
				fq = fseq.unvoiced(op).frame(readFrame).freqToSyx();
				ba.writeByte( (fq>>7) & 0x7f );
			}
			for( op=0; op<8; op++ ) {	// lo bytes
				fq = fseq.unvoiced(op).frame(readFrame).freqToSyx();
				ba.writeByte( fq & 0x7f );
			}
			for( op=0; op<8; op++ ) {
				ba.writeByte( fseq.unvoiced(op).frame(readFrame).ampToSyx() );
			}
			
			// Depending on the number of frames being saved, we may skip over some frames in our FormantSequence.
			// FormantSequences always have 512 frames, but .syx format can have a reduced number.
			// TODO: Interpolation between frames?
			switch( frameCount ) {
				case 128:	readFrame += 4; break;
				case 256:	readFrame += 2; break;
				case 384:	readFrame += (f%3)==2 ? 1 : 0; break;	// TODO: Would be nice to interpolate
				case 512:	readFrame += 1; break;
			}
		}
		
		// Create the checksum
		var lastPos:int = ba.position;
		ba.position = 4;	// jump back to the beginning, skip the header
		var check:uint = 0x0;
		for( var b:int=4; b<lastPos; b++ ) {
			check += ba.readUnsignedByte();
		}
		
		ba.position = lastPos;
		ba.writeByte( 0x80 - (check&0x7f) );	// This is the checksum. When added to the other bytes, will yield 0x0 in lowest 7 bits.
		ba.writeByte( 0xf7 );	// Done!
		
		var file:FileReference = new FileReference();
		file.save( ba, fseq.title+".syx" );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function write14BitWord( ba:ByteArray, word16:int ) :void {
		ba.writeByte( (word16 >> 7) & 0x7f );	// hi
		ba.writeByte( word16 & 0x7f );	// lo 
	}
	
}

}

