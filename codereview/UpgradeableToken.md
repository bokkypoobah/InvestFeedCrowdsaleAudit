# UpgradeableToken

Source file [../contracts/UpgradeableToken.sol](../contracts/UpgradeableToken.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 3 Ok
import './ERC20.sol';
import './StandardToken.sol';
import "./UpgradeAgent.sol";

/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 */
contract UpgradeableToken is StandardToken {

  /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
  // BK Ok
  address public upgradeMaster;

  /** The next contract where the tokens will be migrated. */
  // BK Ok
  UpgradeAgent public upgradeAgent;

  /** How many tokens we have upgraded by now. */
  // BK Ok. Upgrade agent holds originalSupply
  uint256 public totalUpgraded;

  /**
   * Upgrade states.
   *
   * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
   * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
   * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
   * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
   *
   */
  // BK Ok
  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

  /**
   * Somebody has upgraded some of his tokens.
   */
  // BK OK
  event Upgrade(address indexed _from, address indexed _to, uint256 _value);

  /**
   * New upgrade agent available.
   */
  // BK Ok
  event UpgradeAgentSet(address agent);

  /**
   * Do not allow construction without upgrade master set.
   */
  // BK Ok - Constructor
  function UpgradeableToken(address _upgradeMaster) {
    // BK Ok
    upgradeMaster = _upgradeMaster;
  }

  /**
   * Allow the token holder to upgrade some of their tokens to a new contract.
   */
  // BK Ok - Account can upgrade it's balance from the current token contract into the new token contract balance
  function upgrade(uint256 value) public {
    // BK Ok
    UpgradeState state = getUpgradeState();
    // BK Ok - Ready to upgrade or currently upgrading
    require((state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading));
    // if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
    //   // Called in a bad state
    //   throw;
    // }

    // Validate input value.
    // BK Ok - Partial upgrades are possible
    if (value == 0) throw;

    // BK Ok - Deduct amount from this old token contract's account balances
    balances[msg.sender] = safeSub(balances[msg.sender],value);

    // Take tokens out from circulation
    // BK Ok - Deduct amount from this old token contract's totalSupply
    totalSupply = safeSub(totalSupply,value);
    // BK Ok - Keep track of amount that have been upgraded
    totalUpgraded = safeAdd(totalUpgraded,value);

    // Upgrade agent reissues the tokens
    // BK Ok - Add the amount to the new token contract's account balances and totalSupply
    upgradeAgent.upgradeFrom(msg.sender, value);
    // BK Ok - Log event
    Upgrade(msg.sender, upgradeAgent, value);
  }

  /**
   * Set an upgrade agent that handles
   */
  // BK Ok - Can only be called by the upgrade master
  function setUpgradeAgent(address agent) external {
    // BK Ok - Always true
    require(canUpgrade());
    // if(!canUpgrade()) {
    //   // The token is not yet in a state that we could think upgrading
    //   throw;
    // }

    // BK Ok - Just checking for 0x0
    require(agent != 0x0);
    //if (agent == 0x0) throw;
    // Only a master can designate the next agent
    // BK Ok - Only upgrade master can set the upgrade agent
    require(msg.sender == upgradeMaster);
    //if (msg.sender != upgradeMaster) throw;
    // Upgrade has already begun for an agent
    // BK Ok - Cannot set upgrade agent if there is already an upgrade agent in the process of upgrading
    require(getUpgradeState() != UpgradeState.Upgrading);
    //if (getUpgradeState() == UpgradeState.Upgrading) throw;

    // BK Ok - Set the upgrade agent
    upgradeAgent = UpgradeAgent(agent);

    // Bad interface
    // BK Ok - Check that the new upgrade agent contract is an upgrade agent contract
    require(upgradeAgent.isUpgradeAgent());
    //if(!upgradeAgent.isUpgradeAgent()) throw;
    // Make sure that token supplies match in source and target
    // BK Ok - Upgrade agent must have original supply set to the old contract totalSupply
    require(upgradeAgent.originalSupply() == totalSupply);
    //if (upgradeAgent.originalSupply() != totalSupply) throw;

    // BK Ok - Log event
    UpgradeAgentSet(upgradeAgent);
  }

  /**
   * Get the state of the token upgrade.
   */
  // BK Ok
  function getUpgradeState() public constant returns(UpgradeState) {
    // BK Ok - canUpgrade() is always true, so this state will never occur
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    // BK Ok - No upgrade agent set
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    // BK Ok - Upgrade agent set, but no tokens upgraded yet
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    // BK Ok - Upgrade agent set, and some tokens have been upgraded
    else return UpgradeState.Upgrading;
  }

  /**
   * Change the upgrade master.
   *
   * This allows us to set a new owner for the upgrade mechanism.
   */
  // BK NOTE - Current upgrade master can call this with an incorrect new upgrade master and prevent upgrades from ever being done
  //         - Cannot set new upgrade master to 0x0, but can always set to 0x1111...1111 or something like that to make this
  //           token contract trustless
  // BK Ok 
  function setUpgradeMaster(address master) public {
    // BK Ok
    require(master != 0x0);
    //if (master == 0x0) throw;
    // BK Ok - Only current upgrade master can change the upgrade master
    require(msg.sender == upgradeMaster);
    //if (msg.sender != upgradeMaster) throw;
    // BK Ok - Set new upgrade master
    upgradeMaster = master;
  }

  /**
   * Child contract can enable to provide the condition when the upgrade can begun.
   */
  // BK Ok - Always true
  function canUpgrade() public constant returns(bool) {
     // BK Ok 
     return true;
  }

}
```