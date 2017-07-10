# MintedEthCappedCrowdsale

Source file [../contracts/MintedEthCappedCrowdsale.sol](../contracts/MintedEthCappedCrowdsale.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 2 Ok
import "./Crowdsale.sol";
import "./MintableToken.sol";

/**
 * ICO crowdsale contract that is capped by amout of ETH.
 *
 * - Tokens are dynamically created during the crowdsale
 *
 *
 */
// BK Ok
contract MintedEthCappedCrowdsale is Crowdsale {

  /* Maximum amount of wei this crowdsale can raise. */
  // BK Ok
  uint public weiCap;

  // BK Ok Constructor
  function MintedEthCappedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _weiCap) Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal) {
    // BK Ok
    weiCap = _weiCap;
  }

  /**
   * Called from invest() to confirm if the curret investment does not break our cap rule.
   */
  // BK Ok
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    // BK Ok
    return weiRaisedTotal > weiCap;
  }

  // BK Ok
  function isCrowdsaleFull() public constant returns (bool) {
    // BK Ok
    return weiRaised >= weiCap;
  }

  /**
   * Dynamically create tokens and assign them to the investor.
   */
  // BK Ok
  function assignTokens(address receiver, uint tokenAmount) private {
    // BK Ok
    MintableToken mintableToken = MintableToken(token);
    // BK Ok
    mintableToken.mint(receiver, tokenAmount);
  }
}
```