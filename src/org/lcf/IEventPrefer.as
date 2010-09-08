package org.lcf
{
	/**
	 * 事件偏好监听接口
	 * 当把实现此接口的对象放入中心容器时，由中心容器调用
	 * 当把实现此接口的对象从中心容器删除时
	 */
	public interface IEventPrefer
	{
		/**
		 * 注册事件监听程序定义
		 * 返回结果:
		 * 事件class的集合[new EventListenerModel(),new EventListenerModel()]
		 */ 
		function get preferEventListeners():Array;
		
	}
}