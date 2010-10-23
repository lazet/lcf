/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.lcf.util.EventDispatcher;
	import org.lcf.util.ModuleEvent;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.Reflector;
	
	public class Container implements IContainer
	{
		protected var injector:Injector;
		protected var eventDispatcher:EventDispatcher;
		protected var reflector:Reflector = new Reflector();
		protected var nameClazzMap:Dictionary = new Dictionary();
		protected var pContainer:IContainer;
		public function Container()
		{
			injector = new Injector();
			eventDispatcher = new EventDispatcher();
			injector.mapValue(EventDispatcher,eventDispatcher,Constants.EVENT_DISPATCHER);
			this.injector.mapValue(IContainer,this,Constants.CONTAINER);
		}
		/**
		 * 指定父容器
		 */ 
		public function set parentContainer(parent:IContainer):void{
			this.pContainer = parent;
		}
		public function put(name:String, ins:Object):void
		{
			this.remove(name);
			var c:Class = reflector.getClass(ins);
			if(c == null){
				c = reflector.getClass({});
				
			}
			this.nameClazzMap[name]=c;
			
			injector.mapValue(c,ins,name);
			injector.injectInto(ins);
			if(ins is IEventPrefer){
				var ep:IEventPrefer = ins as IEventPrefer;
				if(ep.preferEventListeners != null){
					for(var i:int = 0; i < ep.preferEventListeners.length; i++){
						var o:EventListenerModel = ep.preferEventListeners[i];
						if(o.eventType != null && o.listener != null){
							eventDispatcher.addEventListener(o.eventType,o.listener);
						}
					}
				}
			}
		}
		
		public function remove(name:String):void
		{
			
			var ins:Object = this.getInternal(name);
			if(ins is IEventPrefer){
				var ep:IEventPrefer = ins as IEventPrefer;
				if(ep.preferEventListeners != null){
					for(var i:int = 0; i < ep.preferEventListeners.length; i++){
						var o:EventListenerModel = ep.preferEventListeners[i];
						if(o.eventType != null){
							eventDispatcher.removeEventListener(o.eventType,o.listener);
						}
					}
				}
			}
			
			try{
				this.nameClazzMap[name] = null;
				delete this.nameClazzMap[name];
				injector.unmap(this.nameClazzMap[name],name);
				
			}catch(err:Error){
				trace(err);
			}
		}
		
		public function get(name:String):Object
		{
			var result:Object = getInternal(name);
			if(result == null && pContainer != null){
				return pContainer.get(name);
			}
			return result;
		}
		protected function getInternal(name:String):Object
		{
			try{
				return injector.getInstance(this.nameClazzMap[name],name);
			}
			catch(e:Error){
				trace(e);
			}
			return null;
		}	
		public function dispatch(e:Event):void
		{
			this.eventDispatcher.dispatchEvent(e);
		}
		/**
		 * 关闭容器
		 */
		public function close():void
		{
			for(var key:String in this.nameClazzMap){
				try{
					this.remove(key);
				}catch(e:Error){
					
				}
			}
			this.injector.unmap(EventDispatcher,Constants.EVENT_DISPATCHER);
			this.injector.unmap(IContainer,Constants.CONTAINER);
			
			this.nameClazzMap = null;
			this.eventDispatcher = null;
			this.injector = null;
			this.nameClazzMap = null;
		}
	}
}