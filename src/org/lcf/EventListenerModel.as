package org.lcf
{
	/**
	 * 时间监听定义（定义那些事件用什么方法监听）
	 */ 
	public class EventListenerModel
	{
		public var eventType:String;
		public var listener:Function;
		public function EventListenerModel(eventType:String = null,listener:Function = null)
		{
			this.eventType = eventType;
			this.listener = listener;
		}
	}
}