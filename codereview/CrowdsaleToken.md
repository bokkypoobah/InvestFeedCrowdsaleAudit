# CrowdsaleToken

Source file [../contracts/CrowdsaleToken.sol](../contracts/CrowdsaleToken.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 4 Ok
import './StandardToken.sol';
import "./UpgradeableToken.sol";
import "./ReleasableToken.sol";
import "./MintableToken.sol";


/**
 * A crowdsaled token.
 *
 * An ERC-20 token designed specifically for crowdsales with investor protection and further development path.
 *
 * - The token transfer() is disabled until the crowdsale is over
 * - The token contract gives an opt-in upgrade path to a new contract
 * - The same token can be part of several crowdsales through approve() mechanism
 * - The token can be capped (supply set in the constructor) or uncapped (crowdsale contract can mint new tokens)
 *
 */
// BK Ok
contract CrowdsaleToken is ReleasableToken, MintableToken, UpgradeableToken {

  // BK Ok
  event UpdatedTokenInformation(string newName, string newSymbol);

  // BK Ok
  string public name;

  // BK Ok
  string public symbol;

  // BK Ok
  uint8 public decimals;

  /**
   * Construct the token.
   *
   * This token must be created through a team multisig wallet, so that it is owned by that wallet.
   *
   * @param _name Token name
   * @param _symbol Token symbol - should be all caps
   * @param _initialSupply How many tokens we start with
   * @param _decimals Number of decimal places
   * @param _mintable Are new tokens created over the crowdsale or do we distribute only the initial supply? Note that when the token becomes transferable the minting always ends.
   */
  // BK Ok - Constructor
  function CrowdsaleToken(string _name, string _symbol, uint _initialSupply, uint8 _decimals, bool _mintable)
    UpgradeableToken(msg.sender) {

    // Create any address, can be transferred
    // to team multisig via changeOwner(),
    // also remember to call setUpgradeMaster()
    // BK Ok - This should already be set by the Ownable constructor
    owner = msg.sender;

    // BK Next 2 Ok
    name = _name;
    symbol = _symbol;

    // BK Ok
    totalSupply = _initialSupply;

    // BK Ok
    decimals = _decimals;

    // Create initially all balance on the team multisig
    // BK Ok
    balances[owner] = totalSupply;

    // BK Ok
    if(totalSupply > 0) {
      // BK NOTE - StandardToken.Minted
      //         - Crowdsale minting calls the MintableToken.mint(...) and this generates the Transfer(0x0, account, amount) log event
      //           instead of this Minted log event. It does not matter in this case as the initial totalSupply should be 0
      Minted(owner, totalSupply);
    }

    // No more new supply allowed after the token creation
    // BK Ok - Mintable is set to true for this crowdsale
    if(!_mintable) {
      // BK Ok
      mintingFinished = true;
      // BK Ok
      require(totalSupply != 0);
      // if(totalSupply == 0) {
      //   throw; // Cannot create a token without supply and no minting
      // }
    }
  }

  /**
   * When token is released to be transferable, enforce no new tokens can be created.
   */
  // BK Ok - Only the release agent can call this
  function releaseTokenTransfer() public onlyReleaseAgent {
    // BK Ok - MintableToken.mintingFinished is set to true
    mintingFinished = true;
    // BK Ok - ReleasableToken.released is set to true
    super.releaseTokenTransfer();
  }

  /**
   * Allow upgrade agent functionality kick in only if the crowdsale was success.
   */
  // BK Ok - Can only upgrade if the tokens have been released
  function canUpgrade() public constant returns(bool) {
    return released && super.canUpgrade();
  }

  /**
   * Owner can update token information here
   */
  // BK Ok - Only owner can call this
  function setTokenInformation(string _name, string _symbol) onlyOwner {
    // BK Ok
    name = _name;
    // BK Ok
    symbol = _symbol;
    // BK Ok
    UpdatedTokenInformation(name, symbol);
  }

}
```