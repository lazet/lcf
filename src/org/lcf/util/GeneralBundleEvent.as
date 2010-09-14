package org.lcf.util
{
	import flash.events.Event;
	
	/**
	 * 可以携带包袱信息的类
	 */ 
	public class GeneralBundleEvent extends Event
	{
		private var _bundle:Object;
		public function get bundle():Object{
			return _bundle;
		}
		public function GeneralBundleEvent(type:String, bundle:Object)
		{
			super(type, bubbles, cancelable);
			this._bundle = bundle;
		}
	}
}