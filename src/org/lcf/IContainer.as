package org.lcf
{
	import flash.events.Event;

	/**
	 * 服务调度中心
	 */
	public interface IContainer
	{
		
		
		/**
		 *	 将对象放入容器
		 */
		function put(name:String, ins:Object):void;
		/**
		 *	 将对象放入容器
		 */
		function remove(name:String):void;
		/**
		 *	 将对象放入容器
		 */
		function get(name:String):Object;
		
		/**
		 * 分发事件
		 */
		function dispatch(e:Event):void;
		
		/**
		 * 关闭中心
		 */
		function close():void;
		
	}
}