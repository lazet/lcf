package org.lcf
{
	import mx.core.IVisualElement;

	public class ModuleInfo
	{
		//模块编号
		public var moduleId:String;
		//模块名称
		public var moduleName:String;
		//模块相应的可视化对象
		public var moduleObject:IVisualElement;
		//图标路径
		public var icon:String;
		//模块是否允许关闭
		public var closable:Boolean;
		//模块的位置
		public var position:int;
		/**
		 * 模块基本信息
		 */ 
		public function ModuleInfo(moduleId:String,moduleName:String,moduleObject:IVisualElement,icon:String=null,closable:Boolean = false,position:int = 0)
		{
			this.moduleId = moduleId;
			this.moduleName = moduleName;
			this.moduleObject = moduleObject;
			this.icon = icon;
			this.closable = closable;
			this.position = position;
		}
	}
}