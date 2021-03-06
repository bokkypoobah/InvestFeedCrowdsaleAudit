# Crowdsale

Source file [../contracts/Crowdsale.sol](../contracts/Crowdsale.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 5 Ok
import "./SafeMathLib.sol";
import "./Haltable.sol";
import "./PricingStrategy.sol";
import "./FinalizeAgent.sol";
import "./FractionalERC20.sol";


/**
 * Abstract base contract for token sales.
 *
 * Handle
 * - start and end dates
 * - accepting investments
 * - minimum funding goal and refund
 * - various statistics during the crowdfund
 * - different pricing strategies
 * - different investment policies (require server side customer id, allow only whitelisted addresses)
 *
 */
// BK Ok
contract Crowdsale is Haltable, SafeMathLib {

  /* Max investment count when we are still allowed to change the multisig address */
  // BK Ok
  uint public MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE = 5;

  /* The token we are selling */
  // BK Ok
  FractionalERC20 public token;

  /* How we are going to price our offering */
  // BK Ok
  PricingStrategy public pricingStrategy;

  /* Post-success callback */
  // BK Ok
  FinalizeAgent public finalizeAgent;

  /* tokens will be transfered from this address */
  // BK Ok
  address public multisigWallet;

  /* if the funding goal is not reached, investors may withdraw their funds */
  // BK Ok
  uint public minimumFundingGoal;

  /* the UNIX timestamp start date of the crowdsale */
  // BK Ok
  uint public startsAt;

  /* the UNIX timestamp end date of the crowdsale */
  // BK Ok
  uint public endsAt;

  /* the number of tokens already sold through this contract*/
  // BK Ok
  uint public tokensSold = 0;

  /* How many wei of funding we have raised */
  // BK Ok
  uint public weiRaised = 0;

  /* How many distinct addresses have invested */
  // BK Ok
  uint public investorCount = 0;

  /* How much wei we have returned back to the contract after a failed crowdfund. */
  // BK Ok
  uint public loadedRefund = 0;

  /* How much wei we have given back to investors.*/
  // BK Ok
  uint public weiRefunded = 0;

  /* Has this crowdsale been finalized */
  // BK Ok
  bool public finalized;

  /* Do we need to have unique contributor id for each customer */
  // BK Ok
  bool public requireCustomerId;

  /**
    * Do we verify that contributor has been cleared on the server side (accredited investors only).
    * This method was first used in FirstBlood crowdsale to ensure all contributors have accepted terms on sale (on the web).
    */
  // BK Ok
  bool public requiredSignedAddress;

  /* Server side address that signed allowed contributors (Ethereum addresses) that can participate the crowdsale */
  // BK Ok
  address public signerAddress;

  /** How much ETH each address has invested to this crowdsale */
  // BK Ok
  mapping (address => uint256) public investedAmountOf;

  /** How much tokens this crowdsale has credited for each investor address */
  // BK Ok
  mapping (address => uint256) public tokenAmountOf;

  /** Addresses that are allowed to invest even before ICO offical opens. For testing, for ICO partners, etc. */
  // BK Ok
  mapping (address => bool) public earlyParticipantWhitelist;

  /** This is for manul testing for the interaction from owner wallet. You can set it to any value and inspect this in blockchain explorer to see that crowdsale interaction works. */
  // BK NOTE - This variable is unused and redundant
  uint public ownerTestValue;

  /** State machine
   *
   * - Preparing: All contract initialization calls and variables have not been set yet
   * - Prefunding: We have not passed start time yet
   * - Funding: Active crowdsale
   * - Success: Minimum funding goal reached
   * - Failure: Minimum funding goal not reached before ending time
   * - Finalized: The finalized has been called and succesfully executed
   * - Refunding: Refunds are loaded on the contract for reclaim.
   */
  // BK Ok
  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  // A new investment was made
  // BK Ok
  event Invested(address investor, uint weiAmount, uint tokenAmount, uint128 customerId);

  // Refund was processed for a contributor
  // BK Ok
  event Refund(address investor, uint weiAmount);

  // The rules were changed what kind of investments we accept
  // BK Ok
  event InvestmentPolicyChanged(bool requireCustomerId, bool requiredSignedAddress, address signerAddress);

  // Address early participation whitelist status changed
  // BK Ok
  event Whitelisted(address addr, bool status);

  // Crowdsale end time has been changed
  // BK Ok
  event EndsAtChanged(uint endsAt);

  // BK Ok
  function Crowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal) {

    // BK Ok - This is unnecessary as Haltable() -> Ownable() will initialise the owner to msg.sender
    owner = msg.sender;

    // BK Ok
    token = FractionalERC20(_token);

    // BK Ok
    setPricingStrategy(_pricingStrategy);

    // BK Ok
    multisigWallet = _multisigWallet;
    require(multisigWallet != 0);
    // if(multisigWallet == 0) {
    //     throw;
    // }

    // BK Ok
    require(_start != 0);
    // if(_start == 0) {
    //     throw;
    // }

    // BK Ok
    startsAt = _start;

    // BK Ok
    require(_end != 0);
    // if(_end == 0) {
    //     throw;
    // }

    // BK Ok
    endsAt = _end;

    // Don't mess the dates
    // BK Ok
    require(startsAt < endsAt);
    // if(startsAt >= endsAt) {
    //     throw;
    // }

    // Minimum funding goal can be zero
    / BK Ok
    minimumFundingGoal = _minimumFundingGoal;
  }

  /**
   * Don't expect to just send in money and get tokens.
   */
  // BK Ok - Not using default function to receive ethers
  function() payable {
    throw;
  }

  /**
   * Make an investment.
   *
   * Crowdsale must be running for one to invest.
   * We must have not pressed the emergency brake.
   *
   * @param receiver The Ethereum address who receives the tokens
   * @param customerId (optional) UUID v4 to track the successful payments on the server side
   *
   */
  // BK Ok - Anyone can call this via another public function, but not when halted
  function investInternal(address receiver, uint128 customerId) stopInEmergency private {

    // Determine if it's a good time to accept investment from this participant
    // BK Ok
    if(getState() == State.PreFunding) {
      // Are we whitelisted for early deposit
      // BK Ok
      require(earlyParticipantWhitelist[receiver]);
      // if(!earlyParticipantWhitelist[receiver]) {
      //   throw;
      // }
    // BK Ok
    } else if(getState() == State.Funding) {
      // Retail participants can only come in when the crowdsale is running
      // pass
    } else {
      // Unwanted state
      throw;
    }

    // BK Ok
    uint weiAmount = msg.value;
    // BK Ok
    uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised, tokensSold, msg.sender, token.decimals());

    // BK Ok
    require(tokenAmount != 0);
    // if(tokenAmount == 0) {
    //   // Dust transaction
    //   throw;
    // }

    // BK Ok
    if(investedAmountOf[receiver] == 0) {
       // A new investor
       // BK Ok
       investorCount++;
    }

    // Update investor
    // BK Ok
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver],weiAmount);
    // BK Ok
    tokenAmountOf[receiver] = safeAdd(tokenAmountOf[receiver],tokenAmount);

    // Update totals
    // BK Ok
    weiRaised = safeAdd(weiRaised,weiAmount);
    // BK Ok
    tokensSold = safeAdd(tokensSold,tokenAmount);

    // Check that we did not bust the cap
    // BK Ok
    require(!isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold));
    // if(isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold)) {
    //   throw;
    // }

    // BK Ok
    assignTokens(receiver, tokenAmount);

    // Pocket the money
    // BK Ok
    if(!multisigWallet.send(weiAmount)) throw;

    // Tell us invest was success
    // BK Ok
    Invested(receiver, weiAmount, tokenAmount, customerId);
  }

  /**
   * Preallocate tokens for the early investors.
   *
   * Preallocated tokens have been sold before the actual crowdsale opens.
   * This function mints the tokens and moves the crowdsale needle.
   *
   * Investor count is not handled; it is assumed this goes for multiple investors
   * and the token distribution happens outside the smart contract flow.
   *
   * No money is exchanged, as the crowdsale team already have received the payment.
   *
   * @param fullTokens tokens as full tokens - decimal places added internally
   * @param weiPrice Price of a single full token in wei
   *
   */
  // BK NOTE - You cannot add 10.12345678 tokens using this function, as only `10` can be specified
  //         - This function can be executed at any time (before, during and after the crowdsale period) before finalisation
  //           instead of just being available before the crowdsale starts
  // BK Ok - Only owner
  function preallocate(address receiver, uint fullTokens, uint weiPrice) public onlyOwner {

    // BK Next 2 Ok. No safeMul, but contract owner inputs the data
    uint tokenAmount = fullTokens * 10**uint(token.decimals());
    uint weiAmount = weiPrice * fullTokens; // This can be also 0, we give out tokens for free

    // BK Next 2 Ok
    weiRaised = safeAdd(weiRaised,weiAmount);
    tokensSold = safeAdd(tokensSold,tokenAmount);

    // BK Next 2 Ok
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver],weiAmount);
    tokenAmountOf[receiver] = safeAdd(tokenAmountOf[receiver],tokenAmount);

    // BK Ok
    assignTokens(receiver, tokenAmount);

    // Tell us invest was success
    // BK Ok
    Invested(receiver, weiAmount, tokenAmount, 0);
  }

  /**
   * Allow anonymous contributions to this crowdsale.
   */
  // function investWithSignedAddress(address addr, uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {
  //    bytes32 hash = sha256(addr);
  //    if (ecrecover(hash, v, r, s) != signerAddress) throw;
  //    require(customerId != 0);
  //    //if(customerId == 0) throw;  // UUIDv4 sanity check
  //    investInternal(addr, customerId);
  // }

  /**
   * Track who is the customer making the payment so we can send thank you email.
   */
  // BK Ok. Anyone can execute this
  function investWithCustomerId(address addr, uint128 customerId) public payable {
    // BK Ok
    require(!requiredSignedAddress);
    //if(requiredSignedAddress) throw; // Crowdsale allows only server-side signed participants
    
    // BK Ok
    require(customerId != 0);
    //if(customerId == 0) throw;  // UUIDv4 sanity check
    // BK Ok
    investInternal(addr, customerId);
  }

  /**
   * Allow anonymous contributions to this crowdsale.
   */
  // BK Ok. Anyone can execute this
  function invest(address addr) public payable {
    // BK Ok
    require(!requireCustomerId);
    //if(requireCustomerId) throw; // Crowdsale needs to track partipants for thank you email

    // BK Ok
    require(!requiredSignedAddress);
    //if(requiredSignedAddress) throw; // Crowdsale allows only server-side signed participants
    // BK Ok
    investInternal(addr, 0);
  }

  /**
   * Invest to tokens, recognize the payer and clear his address.
   *
   */
  
  // function buyWithSignedAddress(uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {
  //   investWithSignedAddress(msg.sender, customerId, v, r, s);
  // }

  /**
   * Invest to tokens, recognize the payer.
   *
   */
  // BK Ok
  function buyWithCustomerId(uint128 customerId) public payable {
    // BK Ok
    investWithCustomerId(msg.sender, customerId);
  }

  /**
   * The basic entry point to participate the crowdsale process.
   *
   * Pay for funding, get invested tokens back in the sender address.
   */
  // BK Ok
  function buy() public payable {
    // BK Ok
    invest(msg.sender);
  }

  /**
   * Finalize a succcesful crowdsale.
   *
   * The owner can triggre a call the contract that provides post-crowdsale actions, like releasing the tokens.
   */
  // BK Ok - Only owner, when not halted
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {

    // Already finalized
    // BK Ok - Can only run once
    require(!finalized);
    // if(finalized) {
    //   throw;
    // }

    // Finalizing is optional. We only call it if we are given a finalizing agent.
    // BK Ok
    if(address(finalizeAgent) != 0) {
      // BK Ok
      finalizeAgent.finalizeCrowdsale();
    }

    // BK Ok
    finalized = true;
  }

  /**
   * Allow to (re)set finalize agent.
   *
   * Design choice: no state restrictions on setting this, so that we can fix fat finger mistakes.
   */
  // BK Ok - Only owner, can execute at any time
  function setFinalizeAgent(FinalizeAgent addr) onlyOwner {
    // BK Ok
    finalizeAgent = addr;

    // Don't allow setting bad agent
    // BK Ok
    require(finalizeAgent.isFinalizeAgent());
    // if(!finalizeAgent.isFinalizeAgent()) {
    //   throw;
    // }
  }

  /**
   * Set policy do we need to have server-side customer ids for the investments.
   *
   */
  // BK Ok - Only owner, can execute at any time
  function setRequireCustomerId(bool value) onlyOwner {
    // BK Ok
    requireCustomerId = value;
    // BK Ok
    InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
  }

  /**
   * Set policy if all investors must be cleared on the server side first.
   *
   * This is e.g. for the accredited investor clearing.
   *
   */
  // function setRequireSignedAddress(bool value, address _signerAddress) onlyOwner {
  //   requiredSignedAddress = value;
  //   signerAddress = _signerAddress;
  //   InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
  // }

  /**
   * Allow addresses to do early participation.
   *
   * TODO: Fix spelling error in the name
   */
  // BK Ok - Only owner, anytime. But only applicable to contributions before the public crowdsale period 
  function setEarlyParicipantWhitelist(address addr, bool status) onlyOwner {
    // BK Ok
    earlyParticipantWhitelist[addr] = status;
    // BK Ok - Log event
    Whitelisted(addr, status);
  }

  /**
   * Allow crowdsale owner to close early or extend the crowdsale.
   *
   * This is useful e.g. for a manual soft cap implementation:
   * - after X amount is reached determine manual closing
   *
   * This may put the crowdsale to an invalid state,
   * but we trust owners know what they are doing.
   *
   */
  // BK NOTE - Crowdsale end date can be changed by the owner at any point during the crowdsale, to a time later than when the change is made
  //           The `EndsAtChanged(...)` event is logged
  // BK Ok - Only owner
  function setEndsAt(uint time) onlyOwner {
    // BK Ok - Can only update to a future time
    if(now > time) {
      throw; // Don't change past
    }
    // BK Ok
    endsAt = time;
    // BK Ok - Log event
    EndsAtChanged(endsAt);
  }

  /**
   * Allow to (re)set pricing strategy.
   *
   * Design choice: no state restrictions on the set, so that we can fix fat finger mistakes.
   */
  // BK NOTE - Pricing strategy can be changed by the owner at any point during the crowdsale
  //           A change can only be detected by looking for this change transaction, and the ETH to token rate changes
  // BK Ok
  function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {
    // BK Ok
    pricingStrategy = _pricingStrategy;

    // Don't allow setting bad agent
    // BK Ok
    require(pricingStrategy.isPricingStrategy());
    // if(!pricingStrategy.isPricingStrategy()) {
    //   throw;
    // }
  }

  /**
   * Allow to change the team multisig address in the case of emergency.
   *
   * This allows to save a deployed crowdsale wallet in the case the crowdsale has not yet begun
   * (we have done only few test transactions). After the crowdsale is going
   * then multisig address stays locked for the safety reasons.
   */
  // BK Ok - Only owner can change the multisig address
  function setMultisig(address addr) public onlyOwner {

    // Change
    // BK Ok - Cannot have more than 5 investors and still change the multisig address
    if(investorCount > MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE) {
      throw;
    }

    // BK Ok
    multisigWallet = addr;
  }

  /**
   * Allow load refunds back on the contract for the refunding.
   *
   * The team can transfer the funds back on the smart contract in the case the minimum goal was not reached..
   */
  // BK NOTE - This crowdsale contract moves all investor contributions into a multisig. If the crowdsale does not meet the minimum goal,
  //           investors must claim their refunds. For the crowdsale contract to switch to State.Refund mode, the crowdsale multisig funds
  //           must be moved back into the crowdsale contract with this function.
  //           This will be a safer crowdsale contract as the funds being raised is not sitting in a little used often customised contract
  //           compared to the widely used multisig wallets.
  //           However, investors will need to trust that the crowdsale team will move the funds back into the crowdsale contract for 
  //           refunds to become active.
  // BK Ok - Anyone can execute this function, payable
  function loadRefund() public payable inState(State.Failure) {
    // BK Ok
    require(msg.value != 0);
    //if(msg.value == 0) throw;
    // BK Ok - Funds can be moved in portions, but refunds will only be active when all the original funds are moved back into the crowdsale contract
    loadedRefund = safeAdd(loadedRefund,msg.value);
  }

  /**
   * Investors can claim refund.
   */
  // BK NOTE - The refund mode will only become active when all crowdsale contribution ethers are moved from the multisig back into the 
  //           crowdsale contract.
  // BK Ok
  function refund() public inState(State.Refunding) {
    // BK Ok
    uint256 weiValue = investedAmountOf[msg.sender];
    // BK Ok - Non zero refunds due
    require(weiValue != 0);
    //if (weiValue == 0) throw;
    // BK NOTE - Original amounts contributed in one or more contribution transactions
    //         - `preallocate(...)` entries can also withdraw their refunds using this function 
    // BK Ok
    investedAmountOf[msg.sender] = 0;
    // BK Ok - Keep a tally
    weiRefunded = safeAdd(weiRefunded,weiValue);
    // BK Ok - Log an event
    Refund(msg.sender, weiValue);
    // BK Ok
    if (!msg.sender.send(weiValue)) throw;
  }

  /**
   * @return true if the crowdsale has raised enough money to be a succes
   */
  // BK Ok
  function isMinimumGoalReached() public constant returns (bool reached) {
    // BK Ok
    return weiRaised >= minimumFundingGoal;
  }

  /**
   * Check if the contract relationship looks good.
   */
  // BK NOTE - This function is unused and redundant, and not used in any other TokenMarket contracts
  // BK Ok
  function isFinalizerSane() public constant returns (bool sane) {
    // BK Ok
    return finalizeAgent.isSane();
  }

  /**
   * Check if the contract relationship looks good.
   */
  // BK NOTE - This function is unused and redundant, and not used in any other TokenMarket contracts
  // BK Ok
  function isPricingSane() public constant returns (bool sane) {
    // BK Ok
    return pricingStrategy.isSane(address(this));
  }

  /**
   * Crowdfund state machine management.
   *
   * We make it a function and do not assign the result to a variable, so there is no chance of the variable being stale.
   */
  // BK Ok
  function getState() public constant returns (State) {
    // BK Ok - Is finalised?
    if(finalized) return State.Finalized;
    // BK Ok - Needs finalizeAgent
    else if (address(finalizeAgent) == 0) return State.Preparing;
    // BK Ok - Needs valid finalizeAgent
    else if (!finalizeAgent.isSane()) return State.Preparing;
    // BK Ok - Needs ETH -> token conversion algorithm
    else if (!pricingStrategy.isSane(address(this))) return State.Preparing;
    // BK Ok - Set up and prepared, before the public crowdsale
    else if (block.timestamp < startsAt) return State.PreFunding;
    // BK Ok - Before crowdsale end, and cap not reached
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
    // BK NOTE - [prev] Not finalised
    //           [prev] After crowdsale start
    //           [prev] Not (before end and cap not reached) => after end or cap reached
    //           Minimum goal reached
    else if (isMinimumGoalReached()) return State.Success;
    // BK NOTE - [prev] Not finalised
    //           [prev] After crowdsale start
    //           [prev] Not (before end and cap not reached) => after end or cap reached
    //           [prev] Minimum goal not reached
    //           Some funds raised
    //           Refunds have been loaded and >= funds raised
    else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) return State.Refunding;
    // BK Ok - Something fell through the logic above, including the situation where the minimum goal is not reached and the
    //         funds to be refunded have not been moved from the multisig back to the crowdsale contract
    else return State.Failure;
  }

  /** This is for manual testing of multisig wallet interaction */
  // BK NOTE - This function sets `ownerTestValue` which is unused and redundant, and not used in any other TokenMarket contracts
  // BK Ok
  function setOwnerTestValue(uint val) onlyOwner {
    // BK OK
    ownerTestValue = val;
  }

  /** Interface marker. */
  // BK NOTE - This function is unused in this set of contracts, but is used in one other TokenMarket contract
  // BK Ok
  function isCrowdsale() public constant returns (bool) {
    // BK Ok
    return true;
  }

  //
  // Modifiers
  //

  /** Modified allowing execution only if the crowdsale is currently running.  */
  // BK Ok
  modifier inState(State state) {
    // BK Ok
    require(getState() == state);
    //if(getState() != state) throw;
    // BK Ok
    _;
  }


  //
  // Abstract functions
  //

  /**
   * Check if the current invested breaks our cap rules.
   *
   *
   * The child contract must define their own cap setting rules.
   * We allow a lot of flexibility through different capping strategies (ETH, token count)
   * Called from invest().
   *
   * @param weiAmount The amount of wei the investor tries to invest in the current transaction
   * @param tokenAmount The amount of tokens we try to give to the investor in the current transaction
   * @param weiRaisedTotal What would be our total raised balance after this transaction
   * @param tokensSoldTotal What would be our total sold tokens count after this transaction
   *
   * @return true if taking this investment would break our cap rules
   */
  // BK Ok
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken);
  /**
   * Check if the current crowdsale is full and we can no longer sell any tokens.
   */
  // BK Ok
  function isCrowdsaleFull() public constant returns (bool);

  /**
   * Create new tokens or transfer issued tokens to the investor depending on the cap model.
   */
  // BK Ok
  function assignTokens(address receiver, uint tokenAmount) private;
}
```