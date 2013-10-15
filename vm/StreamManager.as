package vm
{
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.net.NetStream;
	
	import vm.utils.ArrayUtil;

	public class StreamManager
	{
		public static const TYPE_FLV:String = "flv";
		public static const TYPE_MP4:String = "mp4";
		public static const TYPE_F4V:String = "f4v";
		
		private var _streamType:String;
		private var _streamName:String;
		private var _streamOut:NetStream;
		private var _streamIn:NetStream;
		
		private var _metaData:Object = new Object();
		private var _h264Settings:H264VideoStreamSettings;
		
		/**
		 * Constructor
		 * 
		 * @param name Stream name
		 * @param type Stream type. Default to TYPE_FLV
		 */
		public function StreamManager(streamOut:NetStream, name:String, type:String=TYPE_FLV)
		{
			_streamOut = streamOut;
			_streamName = name;
			this.streamType = type;
		}
		
		/**
		 * Gets stream name, prepared for publish
		 */
		public function get streamName():String
		{
			var name:String;
			switch(_streamType) 
			{
				case TYPE_FLV:
					name=_streamName;
					break;
				case TYPE_MP4:
					name=_streamType + ":" + _streamName + "." + _streamType;
					break;
				case TYPE_F4V:
					name="mp4:" + _streamName + "." + _streamType;
					break;
				default:
					name=_streamName;
					break;
			}
			
			if(_streamType == TYPE_MP4 || _streamType == TYPE_F4V) {
				_h264Settings = new H264VideoStreamSettings()
				_h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3);
				_streamOut.videoStreamSettings = _h264Settings;
				
				_metaData = new Object();
				_metaData.codec = _streamOut.videoStreamSettings.codec;
				_metaData.profile = _h264Settings.profile;
				_metaData.level = _h264Settings.level;
			}
			
			return name;
		}
		
		/**
		 * Sets stream name
		 */
		public function set streamName(value:String):void
		{
			_streamName = value;
		}
		
		/**
		 * Gets stream name, prepared for download
		 */
		public function get streamRawName():String
		{			
			return _streamName + "." + _streamType;
		}
		
		/**
		 * Sets stream type
		 */
		public function set streamType(value:String):void 
		{
			if(!ArrayUtil.inArray(value, this.streamTypes)) return;
			_streamType = value;
		}
		
		/**
		 * Gets stream type
		 */
		public function get streamType():String 
		{
			return _streamType;
		}
		
		/**
		 * Returns array of all available types
		 */
		public function get streamTypes():Array
		{
			return new Array(
				TYPE_FLV,
				TYPE_MP4
			);
		}
		
		/**
		 * Gets stream metadata
		 */
		public function get metaData():Object
		{			
			return _metaData;
		}
		
		/**
		 * Sets stream metadata
		 */
		public function set metaData(value:Object):void
		{			
			_metaData = value;
		}
		
		/**
		 * Gets net stream out
		 */
		public function get streamOut():NetStream
		{			
			return _streamOut;
		}
		
		/**
		 * Sets net stream out
		 */
		public function set streamOut(value:NetStream):void
		{			
			_streamOut = value;
		}
		
		/**
		 * Gets net stream in
		 */
		public function get streamIn():NetStream
		{		
			return _streamIn;
		}
		
		/**
		 * Sets net stream in
		 */
		public function set streamIn(value:NetStream):void
		{			
			_streamIn = value;
		}
	}
}