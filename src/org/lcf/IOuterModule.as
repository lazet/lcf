package org.lcf
{
	public interface IOuterModule extends IModule
	{
		/**
		 *	获得容器
		 */        
		function get container():IContainer;
		/**
		 * 定义可以接收从父容器传入的事件集合;这个方法要由子类覆盖
		 * 返回集合是事件类型，事件class的集合['checkAccount']
		 */
		function get transferInEvents():Array;
		
		/**
		 * 定义可以传出给父容器的事件集合；这个方法要由子类覆盖
		 * 返回集合是事件类型，事件class的集合['checkAccount','addProductItem']
		 */
		function get transferOutEvents():Array;
		/**
		 * Modules need a method for cleanup and removal of the module from 
		 * memory to make them available for garbage collection. 
		 * 
		 */
		function unload():void;
	}
}