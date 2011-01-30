package gerrybeauregard
{
	/**
	 * Performs an in-place complex FFT.
	 *
	 * Released under the MIT License
	 *
	 * Copyright (c) 2010 Gerald T. Beauregard
	 *
	 * Permission is hereby granted, free of charge, to any person obtaining a copy
	 * of this software and associated documentation files (the "Software"), to
	 * deal in the Software without restriction, including without limitation the
	 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
	 * sell copies of the Software, and to permit persons to whom the Software is
	 * furnished to do so, subject to the following conditions:
	 *
	 * The above copyright notice and this permission notice shall be included in
	 * all copies or substantial portions of the Software.
	 *
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
	 * IN THE SOFTWARE.
	 */
	public class FFT
	{
		public static const FORWARD:Boolean = false;
		public static const INVERSE:Boolean = true;

		private var m_logN:uint = 0;			// log2 of FFT size
		private var m_N:uint = 0;				// FFT size
		private var m_invN:Number;				// Inverse of FFT length

		// Bit-reverse lookup table
		private var m_bitRevLen:uint;			// Length of the bit reverse table
		private var m_bitRevFrom:Vector.<uint>;	// "From" indices for swap
		private var m_bitRevTo:Vector.<uint>;	// "To" indices for swap

		/**
		 *
		 */
		public function FFT()
		{
		}

		/**
		 * Initialize class to perform FFT of specified size.
		 *
		 * @param	logN	Log2 of FFT length. e.g. for 512 pt FFT, logN = 9.
		 */
		public function init(
			logN:uint ):void
		{
			m_logN = logN
			m_N = 1 << m_logN;
			m_invN = 1.0/m_N;

			//	Create the bit-reverse table
			m_bitRevFrom = new Vector.<uint>;
			m_bitRevTo   = new Vector.<uint>;
			for ( var k:uint = 0; k < m_N; k++ )
			{
				var kRev:uint = BitReverse(k,logN);
				if (kRev > k)
				{
					m_bitRevFrom.push(k);
					m_bitRevTo.push(kRev);
				}
			}
			m_bitRevLen = m_bitRevFrom.length;
		}

		/**
		 * Performs in-place complex FFT.
		 *
		 * @param	xRe		Real part of input/output
		 * @param	xIm		Imaginary part of input/output
		 * @param	inverse	If true (INVERSE), do an inverse FFT
		 */
		public function run(
			xRe:Vector.<Number>,
			xIm:Vector.<Number>,
			inverse:Boolean = false ):void
		{
			var numFlies:uint = m_N >> 1;	// Number of butterflies per sub-FFT
			var span:uint = m_N >> 1;		// Width of the butterfly
			var spacing:uint = m_N;			// Distance between start of sub-FFTs
			var wIndexStep:uint = 1; 		// Increment for twiddle table index

			// For each stage of the FFT
			for ( var stage:uint = 0; stage < m_logN; ++stage )
			{
				// Compute a multiplier factor for the "twiddle factors".
				// The twiddle factors are complex unit vectors spaced at
				// regular angular intervals. The angle by which the twiddle
				// factor advances depends on the FFT stage. In many FFT
				// implementations the twiddle factors are cached, but because
				// vector lookup is relatively slow in ActionScript, it's just
				// as fast to compute them on the fly.
				var wAngleInc:Number = wIndexStep * 2.0*Math.PI/m_N;
				if ( inverse )
					wAngleInc *= -1;
				var wMulRe:Number = Math.cos(wAngleInc);
				var wMulIm:Number = Math.sin(wAngleInc);

				for ( var start:uint = 0; start < m_N; start += spacing )
				{
					var top:uint    = start;
					var bottom:uint = top + span;

					var wRe:Number = 1.0;
					var wIm:Number = 0.0;

					// For each butterfly in this stage
					for ( var flyCount:uint = 0; flyCount < numFlies; ++flyCount )
					{
						// Get the top & bottom values
						var xTopRe:Number = xRe[top];
						var xTopIm:Number = xIm[top];
						var xBotRe:Number = xRe[bottom];
						var xBotIm:Number = xIm[bottom];

						// Top branch of butterfly has addition
						xRe[top] = xTopRe + xBotRe;
						xIm[top] = xTopIm + xBotIm;

						// Bottom branch of butterly has subtraction,
						// followed by multiplication by twiddle factor
						xBotRe = xTopRe - xBotRe;
						xBotIm = xTopIm - xBotIm;
						xRe[bottom] = xBotRe*wRe - xBotIm*wIm;
						xIm[bottom] = xBotRe*wIm + xBotIm*wRe;

						// Update indices to the top & bottom of the butterfly
						++top;
						++bottom;

						// Update the twiddle factor, via complex multiply
						// by unit vector with the appropriate angle
						// (wRe + j wIm) = (wRe + j wIm) x (wMulRe + j wMulIm)
						var tRe:Number = wRe;
						wRe = wRe*wMulRe - wIm*wMulIm;
						wIm = tRe*wMulIm + wIm*wMulRe
					}
				}

				numFlies >>= 1; 	// Divide by 2 by right shift
				span >>= 1;
				spacing >>= 1;
				wIndexStep <<= 1;  	// Multiply by 2 by left shift
			}

			// The algorithm leaves the result in a scrambled order.
			// Do bit-reversal to unscramble the result.
			for ( var k:uint = 0; k < m_bitRevLen; k++ )
			{
				var brFr:uint = m_bitRevFrom[k];
				var brTo:uint = m_bitRevTo[k];
				var tempRe:Number = xRe[brTo];
				var tempIm:Number = xIm[brTo];
				xRe[brTo] = xRe[brFr];
				xIm[brTo] = xIm[brFr];
				xRe[brFr] = tempRe;
				xIm[brFr] = tempIm;
			}

			//	Divide everything by n for inverse
			if ( inverse )
			{
				for ( k = 0; k < m_N; k++ )
				{
					xRe[k] *= m_invN;
					xIm[k] *= m_invN;
				}
			}
		}

		/**
		 * Do bit reversal of specified number of places of an int
		 * For example, 1101 bit-reversed is 1011
		 *
		 * @param	x		Number to be bit-reverse.
		 * @param	numBits	Number of bits in the number.
		 */
		private function BitReverse(
			x:uint,
			numBits:uint):uint
		{
			var y:uint = 0;
			for ( var i:uint = 0; i < numBits; i++)
			{
				y <<= 1;
				y |= x & 0x0001;
				x >>= 1;
			}
			return y;
		}
	}
}
