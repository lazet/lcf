/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf
{
	import org.lcf.EventListenerModel;
	import org.lcf.IEventPrefer;
	/**
	 * 时间监听定义（定义那些事件用什么方法监听）
	 */ 
	public class EventListenerModel implements IEventPrefer
	{
		public var eventType:String;
		public var listener:Function;
		public function EventListenerModel(eventType:String = null,listener:Function = null)
		{
			this.eventType = eventType;
			this.listener = listener;
		}
		public function get preferEventListeners():Array
		{
			return [this];
		}
	}
}