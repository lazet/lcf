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
		
		public function Container()
		{
			injector = new Injector();
			eventDispatcher = new EventDispatcher();
			injector.mapValue(EventDispatcher,eventDispatcher,Constants.EVENT_DISPATCHER);
			this.injector.mapValue(IContainer,this,Constants.CONTAINER);
		}
		
		public function put(name:String, ins:Object):void
		{
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
					for(var i = 0; i < ep.preferEventListeners.length; i++){
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
			
			var ins:Object = this.get(name);
			if(ins is IEventPrefer){
				var ep:IEventPrefer = ins as IEventPrefer;
				if(ep.preferEventListeners != null){
					for(var i = 0; i < ep.preferEventListeners.length; i++){
						var o:EventListenerModel = ep.preferEventListeners[i];
						if(o.eventType != null){
							eventDispatcher.removeEventListener(o.eventType,o.listener);
						}
					}
				}
			}
			
			try{	
				injector.unmap(this.nameClazzMap[name],name);
				this.nameClazzMap[name] = null;
				delete this.nameClazzMap[name];
			}catch(err:Error){
				trace(err);
			}
		}
		
		public function get(name:String):Object
		{
			try{
				return injector.getInstance(this.nameClazzMap[name],name);
			}
			catch(e:Error){
				return null;
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