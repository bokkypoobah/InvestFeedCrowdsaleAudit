# BonusFinalizeAgent

Source file [../contracts/BonusFinalizeAgent.sol](../contracts/BonusFinalizeAgent.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 3 Ok
import "./Crowdsale.sol";
import "./CrowdsaleToken.sol";
import "./SafeMathLib.sol";

/**
 * At the end of the successful crowdsale allocate % bonus of tokens to the team.
 *
 * Unlock tokens.
 *
 * BonusAllocationFinal must be set as the minting agent for the MintableToken.
 *
 */
contract BonusFinalizeAgent is FinalizeAgent, SafeMathLib {

  // BK Ok
  CrowdsaleToken public token;
  // BK Ok
  Crowdsale public crowdsale;

  /** Total percent of tokens minted to the team at the end of the sale as base points (0.0001) */
  // BK Ok
  uint public totalMembers;
  // BK Ok
  uint public allocatedBonus;
  // BK Ok
  mapping (address=>uint) bonusOf;
  /** Where we move the tokens at the end of the sale. */
  // BK Ok
  address[] public teamAddresses;


  // BK Ok
  function BonusFinalizeAgent(CrowdsaleToken _token, Crowdsale _crowdsale, uint[] _bonusBasePoints, address[] _teamAddresses) {
    // BK Ok
    token = _token;
    // BK Ok
    crowdsale = _crowdsale;

    //crowdsale address must not be 0
    // BK Ok
    require(address(crowdsale) != 0);

    //bonus & team address array size must match
    // BK Ok
    require(_bonusBasePoints.length == _teamAddresses.length);

    // BK Ok
    totalMembers = _teamAddresses.length;
    // BK Ok
    teamAddresses = _teamAddresses;
    
    //if any of the bonus is 0 throw
    // otherwise sum it up in totalAllocatedBonus
    // BK Ok
    for (uint i=0;i<totalMembers;i++){
      // BK Ok
      require(_bonusBasePoints[i] != 0);
      //if(_bonusBasePoints[i] == 0) throw;
    }

    //if any of the address is 0 or invalid throw
    //otherwise initialize the bonusOf array
    // BK Ok
    for (uint j=0;j<totalMembers;j++){
      // BK Ok
      require(_teamAddresses[j] != 0);
      //if(_teamAddresses[j] == 0) throw;
      // BK Ok
      bonusOf[_teamAddresses[j]] = _bonusBasePoints[j];
    }
  }

  /* Can we run finalize properly */
  // BK Ok
  function isSane() public constant returns (bool) {
    // BK Ok
    return (token.mintAgents(address(this)) == true) && (token.releaseAgent() == address(this));
  }

  /** Called once by crowdsale finalize() if the sale was success. */
  // BK Ok
  function finalizeCrowdsale() {

    // if finalized is not being called from the crowdsale 
    // contract then throw
    // BK Ok
    require(msg.sender == address(crowdsale));

    // if(msg.sender != address(crowdsale)) {
    //   throw;
    // }

    // get the total sold tokens count.
    // BK Ok
    uint tokensSold = crowdsale.tokensSold();

    // BK Ok
    for (uint i=0;i<totalMembers;i++){
      // BK Ok
      allocatedBonus = safeMul(tokensSold, bonusOf[teamAddresses[i]]) / 10000;
      // move tokens to the team multisig wallet
      // BK Ok
      token.mint(teamAddresses[i], allocatedBonus);
    }

    // Make token transferable
    // realease them in the wild
    // Hell yeah!!! we did it.
    // BK Ok
    token.releaseTokenTransfer();
  }

}
```