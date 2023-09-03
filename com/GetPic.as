package com
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author hld
	 */
	public class GetPic extends Sprite{
		
		private var _file:FileReference;
		private var _pro:Number;//加载进度
		
		private var _callBack:Function;
		private var _urlLoader:URLLoader;
		private var _loader:Loader;
		private var isLoading:Boolean;
		public static const ERROR:String = "error";
		public function GetPic() {
			//
			isLoading = false;
			}
		//------------------浏览本地图片，并加载---------------------
		/**
		 * 浏览本地图片，并加载
		 * @param	fun	回调函数(回调函数的参数为BitmapData)
		 */
		public function getPicInLocal(fun:Function = null) {
			if (isLoading) {
				throw(new Error("一个实例只能同时加载一个图片"));
				return;
				}
			isLoading = true;
			_callBack = fun;
			_file = new FileReference();
			var fileFilter:FileFilter = new FileFilter("图片文件格式 (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
			_file.addEventListener(Event.SELECT, onSelectedFun);
			_file.addEventListener(Event.CANCEL, onCancelFun);
			_file.browse([fileFilter]);
			}
		//-------------------根据地址加载图片--------------------
		/**
		 * 根据地址加载图片
		 * @param	url	String 图片地址，可以是本地或是线上地址
		 * @param	fun	回调函数
		 */
		public function getPicByUrl(url:String, fun:Function = null) {
			if (isLoading) {
				throw(new Error("一个实例只能同时加载一个图片"));
				return;
				}
			isLoading = false;
			_callBack = fun;
			var req:URLRequest = new URLRequest(url);
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onErrorFun);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorFun);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressFun);
			_urlLoader.addEventListener(Event.COMPLETE, onLoadedFun);
			_urlLoader.load(req);
			}
		//----------------------外部读取加载进度---------------------------
		/**
		 * 返回加载进度，0到1之间的小数
		 * @param	n	int	小数位数
		 * @return	Number 加载进度
		 */
		public function getProgress(n:int=1):Number {
			for (var i:int = 0; i < n;i++ ) {
				_pro *= 10;
				}
			_pro = Math.floor(_pro);
			for (i = 0; i < n - 1;i++ ) {
				_pro /= 10;
				}
			return _pro;
			}
		//-----------------------浏览加载本地相关-------------------------
		private function onCancelFun(e:Event) {
			trace(e);
			isLoading = true;
			}
		private function onSelectedFun(e:Event) {
			if (_file.size > 1024 * 1024 * 8) {
				printf("您选择的图片大于8M，\n请重新选择图片。");
				}
			else {
				_file.addEventListener(Event.OPEN, onOpenFun);
				_file.addEventListener(Event.COMPLETE, onLoadedFun);
				_file.addEventListener(ProgressEvent.PROGRESS, onProgressFun);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onErrorFun);
				_file.load();
				}
			}
		private function onOpenFun(e:Event) {
			trace("开始加载");
			}
		//-----------------------二次加载(公用)------------------------
		private function onLoadedFun(e:Event) { 
			trace("加载完成");
			var ld:Loader = new Loader();
			ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorFun);
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteFun);
			ld.loadBytes(e.currentTarget.data);
			}
		private function onCompleteFun(e:Event) {
			var ldr:Loader = Loader(e.currentTarget.loader);
			var bmd:BitmapData = new BitmapData(ldr.width, ldr.height);
			bmd.draw(ldr);
			if (_callBack!=null) {
				_callBack(bmd);
				}
			isLoading = false;
			}
		//----------------更新加载进度(公用)--------------------
		private function onProgressFun(e:ProgressEvent) {
			_pro = e.bytesLoaded / e.bytesTotal;
			}
		//-----------------加载出错---------------------
		private function onErrorFun(e:Event) {
			dispatchEvent(new Event(GetPic.ERROR));
			printf("打开图片出错");
			isLoading = false;
			/*
			if (_callBack!=null) {
				_callBack(null);
				}*/
			}
		//--------------功能函数-------------------
		/**
		 * 获取FileReference选择到的本地图片的属性，这个函数没什么必要存在，权当备忘录了
		 * @param	file
		 * @return
		 */
		private function getFileInfo(file:FileReference):Object {//均为只读属性
			var obj:Object = new Object();
			obj["name"] = file.name;
			obj["size"] = file.size;
			obj["type"] = file.type;
			obj["creationDate"] = file.creationDate;//创建日期
			obj["modificationDate"] = file.modificationDate;//上一次修改日期
			//obj["extension"] = file.extension;//扩展名
			//obj["creator"] = file.creator;//文件的 Macintosh 创建者类型，此类型仅用于 Mac OS X 之前的 Mac OS 版本中
			//obj["data"] = file.data;
			return obj;
			}
		/**
		 * 输出信息
		 * @param	str
		 */
		private function printf(str:String) {
			if (ExternalInterface.available) {
				ExternalInterface.call("alert",str);
					}
			else {
				trace(str);
				}
			}
	}
	
}













