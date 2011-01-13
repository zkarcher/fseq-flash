package fseq.model
{

public class Const extends Object
{
	// Audio settings
	public static const SAMPLE_RATE :Number = 44100;
	public static const BUFFER_SIZE :int = 4096;	// mono size, not stereo, so less than 4096 plz
	public static const LERP_SAMPLES :Number = 30;	// "Smoothly" transition between pitch/width/etc changes

	// Fseq parameters
	public static const FRAMES :int = 512;
	public static const VOICED_OPS :int = 8;
	public static const UNVOICED_OPS :int = 8;
	
	// View modes & color palettes, etc
	public static const FREQ :String = "FREQ";
	public static const AMP :String = "AMP";
	
	// Operator types
	public static const PITCH :String = "PITCH";
	public static const VOICED :String = "VOICED";
	public static const UNVOICED :String = "UNVOICED";
	
	// Editor
	public static const GRAPH_SCALE_X :Number = 2.0;
	public static const GRAPH_AMP_HEIGHT :Number = 200;
	public static const GRAPH_FREQ_HEIGHT :Number = 500;
	
	public function Const()
	{
		super();
	}
	
	public static function color( type:String, id:int=0 ) :uint {
		switch( type ) {
			case Const.PITCH:
				return 0xffffff;
			
			case Const.VOICED:
				return [0xff4801,0xfe1d16,0xfe1f72,0xfd2096,0xf626ff,0xc749ff,0x9350ff,0x6b78ff][id];
				
			case Const.UNVOICED:
				return [0x00feed,0x00f6c0,0x00ec86,0x00db40,0x08c827,0x1cb827,0x459b34,0x787a52][id];
		}
		trace("** SequenceView: What weird color are you looking for? I only accept", Const.PITCH, Const.VOICED, Const.UNVOICED, "...", type, id);
		return 0x444444;
	}
	
}

}

