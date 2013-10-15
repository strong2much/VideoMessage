/**
 * File for NumberUtil class
 *
 * @package   vm.utils
 * @author    Denis Tatarnikov <tatarnikovda@gmail.com>
 */
package vm.utils
{
	/**
	 * NumberUtil class
	 *
	 * @package  vm.utils
	 * @author   Denis Tatarnikov <tatarnikovda@gmail.com>
	 */
	public class NumberUtil
	{

		static public function minutes(sec:Number):int
		{
			return Math.floor(sec/60);
		}
		
		static public function seconds(milisec:Number):int
		{
			return Math.floor(milisec/1000);
		}
		
		static public function formatMinSecFromSec(time:int):String
		{
			var min:int = NumberUtil.minutes(time);
			var sec:int = Math.floor(time-min*60);
			var minStr:String = '' + min;
			var secStr:String = '' + sec;
			
			if(min<10) minStr = "0" + min;
			if(sec<10) secStr = "0" + sec;
			
			var format:String = minStr+':'+secStr;
			
			return format;
		}
		
		static public function formatMinSecFromMilisec(time:int):String
		{
			var min:int = NumberUtil.minutes(NumberUtil.seconds(time));
			var sec:int = Math.floor(NumberUtil.seconds(time)-min*60);
			var minStr:String = '' + min;
			var secStr:String = '' + sec;
			
			if(min<10) minStr = "0" + min;
			if(sec<10) secStr = "0" + sec;
			
			var format:String = minStr+':'+secStr;
			
			return format;
		}
	}

}