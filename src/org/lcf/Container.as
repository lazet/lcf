package org.lcf
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.Reflector;
	
	public class Container implements IContainer
	{
		protected var injector:Injector = new Injector();
		protected var eventDispatcher:IEventDispatcher = new EventDispatcher();
		protected var reflector:Reflector = new Reflector();
		protected var nameClazzMap:Dictionary = new Dictionary();
		
		public function Container()
		{
			injector.mapValue(IEventDispatcher,eventDispatcher,Constants.EVENT_DISPATCHER);
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
						var o:Object = ep.preferEventListeners[i];
						if(o.eventType != null){
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
						var o:Object = ep.preferEventListeners[i];
						if(o.eventType != null){
							eventDispatcher.removeEventListener(o.eventType,o.listener);
						}
					}
				}
			}
				
			injector.unmap(this.nameClazzMap[name],name);
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
		 * 还没有完全清理干净，会有内存泄露，须逐个清理对象的事件处理
		 */
		public function close():void
		{
			eventDispatcher = null;
			injector = null;
			nameClazzMap = null;
		}
	}
}