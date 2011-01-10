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
		// TODO, gah I wish I knew what the formula was
		return Number( syx );
	}
	
	public function get syxAmp() :uint {
		// TODO, convert the amp db decimal back to 7-bit format.
		return 0;
	}
	public static function syxToAmp( syx:uint ) :Number {
		// 7-bit number. Convert to db.
		// TODO
		return syx / Number(0x7f);
	}
	
	public function clone() :OperatorFrame {
		return new OperatorFrame( amp, freq );
	}
}

}

