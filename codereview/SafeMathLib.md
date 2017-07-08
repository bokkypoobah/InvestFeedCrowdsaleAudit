# SafeMathLib

Source file [../contracts/SafeMathLib.sol](../contracts/SafeMathLib.sol)

NOTE: The latest version of OpenZeppelin's [SafeMath](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol)
is implemented as a library, and the functions have been renamed.

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
contract SafeMathLib {
  // BK Ok
  function safeMul(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  // BK Ok
  function safeSub(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a - b;
  }

  // BK Ok
  function safeAdd(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }
}
```