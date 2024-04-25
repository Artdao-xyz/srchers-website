// iosInnerHeight.js

/**
 * @module iosInnerHeight
 *
 * @description Get proper window.innerHeight from iOS devices,
 * excluding URL control and menu bar.
 *
 * @param {Object} navigatorObj - The navigator object (optional, defaults to global navigator).
 * @return {function} Callable function to retrieve the
 * cached `window.innerHeight` measurement, specific to the
 * device's current orientation.
 */
const iosInnerHeight = (navigatorObj = window.navigator) => {
	// Non-iOS browsers return window.innerHeight per usual.
	// No caching here since browsers can be resized, and setting
	// up resize-triggered cache invalidation is not in scope.
	/* istanbul ignore if  */
	if (!navigatorObj.userAgent.match(/iphone|ipod|ipad/i)) {
		/**
		 * Avoids conditional logic in the implementation
		 * @return {number} - window's innerHeight measurement in pixels
		 */
		return window.innerHeight;
	}

	// Store initial orientation
	const axis = Math.abs(window.orientation);
	// And hoist cached dimensions
	const dims = { w: 0, h: 0 };

	/**
	 * Creates an element with a height of 100vh since iOS accurately
	 * reports vp height (but not window.innerHeight). Then destroy it.
	 */
	const createRuler = () => {
		const ruler = document.createElement('div');

		ruler.style.position = 'fixed';
		ruler.style.height = '100vh';
		ruler.style.width = '0';
		ruler.style.top = '0';

		document.documentElement.appendChild(ruler);

		// Set cache conscientious of device orientation
		dims.w = axis === 90 ? ruler.offsetHeight : window.innerWidth;
		dims.h = axis === 90 ? window.innerWidth : ruler.offsetHeight;

		// Clean up after ourselves
		document.documentElement.removeChild(ruler);
	};

	// Measure once
	createRuler();

	/**
	 * Returns window's cached innerHeight measurement
	 * based on viewport height and device orientation
	 * @return {number} - window's innerHeight measurement in pixels
	 */
	return Math.abs(window.orientation) !== 90 ? dims.h : dims.w;
};

export default iosInnerHeight;
