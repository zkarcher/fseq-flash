package fseq.model
{

public class OperatorFrame extends Object
{
	
	public function OperatorFrame( inAmp:Number, inFreq:Number )
	{
		super();
		amp = inAmp;
		freq = inFreq;
	}
	
	public var amp :Number;	// FS1R uses 7-bit numbers
	public var freq :Number;
	
	// Convert semitone number to hertz
	public function get syxFreq() :uint {
		// TODO, convert freq to 14-bit syxFreq
		return 0;
	}
	public static function syxToFreq( syx:uint ) :Number {
		// Reverse-engineered after a little hacking.
		// The frequencies probably aren't perfect yet.
		return Math.pow( 2.0, (14.302 - (0.001879 * (0x3fff - syx))) );
	}
	
	public function get syxAmp() :uint {
		// TODO, convert the amp db decimal back to 7-bit format.
		return 0;
	}
	public static function syxToAmp( syx:uint ) :Number {
		// 7-bit number. Convert to db.
		// How is it measured, 6 db steps for each 50% attenuation? 8.5 steps?
		// The syx values are inverted: 0 has the greatest amplitude, 0x7f the least.
		var stepsPer6db :Number = 8.5;	// 90db dynamic range?
		var inPow:Number = Math.pow( 2.0, Number(0x7f-syx) / stepsPer6db );
		var maxPow:Number = Math.pow( 2.0, Number(0x7f) / stepsPer6db );
		return inPow / maxPow;
		
	}
	
	public function clone() :OperatorFrame {
		return new OperatorFrame( amp, freq );
	}
}

}

