/**
 * File for VM class
 *
 * @package   vm
 * @author    Denis Tatarnikov <tatarnikovda@gmail.com>
 */
package vm 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.fscommand;
	import flash.utils.Timer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	import vm.external.*;
	import vm.targets.FirebugTarget;
	import vm.utils.NumberUtil;
	
	/**
	* VM class
	*
	* @package  vm
	* @author   Denis Tatarnikov <tatarnikovda@gmail.com>
	*/
	public class VM extends Sprite 
	{
		//VM version
		public var version:String = "0.0.5";
		public var copyright:String = "Denis Tatarnikov, 2013";
		
		//Log target and logger interface
		private var _logger:ILogger;
		private var _firebugTarget:FirebugTarget;
		
		//Connection variables
		private var _nc:NetConnection;
		private var _video:Video;
		private var _videoPlayer:Video;
		private var _cam:Camera;
		private var _mic:Microphone;
		
		//Flags
		private var _isPlaying:Boolean = false;
		private var _isRecording:Boolean = false;
		private var _isFirstPublish:Boolean = true;
		private var _stopFlag:Boolean = true;
		private var _isRecordAvail:Boolean = false;
		
		//Aditional variables
		private var _timer:Timer;
		private var _width:Number;
		private var _height:Number;		
		
		//Set-up variables
		private var _streamManager:StreamManager;
		private var _remoteServer:String = "rtmp://localhost/vm";
		private var _streamName:String = "streamVideo";
		private var _streamType:String = StreamManager.TYPE_MP4;
		private var _recordTimeLimit:int = 30;
		private var _debug:Boolean = true;
		
		/**
		 * Constructor.
		 */
		public function VM() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.showDefaultContextMenu = false;
			
			_timer = new Timer(500);
			_timer.addEventListener(TimerEvent.TIMER, _onTimerEvent, false, 0, true);
			
			_firebugTarget = new FirebugTarget();
			_firebugTarget.includeLevel	= true;
			_firebugTarget.includeCategory = true;
			_firebugTarget.level = LogEventLevel.ALL;
			Log.addTarget(_firebugTarget);
			
			_logger = Log.getLogger('VM');
			
			_logger.info("v." + version);
						
			if(stage) 
				_init();
			else
				addEventListener(Event.ADDED_TO_STAGE, _init, false, 0, true);
		}
		
		/**
		 * Set remote server url
		 * 
		 * @param value remote server url
		 */
		public function setRemoteServer(value:String):void
		{
			_remoteServer = value;
		}
		
		/**
		 * Set stream name
		 * 
		 * @param value stream name
		 */
		public function setStreamName(value:String):void
		{
			_streamManager.streamName = value;
		}
		
		/**
		 * Set stream type
		 * 
		 * @param value stream type
		 */
		public function setStreamType(value:String):void
		{
			_streamManager.streamType = value;
		}
		
		/**
		 * Set record time limit
		 * 
		 * @param value record time limit
		 */
		public function setRecordTime(value:int):void
		{
			_recordTimeLimit = value;
			timerTxt.text = NumberUtil.formatMinSecFromSec(value);
		}
		
		/**
		 * Returns stream url
		 * 
		 * @return stream url
		 */
		public function getStreamUrl():String
		{
			//TODO replace with RegExp
			return _remoteServer.replace("rtmp://", "http://") + "/" + _streamManager.streamRawName;
		}
		
		/**
		 * Returns is record available
		 * 
		 * @return is record available
		 */
		public function isRecordAvailable():Boolean
		{
			return _isRecordAvail;
		}
		
		/**
		 * Set debug mode
		 * 
		 * @param value debug
		 */
		public function setDebug(value:Boolean):void
		{
			_debug = value;
		}
		
		/**
		 * Start video recording
		 */
		private function startRecord():void
		{
			_video.visible = true;
			_videoPlayer.visible = false;
						
			_isRecording = true;
			_streamManager.streamOut.publish(_streamManager.streamName, "record");
			_streamManager.streamOut.send("@setDataFrame", "onMetaData", _streamManager.metaData);
			recordBtn.label = "Stop";
			
			timerTxt.text = NumberUtil.formatMinSecFromSec(_recordTimeLimit);
			_timer.reset();
			_timer.start();
		}
		
		/**
		 * Stop video recording
		 * 
		 * @param show Change view to "recording video"
		 */
		private function stopRecord(show:Boolean=true):void
		{
			if(show) {
				_video.visible = true;
				_videoPlayer.visible = false;				
				_timer.stop();
				_timer.reset();
			}
			
			_isRecording = false;			
			recordBtn.label = "Record";
			
			/*var start:int = new Date().time;
			while(_streamManager.streamOut.liveDelay>0) {
				if(new Date().time - start >= 10000) {
					break;
				}
				trace("time: " + _streamManager.streamOut.liveDelay);
			}*/
			_streamManager.streamOut.publish(null);
		}
		
		/**
		 * Start playing video that was recorded before.
		 */
		private function startPlay():void
		{
			//Check is any recording was made
			if(_streamManager.streamOut.time!=0) {
				_video.visible = false;
				_videoPlayer.visible = true;
				
				_isPlaying = true;
				_streamManager.streamIn.seek(0);
				_streamManager.streamIn.resume();
				resumeBtn.label = "Pause";
				
				timerTxt.text = NumberUtil.formatMinSecFromSec(0);
				_timer.reset();
				_timer.start();
			}
		}
		
		/**
		 * Stop playing video that was recorded before.
		 * 
		 * @param show Change view to "playing video"
		 */
		private function stopPlay(show:Boolean=true):void
		{
			if(show) {
				_video.visible = false;
				_videoPlayer.visible = true;
				_timer.stop();
				_timer.reset();
			}
			
			_isPlaying = false;
			_streamManager.streamIn.pause();
			resumeBtn.label = "Play";	
		}
		
		/**
		 * Cancel recording and close app.
		 */
		private function close():void
		{
			_disconnect();
			_nc.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			
			_timer.stop();
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, _onTimerEvent);
			
			_streamManager.streamOut.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			_streamManager.streamOut.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError);
			
			_streamManager.streamIn.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			_streamManager.streamIn.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError);
			
			recordBtn.removeEventListener(MouseEvent.CLICK, _buttonClick);
			resumeBtn.removeEventListener(MouseEvent.CLICK, _buttonClick);
			closeBtn.removeEventListener(MouseEvent.CLICK, _buttonClick);
			
			_removeExternalEvents();
			
			ExternalEvents.call(Protocol.EVENT_CLOSE);
		}
		
		/**
		 * Initiate 
		 */
		private function _init(e:Event = null):void
		{
			_logger.info("... initiating");
			
			removeEventListener(Event.ADDED_TO_STAGE, _init);
			_preload();
		}
		
		private function _preload():void
		{
			this.root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, _loading, false, 0, true);
			this.root.loaderInfo.addEventListener(Event.COMPLETE, _loadComplete, false, 0, true);			
		}
		
		/**
		* Connect to the server.
		*/
		private function _connect():void 
		{
			try {
				_logger.info("... connecting to " + _remoteServer);
				
				_nc = new NetConnection();
				_nc.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler, false, 0, true);
				_nc.connect(_remoteServer);
			} 
			catch(e:Error) {
				_logger.error(e.name + ": " + e.message);
			}
		}
		
		/**
		* Disconnect from the server.
		*/
		private function _disconnect():void 
		{
			_logger.info("... disconnecting");
			
			if(_nc!=null)
				_nc.close();			
		}
		
		/**
		 * Initiate devices: camera and microphone. Then attach it to the video.
		 */
		private function _initDevices():void
		{
			_cam = Camera.getCamera();
			_mic = Microphone.getMicrophone();
			
			if(_video==null) {
				_initVideo();
			}
			
			if (_cam == null) {
				_logger.warn('No camera available!');
			} else {
				_logger.info('Captured camera: ' + _cam.name);
				
				_cam.setQuality(0, 90);
				_cam.setMode(_width, _height, 30, true);
				_cam.setKeyFrameInterval(2);
				_cam.addEventListener(StatusEvent.STATUS, _cameraStatusHandler, false, 0, true); 
				
				_video.attachCamera(_cam);
				_streamManager.streamOut.attachCamera(_cam);
			}
			
			if (_mic == null) {
				_logger.warn('No microphone available!');
			} else {
				_logger.info('Captured microphone: ' + _mic.name);
				_mic.gain = 50;
				_streamManager.streamOut.attachAudio(_mic);
			}
			
			_initMetaData();
		}
		
		/**
		 * Initiate video
		 */
		private function _initVideo():void
		{			
			var nsOut = new NetStream(_nc);
			nsOut.client = this;			
			nsOut.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler, false, 0, true);
			nsOut.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError, false, 0, true);
			
			var nsIn = new NetStream(_nc);
			nsIn.client = this;
			nsIn.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler, false, 0, true);
			nsIn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError, false, 0, true);
			
			_streamManager = new StreamManager(nsOut, _streamName, _streamType);
			_streamManager.streamIn = nsIn;
			
			_video = new Video(_width, _height);
			_video.visible = true;
			_video.smoothing = true;
			_video.x = 0;
			_video.y = 0;			
			
			_videoPlayer = new Video(_width, _height);
			_videoPlayer.visible = false;
			_videoPlayer.smoothing = true;
			_videoPlayer.x = 0;
			_videoPlayer.y = 0;
			_videoPlayer.attachNetStream(_streamManager.streamIn);
		}
		
		/**
		 * Initiate metadata object for recorded videos
		 */
		private function _initMetaData():void
		{	
			var metadata = _streamManager.metaData;
			metadata.fps = _cam.fps;
			metadata.bandwith = _cam.bandwidth;
			metadata.height = _cam.height;
			metadata.width = _cam.width;
			metadata.keyFrameInterval = _cam.keyFrameInterval;
			metadata.copyright = this.copyright;
			_streamManager.metaData = metadata;
		}
		
		/**
		 * Add all external event listeners
		 */
		private function _addExternalEvents():void
		{
			ExternalEvents.listen(Protocol.SET_REMOTE_SERVER, setRemoteServer);
			ExternalEvents.listen(Protocol.SET_STREAM, setStreamName);
			ExternalEvents.listen(Protocol.SET_STREAM_TYPE, setStreamType);
			ExternalEvents.listen(Protocol.SET_RECORD_TIME, setRecordTime);
			ExternalEvents.listen(Protocol.SET_DEBUG, setDebug);
			ExternalEvents.listen(Protocol.GET_STREAM_URL, getStreamUrl);
			ExternalEvents.listen(Protocol.GET_IS_RECORDED, isRecordAvailable);
			ExternalEvents.listen(Protocol.START_RECORD, startRecord);
			ExternalEvents.listen(Protocol.STOP_RECORD, stopRecord);
			ExternalEvents.listen(Protocol.START_PLAY, startPlay);
			ExternalEvents.listen(Protocol.STOP_PLAY, stopPlay);
			ExternalEvents.listen(Protocol.CLOSE_APP, close);
		}
		
		/**
		 * Remove all external event listeners
		 */
		private function _removeExternalEvents():void
		{
			ExternalEvents.listen(Protocol.SET_REMOTE_SERVER, null);
			ExternalEvents.listen(Protocol.SET_STREAM, null);
			ExternalEvents.listen(Protocol.SET_STREAM_TYPE, null);
			ExternalEvents.listen(Protocol.SET_RECORD_TIME, null);
			ExternalEvents.listen(Protocol.SET_DEBUG, null);
			ExternalEvents.listen(Protocol.GET_STREAM_URL, null);
			ExternalEvents.listen(Protocol.GET_IS_RECORDED, null);
			ExternalEvents.listen(Protocol.START_RECORD, null);
			ExternalEvents.listen(Protocol.STOP_RECORD, null);
			ExternalEvents.listen(Protocol.START_PLAY, null);
			ExternalEvents.listen(Protocol.STOP_PLAY, null);
			ExternalEvents.listen(Protocol.CLOSE_APP, null);
		}
		
		/**
		 * Function to pre initialize recording
		 * to remove any delays during the real recording
		 */
		private function _preRecord():void
		{
			startRecord();
			stopRecord();
		}
		
		/**
		 * Handle events relating to the server connection.
		 * 
		 * @param event NetStatusEvent
		 */
		public function _netStatusHandler(event:NetStatusEvent):void 
		{
			if(_debug) {
				var status = "status";
				if(event.currentTarget!=_nc) {
					switch(event.currentTarget)
					{
						case _streamManager.streamOut:
							status = "nsOut";
							break;
						case _streamManager.streamIn:
							status = "nsIn";
							break;
					}
				}
				
				_logger.debug("["+status+"] connected is: " + _nc.connected);
				_logger.debug("["+status+"] event.info.code: " + event.info.code);
			}
			
			switch(event.info.code){
				case "NetConnection.Connect.Success":
					_initDevices();
					break;				
				case "NetStream.Record.NoAccess":
					stopRecord(false);
					_timer.stop();
					_timer.reset();
				case "NetStream.Play.Stop":
					stopPlay(false);
					_timer.stop();
					_timer.reset();
					break;
				case "NetStream.Play.Start":
					if(_stopFlag) {
						_streamManager.streamIn.pause();
						_stopFlag = false;
					}
					break;
				case "NetStream.Record.Start":
					_isRecordAvail = true;
					if(_isFirstPublish) {
						_streamManager.streamIn.play(_streamManager.streamName, 0, -1);
						_isFirstPublish = false;
						resumeBtn.enabled = true;
					}
					break;
				default: break;
			}
		}
		
		/**
		 * Handle events relating to the camera connection.
		 * 
		 * @param event StatusEvent
		 */
		private function _cameraStatusHandler(event:StatusEvent):void 
		{
			removeEventListener(StatusEvent.STATUS, _cameraStatusHandler);
			
			if (!_cam.muted) {
				if(_debug) _logger.debug("User clicked Accept.");
				_preRecord();
				addChildAt(_video, 0);
				addChildAt(_videoPlayer, 0);
			} else { 
				if(_debug) _logger.debug("User clicked Deny."); 
			} 
		}
		
		/**
		 * Handle events relating to asyncronius error with netStream.
		 * 
		 * @param event AsyncErrorEvent
		 */
		private function _onAsyncError(event:AsyncErrorEvent):void
		{
			_logger.error(event.text);
		}
		
		/**
		 * Handle events relating to progress loading of app.
		 * 
		 * @param event ProgressEvent
		 */
		private function _loading(e:ProgressEvent):void
		{  
			var loadedBytes:int = Math.round(e.target.bytesLoaded  / 1024);
			var totalBytes:int = Math.round(e.target.bytesTotal / 1024);
			var percent:int = int((e.target.bytesLoaded/e.target.bytesTotal )*100);  
			
			if(_debug) _logger.debug(percent+" % of application has been loaded: " + loadedBytes + " of " + totalBytes + " KB");
		}
		
		/**
		 * Handle events relating to compete loading of app.
		 * 
		 * @param event Event
		 */
		private function _loadComplete(e:Event):void  
		{
			_logger.info("... loaded");
			
			this.root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, _loading);  
			this.root.loaderInfo.removeEventListener(Event.COMPLETE, _loadComplete);			
			
			_width = this.root.loaderInfo.width;
			_height = this.root.loaderInfo.height;
			
			//Add Event listeners
			_addExternalEvents();
			recordBtn.addEventListener(MouseEvent.CLICK, _buttonClick, false, 0, true);
			resumeBtn.addEventListener(MouseEvent.CLICK, _buttonClick, false, 0, true);
			closeBtn.addEventListener(MouseEvent.CLICK, _buttonClick, false, 0, true);
			
			//Send JS event that AS3 was loaded
			ExternalEvents.call(Protocol.EVENT_INIT);
			
			//Add other function here
			_connect();
			timerTxt.text = NumberUtil.formatMinSecFromSec(_recordTimeLimit);
			resumeBtn.enabled = false;
		}
		
		/**
		 * Handle events relating to btn clicks.
		 * 
		 * @param event MouseEvent
		 */
		private function _buttonClick(event:MouseEvent):void 
		{
			switch(event.currentTarget)
			{
				case closeBtn:
					close();
					break;
				case recordBtn:					
					if(!_isRecording) {				
						startRecord();
						if(!_isFirstPublish)
							stopPlay(false);
					} else {
						stopRecord();
					}
					break;
				case resumeBtn:					
					if(!_isPlaying) {
						startPlay();
						stopRecord(false);
					} else {
						stopPlay();
					}
					break;
				default: break;
			}			
		}
		
		/**
		 * Handle events relating to timer counting.
		 * 
		 * @param event TimerEvent
		 */
		private function _onTimerEvent(event:TimerEvent):void
		{
			var time = 0;
			if(_isRecording) {
				time = _timer.currentCount * _timer.delay / 1000;
				timerTxt.text = NumberUtil.formatMinSecFromSec(_recordTimeLimit-time);
				
				if((_recordTimeLimit-time)<=0) {					
					stopRecord(false);
					_timer.stop();
					_timer.reset();
				}
			} else if(_isPlaying) {
				time = _timer.currentCount * _timer.delay / 1000;
				timerTxt.text = NumberUtil.formatMinSecFromSec(time);
			}
		}
		
		/**
		 * NetStream Client callback function onMetaData
		 * 
		 * @param info Object
		 */
		public function onMetaData(info:Object):void 
		{
			for (var prop in info) {
				trace("\t"+prop+":\t"+info[prop]);
			}
		}
		
		/**
		 * NetStream Client callback function onTimeCoordInfo
		 * 
		 * @param info Object
		 */
		public function onTimeCoordInfo(info:Object):void 
		{ 
			for (var prop in info) {
				trace("\t"+prop+":\t"+info[prop]);
			}
		}
		
		/**
		 * NetStream Client callback function onPlayStatus
		 * 
		 * @param info Object
		 */
		public function onPlayStatus(info:Object):void 
		{ 
			for (var prop in info) {
				trace("\t"+prop+":\t"+info[prop]);
			}
		}
	}
}












