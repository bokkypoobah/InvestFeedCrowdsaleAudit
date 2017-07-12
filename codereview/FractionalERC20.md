# FractionalERC20

Source file [../contracts/FractionalERC20.sol](../contracts/FractionalERC20.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
import './ERC20.sol';

/**
 * A token that defines fractional units as decimals.
 */
// BK Ok
contract FractionalERC20 is ERC20 {
  // BK Ok
  uint8 public decimals;
}
```