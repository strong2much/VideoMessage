/**
 * File for Protocol class
 *
 * @package   vm.external
 * @author    Denis Tatarnikov <tatarnikovda@gmail.com>
 */
package vm.external 
{
	/**
	 * Protocol class
	 *
	 * @package  vm.external
	 * @author   Denis Tatarnikov <tatarnikovda@gmail.com>
	 */
	public class Protocol 
	{
		////////////////////////////////////////
		// Calls from flash
		////////////////////////////////////////
		
		public static const EVENT_INIT:String = "VM.onInit";
		public static const EVENT_CLOSE:String = "VM.onClose";
		
		public static const LOGGING: String = "console.log";
		
		////////////////////////////////////////
		// Calls to flash
		////////////////////////////////////////
		
		public static const SET_REMOTE_SERVER:String = "setRemoteServer";
		public static const SET_STREAM:String = "setStream";
		public static const SET_STREAM_TYPE:String = "setStreamType";
		public static const SET_RECORD_TIME:String = "setRecordTime";
		public static const SET_DEBUG:String = "setDebug";
		public static const GET_STREAM_URL:String = "getStreamUrl";
		public static const GET_IS_RECORDED:String = "isRecordAvailable";
		public static const START_RECORD:String = "startRecord";
		public static const STOP_RECORD:String = "stopRecord";
		public static const START_PLAY:String = "startPlay";
		public static const STOP_PLAY:String = "stopPlay";
		public static const CLOSE_APP:String = "close";
		
	}
}