package fseq.events
{

import flash.events.Event;

public class CustomEvent extends Event
{
	public static const LOAD_COMPLETE :String = "LOAD_COMPLETE";
	public static const LOAD_FAILED :String = "LOAD_FAILED";
	
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

