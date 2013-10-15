/**
 * File for FirebugTarget class
 *
 * @package   vm.targets
 * @author    Denis Tatarnikov <tatarnikovda@gmail.com>
 */
package vm.targets
{
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	import vm.external.*;
	
	use namespace mx_internal;
	
	/**
	 * FirebugTarget class
	 *
	 * @package  vm.targets
	 * @author   Denis Tatarnikov <tatarnikovda@gmail.com>
	 */
	public class FirebugTarget extends LineFormattedTarget
	{
		public function FirebugTarget()
		{
			super();
		}
		
		mx_internal override function internalLog(message:String): void
		{
			trace(message);
			ExternalEvents.call(Protocol.LOGGING, message);
		}
	}
}