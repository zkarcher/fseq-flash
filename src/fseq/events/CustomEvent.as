package fseq.events
{

import flash.events.Event;

public class CustomEvent extends Event
{
	public static const LOAD_COMPLETE :String = "LOAD_COMPLETE";
	public static const LOAD_FAILED :String = "LOAD_FAILED";
	public static const FSEQ_COMPLETE :String = "FSEQ_COMPLETE";
	public static const CANCEL :String = "CANCEL";
	
	// Audio playback
	public static const PLAYING_FRAME :String = "PLAYING_FRAME";
	public static const STOP_THE_SOUND :String = "STOP_THE_SOUND";
	
	// Editing
	public static const EDIT_START :String = "EDIT_START";
	public static const EDIT_STOP :String = "EDIT_STOP";
	
	// History
	public static const ACTIVE_FSEQ_CHANGED :String = "ACTIVE_FSEQ_CHANGED";
	
	public function CustomEvent(type:String, inData:Object=null, bubbles:Boolean=true, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		_data = inData || {};
	}
	
	private var _data :Object;
	public function get data() :Object { return _data; }
	
	override public function clone():Event
	{
		return new CustomEvent(type, _data, bubbles, cancelable);
	}
	
}

}

