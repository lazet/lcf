package org.lcf
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.*;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.events.ResizeEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	import mx.utils.ArrayUtil;
	
	import org.lcf.IContainer;
	import org.lcf.util.ModuleEvent;
	import org.lcf.util.Tab;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.List;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	[SkinState("open")]
	[SkinState("normal")]
	/**
	 * 页签导航
	 */ 
	public class TabNavigator extends SkinnableComponent implements IModuleManager,IEventPrefer
	{
		protected var modules:Array = new Array();
		
		protected var moduleIndexMap:Dictionary = new Dictionary();
		
		[Binding]
		protected var pointer:int = -1;
		
		protected var c:IContainer;
		
		
		/*****图形元素****/
		[SkinPart(required="true")]
		public var tabs:HGroup;
		[SkinPart(required="true")]
		public var switchButton:Button;
		[SkinPart(required="true")]
		public var content:VGroup;
		[SkinPart(required="true")]
		public var selectableList:List;
		public var switching:Boolean;
		[SkinPart(required="true")]
		public var addButton:Button;
		public var addEnable:Boolean=false;
		public var addFunction:Function;
		
		private var tabNumber:int = 6;
		public function TabNavigator()
		{
			super();
			c = new Container();
			this.setStyle("skinClass",TabNavigatorSkin);
			c.put(Constants.TAB_NAVIGATOR,this);
			this.addEventListener(FlexEvent.CREATION_COMPLETE ,onResize);
		}
		
		public function open(moduleId:String, moduleName:String, moduleInfo:Object, icon:String=null, reload:Boolean=false, closable:Boolean=true):Boolean
		{
			//检查现有组件，是否存在Id相同的，如果存在，则根据reload加以处理
			var index:int = -1;
			if(this.moduleIndexMap[moduleId] != null){
				if(reload == false){
					this.switchTo(moduleId);
					return true;
					
				}else{
					this.close(moduleId);
				}
			}
			//判断ModuleInfo，如果是字符串，并且是以.swf结尾的，则调用模块加载器进行加载
			if(moduleInfo is String){
				var info:String = moduleInfo as String;
				if(info.toLowerCase().lastIndexOf(".swf") + 4 == info.length){//这是一swf文件路径，需要加载
					this.loadModule(moduleId,moduleName,info,icon,closable);
				}
				else{//这是一个类名，需要实例化
					var ins:IVisualElement = newInstance(info) as IVisualElement;
					if(ins == null){
						return false;
					}	
				}
			}
				//如果不是字符串，则判断是否是个显示对象，如果是则显示之
			else{
				this.add(moduleId,moduleName,moduleInfo as IVisualElement,icon,closable);
			}
			return true;
		}
		/**
		 * 参数m不能是字符
		 */ 
		public function openModule(m:IModule,icon:String=null, reload:Boolean=false, closable:Boolean=true):Boolean
		{
			if(reload == false){
				var index:int = -1;
				if(this.moduleIndexMap[m.id] != null){
					if(reload == false){
						this.switchTo(m.id);
						return true;
					}else{
						this.close(m.id);
					}
				}
			}
			this.add(m.id,m.name,m as IVisualElement,icon,closable);
			return true;
		}
		
		public function close(moduleId:String):Boolean
		{
			//删除内容
			if(this.pointer == this.moduleIndexMap[moduleId]){
				this.content.removeAllElements();
			}
			//从列表中删除
			//先判断在当前图元上是否存在
			for(var i:int=0;i< this.tabs.numElements;i++){
				var t:Tab = this.tabs.getElementAt(i) as Tab;
				if(t.id == moduleId){
					this.tabs.removeElementAt(i);
					break;
				}
			}
			//从Tab容器中删除图形对象
			c.remove(moduleId);
			//删除原始对象
			var pos:int = this.moduleIndexMap[moduleId];
			this.modules.splice(pos,1);
			
			//如果当前的Tab容器元素个数不足this.tabNumber个，则补充1个Tab
			if(this.tabs.numElements < this.tabNumber && this.modules.length >= this.tabNumber){
				//补充第一个没放进去的
				for(var j:int = 0; j < this.modules.length; j++){
					var cm:ModuleInfo = this.modules[j];
					
					var isExist:Boolean = false;
					for(var i:int=0;i< this.tabs.numElements;i++){
						var t:Tab = this.tabs.getElementAt(i) as Tab;
						if(t.id == cm.moduleId){
							isExist = true;
							break;
						}
					}
					
					if (!isExist){
						this.tabs.addElement(this.c.get(cm.moduleId) as Tab);
						break;
					}
				}
			}
			refresh();
			var p:int = this.pointer;
			if(p >= pos){
				p--;
			}
			if(p == -1 && this.modules.length > 0){
				p = 0;
			}
			this.pointer = -1;
			if(p >= 0) {			
				this.switchTo((this.modules[p] as ModuleInfo).moduleId);
			}
			return true;
		}
		
		public function closeOther(moduleId:String):Boolean
		{
			//循环关闭其他所有链接（不可以关闭的，不关）
			var pos:int = 0;
			var closing:Array = new Array();
			for(var i:int = 0;i < this.modules.length; i++){
				var o = this.modules[i];
				if(o.moduleId != moduleId && o.closable == true){
					closing.push(o.moduleId);
				}
			}
			for(var i:int = 0; i< closing.length;i++){
				this.close(closing[i] as String);
			}
			return true;
		}
		
		public function closeAll():Boolean
		{
			//循环关闭其他所有链接（不可以关闭的，不关）
			var pos:int = 0;
			var closing:Array = new Array();
			for(var i:int = 0;i < this.modules.length; i++){
				var o = this.modules[i];
				if(o.closable == true){
					closing.push(o.moduleId);
				}
			}
			for(var i:int = 0; i< closing.length;i++){
				this.close(closing[i] as String);
			}
			return true;
		}
		
		public function list():XML
		{
			//按顺序列出所有对象
			var result:String = new String();
			result += '<result>';
			for(var i:int = 0;i < this.modules.length; i++){
				var o:* = this.modules[i];
				result += ('<module id="' + o.moduleId + '" label="' + o.moduleName  + '" position="'+ i + '"/>');
			}
			result += '</result>';
			return new XML(result);
			
		}
		
		public function switchTo(moduleId:String):Boolean
		{
			if(this.moduleIndexMap[moduleId] >= 0){
				if(this.pointer == this.moduleIndexMap[moduleId])
					return true;
				var mm:ModuleInfo = this.moduleInfo(moduleId);
				
				var tab:Tab = c.get(moduleId) as Tab;
				if( tab == null){
					tab = new Tab(moduleId,mm.moduleName,mm.icon,mm.closable);
					c.put(moduleId,tab);
					tab.container = c;
				}
				//先判断在当前图元上是否存在
				var isExists:Boolean = false;
				for(var i:int=0;i< this.tabs.numElements;i++){
					var t:Tab = this.tabs.getElementAt(i) as Tab;
					if(t.id == moduleId){
						isExists = true;
						break;
					}
				}
				//在图形上添加图元
				if (isExists){
					//发送事件，选中此组件
					this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_SELECTED_EVENT,moduleId));
				}
				else{
					if(this.tabs.numElements >= this.tabNumber){
						this.tabs.removeElementAt(0);
					}
					this.tabs.addElement(tab);
					this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_SELECTED_EVENT,moduleId));
				}
				this.content.removeAllElements();
				this.content.addElement(mm.moduleObject);
				this.content.invalidateDisplayList();
				this.invalidateDisplayList();
				this.pointer = this.moduleIndexMap[moduleId];
				//如果状态不是normal则关闭
				closeSwitchList();
				return true;
			}
			else{
				return false;
			}
		}
		
		public function get currentModuleInfo():ModuleInfo
		{
			if( this.pointer == -1){
				return null;
			}
			else{
				this.modules[this.pointer].position = this.pointer;
				return this.modules[this.pointer];
			}
		}
		public function get currentPosition():int
		{
			return this.pointer;
		}
		
		
		public function back():Boolean
		{
			if ( this.pointer > 0) {
				return this.switchTo((this.modules[this.pointer - 1] as ModuleInfo).moduleId);
			}
			else{	
				return false;
			}
		}
		public function moduleInfo(moduleId:String):ModuleInfo{
			if(this.moduleIndexMap[moduleId] >= 0){
				var o:* = this.modules[this.moduleIndexMap[moduleId] as int];
				o.position = this.moduleIndexMap[moduleId] as int;
				return o;
			}
			else{
				return null;
			}
		}
		public function forward():Boolean
		{
			if ( this.pointer < this.modules.length -1) {
				return this.switchTo((this.modules[this.pointer + 1] as ModuleInfo).moduleId);
			}
			else{	
				return false;
			}
		}
		public function unload():Boolean{
			this.closeAll();
			this.c = null;
			this.modules = null;
			this.moduleIndexMap = null;
			return true;
		}
		
		/******inner function *****/
		protected function loadModule(moduleId:String,moduleName:String, url:String,icon:String,closable:Boolean):void {
			var info:IModuleInfo = ModuleManager.getModule(url);
			
			if(info.ready){
				addInternal(info,moduleId, moduleName,icon, closable );
			}
			else{
				info.addEventListener(mx.events.ModuleEvent.READY, 
					function(e:mx.events.ModuleEvent){
						addInternal(e.module,moduleId,moduleName,icon, closable);
					});
				info.load();
			}
		}
		
		protected function addInternal(info:IModuleInfo, mId:String,mName:String,icon:String, mClosable:Boolean):void{
			
			//创建对象
			var mo:IVisualElement = info.factory.create() as IVisualElement;
			if(mo is IModule){
				var module:IModule = mo as IModule;
				module.parentCenter = this.c;
			}
			var m:ModuleInfo = new ModuleInfo(mId,mName,mo,icon,mClosable);
			this.modules.push(m);
			this.moduleIndexMap[m.moduleId]=this.modules.length -1;
			this.switchTo(m.moduleId);
		}
		protected function newInstance(url:String):Object{
			try{
				var clazz:Class =Class(getDefinitionByName(url));
				var ins:Object = new clazz();
				return ins;	
			}catch(error:Error){
				return null;
				
			}
			return null;
		}
		protected function add(moduleId:String,moduleName:String, mo:IVisualElement,icon:String,closable:Boolean):void {
			var o:ModuleInfo = new ModuleInfo(moduleId,moduleName,mo,icon,closable);
			
			if(mo is IModule){
				var module:IModule = mo as IModule;
				module.id = moduleId;
				module.name = moduleName;
				module.parentCenter = this.c;
			}
			this.modules.push(o);
			this.moduleIndexMap[o.moduleId]=this.modules.length -1;
			
			
			this.switchTo(moduleId);
		}
		/**
		 * 刷新容器
		 */ 
		protected function refresh():void{
			this.moduleIndexMap = new Dictionary();
			for(var i:int = 0; i< this.modules.length; i++){
				var o:ModuleInfo = this.modules[i];
				this.moduleIndexMap[o.moduleId] = i;
			}
		}
		
		/**
		 * 注册事件监听程序定义
		 * 返回结果:
		 * 事件class的集合[new EventListenerModel(),new EventListenerModel()]
		 */ 
		public function get preferEventListeners():Array{
			var selectElm:EventListenerModel = new EventListenerModel(Constants.SELECT_MODULE_EVENT,checkSelectEvent);
			var closeElm:EventListenerModel = new EventListenerModel(Constants.CLOSE_MODULE_EVENT,closeEvent);
			return [selectElm,closeElm];
		}
		protected function checkSelectEvent(e:org.lcf.util.ModuleEvent):void{
			this.switchTo(e.moduleId); 
		}
		protected function closeEvent(e:org.lcf.util.ModuleEvent):void{
			this.close(e.moduleId); 
		}
		/***************************************/
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.switchButton){
				
				this.switchButton.addEventListener(MouseEvent.CLICK, onSwitch);				
			}
			else if(instance == this.selectableList){
				this.selectableList.dataProvider = new XMLListCollection(this.list().children());
				this.selectableList.selectedIndex = -1;
				this.selectableList.addEventListener(spark.events.IndexChangeEvent.CHANGE,onSelectTab);
			}
			else if(instance == this.tabs){
				this.tabs.addEventListener(MouseEvent.CLICK, closeSwitchList);
			}
			else if(instance == this.content){
				this.content.addEventListener(MouseEvent.CLICK, closeSwitchList);
			}
			else if(instance == this.addButton){
				if(this.addEnable == false){
					this.addButton.visible= false;
				}
				if(this.addFunction != null){
					this.addButton.addEventListener(MouseEvent.CLICK, onAdd);
				}
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == this.switchButton){
				this.switchButton.removeEventListener(MouseEvent.CLICK, onSwitch);				
			}
			else if(instance == this.selectableList){
				this.selectableList.removeEventListener(spark.events.IndexChangeEvent.CHANGE,onSelectTab);
			}
			else if(instance == this.tabs){
				this.tabs.removeEventListener(MouseEvent.CLICK, closeSwitchList);
			}
			else if(instance == this.content){
				this.content.removeEventListener(MouseEvent.CLICK, closeSwitchList);
			}
			else if(instance == this.addButton){
				if(this.addFunction != null){
					this.addButton.removeEventListener(MouseEvent.CLICK, onAdd);
				}
			}
		}
		override protected function getCurrentSkinState():String{
			if(this.switching){
				return "open";
			}
			return "normal";
		}
		public function onSwitch(e:MouseEvent):void{
			this.switching = !this.switching;
			this.invalidateSkinState();
		}
		public function onAdd(e:MouseEvent):void{
			this.addFunction();
		}
		public function closeSwitchList(e:Event = null):void{
			if(this.switching){
				this.switching = false;
				this.invalidateSkinState();
			}
		}
		public function onSelectTab(e:IndexChangeEvent):void{
			var currentDataItem:Object = e.currentTarget.selectedItem;
			var moduleId = currentDataItem.@id;
			this.switchTo(moduleId);	
		}
		public function onResize(e:FlexEvent){
			if(this.width > 0)
				this.tabNumber = Math.floor((this.width-80)/80);
		}
	}
}