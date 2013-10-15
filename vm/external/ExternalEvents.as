/**
 * File for ExternalEvents class
 *
 * @package   vm.external
 * @author    Denis Tatarnikov <tatarnikovda@gmail.com>
 */
package vm.external 
{
	import flash.external.ExternalInterface;
	
	/**
	 * ExternalEvents class
	 *
	 * @package  vm.external
	 * @author   Denis Tatarnikov <tatarnikovda@gmail.com>
	 */
	public class ExternalEvents 
	{	
		/**
		 * Call javascript function (@link event) with the given arguments (@link args).
		 * 
		 * @param event Event string to call
		 * @param args list of arguments separate by the comma
		 */
		public static function call(event:String, ... args):void 
		{
			try {
				if (ExternalEvents.available) {
					ExternalInterface.call(event, args);
				}
			}
			catch (error:Error) {
				trace("Exception occured in 'call': " + error.toString());
			}
		}
		
		/**
		 * Listen (@link event) from javascript and calls actionscript function (@link callback).
		 * 
		 * @param event Event string to listen
		 * @param callback Function to call in actionscript
		 */
		public static function listen(event:String, callback:Function):void 
		{
			try {
				if (ExternalEvents.available) {
					ExternalInterface.addCallback(event, callback);
				}
			}
			catch (error:Error) {
				trace("Exception occured in 'listen': " + error.toString());
			}
		}
		
		/**
		 * Returns if external interface is available
		 * 
		 * @return true if available, false - otherwise
		 */
		public static function get available():Boolean 
		{
			return ExternalInterface.available;
		}
	}
}