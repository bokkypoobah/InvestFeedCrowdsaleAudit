# Haltable

Source file [../contracts/Haltable.sol](../contracts/Haltable.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

import './Ownable.sol';

/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
// BK Ok
contract Haltable is Ownable {
  // BK Ok - Default to false
  bool public halted;

  // BK Ok
  modifier stopInEmergency {
    require(!halted);
    //if (halted) throw;
    _;
  }

  // BK Ok
  modifier onlyInEmergency {
    require(halted);
    //if (!halted) throw;
    _;
  }

  // called by the owner on emergency, triggers stopped state
  // BK Ok
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  // BK Ok
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}
```