/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf.util
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class EventDispatcher
	{
		private var eventMap:Dictionary = new Dictionary();
		public function EventDispatcher()
		{
		}
		public function dispatchEvent(e:Event):void{
			if(e == null){
				return;
			}
			var ls:Array = eventMap[e.type];
			if (ls == null){
				ls = new Array();
			}
			var len:int = ls.length;
			for(var i:int = 0; i< len; i++){
				try{
					ls[i](e);
				}catch(err:Error){
					trace(err);
				}
			}
		}
		public function addEventListener(eventType:String, listener:Function):void{
			if(eventType == null || listener == null)
				return;
			var ls:Array = eventMap[eventType];
			if (ls == null){
				ls = new Array();
			}
			//判断数组中是否存在新增的监听器
			var len:int = ls.length;
			for(var i:int = 0; i< len; i++){
				if(listener == ls[i]){
					return;
				}
			}
			ls.push(listener);
			this.eventMap[eventType] = ls;
		}
		public function removeEventListener(eventType:String,listener:Function):void{
			if(eventType == null || listener == null)
				return;
			var ls:Array = eventMap[eventType];
			if (ls == null){
				ls = new Array();
			}
			//判断数组中是否存在新增的监听器
			var len:int = ls.length;
			for(var i:int = 0; i< len; i++){
				if(listener == ls[i]){
					ls.splice(i,1);
					return;
				}
			}
		}
	}
}