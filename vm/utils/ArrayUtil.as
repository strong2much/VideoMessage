/**
 * File for ArrayUtil class
 *
 * @package   vm.utils
 * @author    Denis Tatarnikov <tatarnikovda@gmail.com>
 */
package vm.utils
{
	/**
	 * ArrayUtil class
	 *
	 * @package  vm.utils
	 * @author   Denis Tatarnikov <tatarnikovda@gmail.com>
	 */
	public class ArrayUtil
	{
		/**
		 * Checks if a value exists in an array
		 * 
		 * @param needle The searched value
		 * @param haystack The array to check
		 */
		public static function inArray(needle:*, haystack:Array):Boolean
		{
			var itemIndex:int = haystack.indexOf(needle);
			return ( itemIndex < 0 ) ? false : true;
		}
	}
}