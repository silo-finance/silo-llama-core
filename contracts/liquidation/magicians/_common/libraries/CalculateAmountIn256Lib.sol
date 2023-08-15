// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../../interfaces/ICurvePoolLike256.sol";

/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
library CalculateAmountIn256Lib {
    struct InputWithNormalization {
        uint256 amountRequired;
        uint256 one;
        address pool;
        uint256 i;
        uint256 j;
        uint256 iDecimals;
        uint256 jDecimals;
    }

    error FailedNormalization();

    function amountIn256(
        uint256 _amountRequired,
        uint256 _one, // One coin based on the coin decimals
        address _pool,
        uint256 _i,
        uint256 _j
    )
        internal
        view
        returns (uint256 amountIn, uint256 amountOut)
    {
        ICurvePoolLike256 curvePool = ICurvePoolLike256(_pool);
        uint256 rate = curvePool.get_dy(_i, _j, _one);

        uint256 multiplied = _one * _amountRequired;
        // We have safe math while doing `one * _amountRequired`. Division should be fine.
        unchecked { amountIn = multiplied / rate; }

        // `get_dy` is an increasing function.
        // It should take ~ 1 - 6 iterations to `amountOut >= _amountRequired`.
        while (true) {
            amountOut = curvePool.get_dy(_i, _j, amountIn);

            if (amountOut >= _amountRequired) {
                return (amountIn, amountOut);
            }

            amountIn = _calcAmountIn(
                amountIn,
                _one,
                rate,
                _amountRequired,
                amountOut
            );
        }
    }

    function amountIn256WithNormalization(InputWithNormalization memory _input)
        internal
        view
        returns (uint256 amountIn, uint256 amountOut)
    {
        ICurvePoolLike256 curvePool = ICurvePoolLike256(_input.pool);
        uint256 dy = curvePool.get_dy(_input.i, _input.j, _input.one);
        // We do normalization of the rate as we will recive from the `get_dy` a value with `_jDecimals`
        uint256 rate = normalizeWithDecimals(dy, _input.iDecimals, _input.jDecimals);
        // Normalize `_input.amountRequired` to `_iDecimals` as we will use it
        // for calculation of the `amountIn` value of the `_tokenIn`
        uint256 amountRequired = normalizeWithDecimals(_input.amountRequired, _input.iDecimals, _input.jDecimals);
        uint256 multiplied = _input.one * amountRequired;
        // Zero value for amountIn is unacceptable.
        assert(multiplied >= rate); // Otherwise, we may get zero.
        // We have safe math while doing `one * amountRequired`. Division should be fine.
        unchecked { amountIn = multiplied / rate; }

        // `get_dy` is an increasing function.
        // It should take ~ 1 - 6 iterations to `amountOut >= amountRequired`.
        while (true) {
            amountOut = curvePool.get_dy(_input.i, _input.j, amountIn);
            uint256 amountOutNormalized = normalizeWithDecimals(amountOut, _input.iDecimals, _input.jDecimals);

            if (amountOutNormalized >= amountRequired) {
                return (amountIn, amountOut);
            }

            amountIn = _calcAmountIn(
                amountIn,
                _input.one,
                rate,
                amountRequired,
                amountOutNormalized
            );
        }
    }

    /// @dev Adjusts the given value to have different decimals
    function normalizeWithDecimals(
        uint256 _value,
        uint256 _toDecimals,
        uint256 _fromDecimals
    )
        internal
        pure
        returns (uint256)
    {
        if (_toDecimals == _fromDecimals) {
            return _value;
        } else if (_toDecimals < _fromDecimals) {
            uint256 devideOn;
            // It can be unchecked because of the condition `_toDecimals < _fromDecimals`.
            // We trust to `_fromDecimals` and `_toDecimals` they should not have large numbers.
            unchecked { devideOn = 10 ** (_fromDecimals - _toDecimals); }
            // Zero value after normalization is unacceptable.
            if (_value < devideOn) revert FailedNormalization();
            // Condition above make it safe
            unchecked { return _value / devideOn; }
        } else {
            uint256 decimalsDiff;
            // Because of the condition `_toDecimals < _fromDecimals` above,
            // we are safe as it guarantees that `_toDecimals` is > `_fromDecimals`
            unchecked { decimalsDiff = 10 ** (_toDecimals - _fromDecimals); }

            return _value * decimalsDiff;
        }
    }

    function _calcAmountIn(
        uint256 _amountIn,
        uint256 _one,
        uint256 _rate,
        uint256 _requiredAmountOut,
        uint256 _amountOutNormalized
    )
        private
        pure
        returns (uint256)
    {
        uint256 diff;
        // Because of the condition `amountOutNormalized >= _requiredAmountOut` in a calling function,
        // safe math is not required here.
        unchecked { diff = _requiredAmountOut - _amountOutNormalized; }
        // We may be stuck in a situation where a difference between
        // a `_requiredAmountOut` and `amountOutNormalized`
        // will be small and we will need to perform more steps.
        // This expression helps to escape the almost infinite loop.
        if (diff < 1e3) {
            // If the `amountIn` value is high the `get_dy` function will revert first
            unchecked { _amountIn += 1e3; }
        } else {
            // `one * diff` is safe as `diff` will be lower then the `_requiredAmountOut`
            // for which we have safe math while doing `ONE_... * _requiredAmountOut` in a calling function.
            unchecked { _amountIn += (_one * diff) / _rate; }
        }

        return _amountIn;
    }
}
