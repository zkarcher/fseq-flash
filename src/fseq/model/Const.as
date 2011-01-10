package fseq.model
{

public class Const extends Object
{
	// Audio settings
	public static const SAMPLE_RATE :Number = 44100;
	public static const BUFFER_SIZE :int = 4096;	// mono size, not stereo, so less than 4096 plz
	public static const LERP_SAMPLES :Number = 100;	// "Smoothly" transition between pitch/width/etc changes

	// Fseq parameters
	public static const FRAMES :int = 512;
	public static const VOICED_OPS :int = 8;
	public static const UNVOICED_OPS :int = 8;
	
	public function Const()
	{
		super();
	}
	
}

}

