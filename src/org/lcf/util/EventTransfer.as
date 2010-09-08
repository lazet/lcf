package org.lcf.util
{
	import flash.events.Event;
	
	import org.lcf.Constants;
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.IModule;
	import org.lcf.EventListenerModel;
	
	public class EventTransfer implements IEventPrefer
	{
		public static var EVENT_TRANSFER:String   = ".EVENT_TRANSFER";
		private var events:Array;
		private var from:IContainer;
		private var to:IContainer;
		private var eId:String;
		

		
		public function EventTransfer(id:String,eventNames:Array,from:IContainer,to:IContainer)
		{

			this.eId = id;
			this.events = new Array(eventNames.length);
			this.from = from;
			this.to = to;
			if(eventNames != null){
				for(var i:int = 0;i < eventNames.length;i++){
					var o:EventListenerModel = new EventListenerModel(eventNames[i],reDispatchEvent);
				
					this.events[i] = o;
				}
			}
			
		}
		public function get id():String{
			return eId;
		}
		public function get preferEventListeners():Array
		{
			return events;
		}
		public function reDispatchEvent(e:Event){
			to.dispatch(e);
		}
	}
}