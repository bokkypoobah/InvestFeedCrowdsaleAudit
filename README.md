# InvestFeed Crowdsale Audit

**STATUS: Work In Progress**

See [https://www.investfeed.com/tokensale](https://www.investfeed.com/tokensale).

<br />

<hr />

## Table Of Contents

* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Trustlessness Of The Crowdsale Contract](#trustlessness-of-the-crowdsale-contract)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [First Review](#first-review)
* [Second Review](#second-review)
* [Third Review](#third-review)
* [Fourth Review](#fourth-review)
  * [Recommendations](#recommendations)
  * [Notes](#notes)
  * [Code Review](#code-review)

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds contributed to these contracts are not easily attacked or stolen by third parties. 
The secondary aim of this audit is that ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to highlight any areas of
weaknesses.

<br />

<hr />

## Limitations
This audit makes no statements or warranties about the viability of the InvestFeed's business proposition, the individuals involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence
As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition before funding the crowdsale.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on InvestFeed's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as duplicating crowdsale websites.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address matches the audited source code, and that 
the deployment parameters are correctly set, including the constant parameters.

Potential participants should note that there is a minimum funding goal in this crowdsale and there are refunds if this minimum funding goal is not reached.

InvestFeed will have to load funds back into the crowdsale contract for investors to withdraw their refunds.

This contract has no mechanism to enforce any vesting of InvestFeed's tokens.

<br />

<hr />

## Risks

This crowdfunding contract has a relatively low risk of losing large amounts of ethers in an attack or a bug, as funds contributed by participants are immediately transferred
into a multisig wallet.

The flow of funds from this crowdsale contract should be monitored using a script and visually through EtherScan. Should there be any abnormal 
gaps in the crowdfunding contracts, potential participants should be informed to stop contributing to this crowdsale contract. Most of the funds
will be held in the multisig wallet, so any potential losses due to flaws in the crowdsale contract should be minimal.

In the case of the crowdfunding contract allocating an incorrect number of tokens for each contribution, the token numbers can be manually
recalculated and a new token contract can be deployed at a new address.

<br />

<hr />

## Trustlessness Of The Crowdsale Contract

* The PricingStrategy can be changed at any point by the owner when the crowdsale is running. Comment in the source code:

  > Design choice: no state restrictions on the set, so that we can fix fat finger mistakes.

  A change in the pricing strategy can only be detected by looking for this `Crowdsale.setPricingStrategy(...)` transaction, and the ETH to token rate changes.

* The crowdsale end date can be changed by the owner at any point during the crowdsale, to a time later than when the change is made. Comment in the source code:

  > Allow crowdsale owner to close early or extend the crowdsale.
  >
  > This is useful e.g. for a manual soft cap implementation:
  > - after X amount is reached determine manual closing
  >
  > This may put the crowdsale to an invalid state,
  > but we trust owners know what they are doing.

  The `EndsAtChanged(...)` event is logged.

  The crowdsale contract owner can also re-open a closed crowdsale using this parameter, if the crowdsale has not been `finalized`.

* Some negative scenarios:

  * An investor may decide to invest near the end of the crowdsale only a small amount has been contributed by other investors. The crowdsale
    contract owner may extend the crowdsale closing date to any point in the future.

  * An investor may decide to wait nearer to the end of the crowdsale to invest, but the owners can suddenly close down the crowdsale. They would normally
    inform their community that they plan to close down the crowdsale prematurely, but this could be 24 hours and not enough time for this investor. 

* This crowdsale contract moves all investor contributions straight into the crowdsale team's multisig wallet. If the minimum funding goal
  is not reached, investors will only be able to claim their refunds IF the crowdsale team moves all original funds back from the
  multisig into the crowdsale contract. See `Crowdsale.loadRefund()`.

* The upgrade agent can be set by the upgrade master (crowdsale team's account), but accounts have to execute the upgrades themselves, which is a good trustless upgrade

* TODO - CHECK AGAIN - Once the crowdsale if finalised, the token contract has the right elements for a trustless token contract

<br />

<hr />

## Potential Vulnerabilities

TODO No potential vulnerabilities have been identified in the crowdsale contract yet.

<br />

<hr />

## First Review

The [MintedEthCappedCrowdsale](contracts-firstreview/MintedEthCappedCrowdsale.sol) crowdsale contract is deployed at [0x70791b81028f30ff01d4ad8f83cbffcd2be1b1f3](https://etherscan.io/address/0x70791b81028f30ff01d4ad8f83cbffcd2be1b1f3#code)

The variable `token` points to [CrowdsaleToken](contracts-firstreview/CrowdsaleToken.sol) deployed at [0xafcb18e95b10a18baeaf69baac1ac610df9f7d12](https://etherscan.io/address/0xafcb18e95b10a18baeaf69baac1ac610df9f7d12#code)

The variable `pricingStrategy` points to [EthTranchePricing](contracts-firstreview/EthTranchePricing.sol) deployed at [0x486e49d1622fdfc8ca760fcfc17792753a4beca8](https://etherscan.io/address/0x486e49d1622fdfc8ca760fcfc17792753a4beca8#code)

The variable `finalizeAgent` points to [BonusFinalizeAgent](contracts-firstreview/BonusFinalizeAgent.sol) deployed at [0xde5bb4b67b64daa2a92df3abf662023f06e599d8](https://etherscan.io/address/0xde5bb4b67b64daa2a92df3abf662023f06e599d8#code)

Following are the line counts in each of the contracts:

    $ wc -l *
         748 BonusFinalizeAgent.sol
         421 CrowdsaleToken.sol
         452 EthTranchePricing.sol
         772 MintedEthCappedCrowdsale.sol
        2393 total


Some potential issues:

* \#1 LOW IMPORTANCE `uint` is used instead of `uint8` for `decimals`. `uint8` is the recommended data type in ERC20 . I have not found any side-effects from using `uint` but it may be better to stick to the standard

  Fixed in second review

* \#2 LOW IMPORTANCE `transfer(...)` and `transferFrom(...)` throws when unable to transfer the tokens. This will not allow contracts to use `transfer(...)` and `transferFrom(...)` elegantly. Some discussion at https://www.reddit.com/r/ethdev/comments/6hakyf/please_those_in_favor_of_throwing_instead_of/ . I have not worked out what the resolution is, but I return true/false for my `transfer(...)` and `transferFrom(...)` - example https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L71-L83 and https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L101-L124

  Fixed in second review

* \#3 MEDIUM IMPORTANCE There are problems with the use of `onlyPayloadSize(...)` - https://blog.coinfabrik.com/smart-contract-short-address-attack-mitigation-failure/ . And OpenZeppelin have a closed issue to remove all short address attack mitigation code - https://github.com/OpenZeppelin/zeppelin-solidity/issues/261 . You can see that they removed this check - https://github.com/OpenZeppelin/zeppelin-solidity/commit/e33d9bb41be136f12bc734aef1aa6fffbf54fa40#diff-36d1ffbdb9795a5b94350fb71b725dbe

  Fixed in second review 

* \#4 Attribute the source of the source code

  Moving to the second review.

<br />

<hr />

## Second Review

Second review of [https://github.com/investfeed-corp/feed-token-sale/commit/57cdb3867d4616c41b21e8948ff507730a513e25](https://github.com/investfeed-corp/feed-token-sale/commit/57cdb3867d4616c41b21e8948ff507730a513e25).

Files available in [contracts-secondreview](contracts-secondreview).

Some potential issues:

* \#4 MEDIUM IMPORTANCE - Attribute the source of the source code

  Fixed in third review.

* \#5 MEDIUM IMPORTANCE - Use `acceptOwnership(...)` pattern in Owned contract

  Fixed in third review

* \#6 LOW IMPORTANCE - `assert(...)` is built-in in Solidity 0.4.11 - https://github.com/investfeed-corp/feed-token-sale/blob/master/CrowdsaleTokenCombined.sol#L22-L24

  Some change incorporated, and not necessary - in fourth review.

* \#7 LOW IMPORTANCE - Use `require(...)` instead of `throw` or `assert(...)` - from https://www.reddit.com/r/ethereum/comments/6llgxv/solidity_0413_released/, "Syntax Checker: Deprecated throw in favour of require(), assert() and revert()"

  Some changes incorporated, and not necessary - in fourth review.

* \#8 LOW IMPORTANCE - The new OpenZeppelin libraries now use `balances[msg.sender] = balances[msg.sender].sub(_amount);` instead of `balances[_to] = safeAdd(balances[_to],_value);` style

  Change not incorporated, and not necessary - in fourth review.

* \#9 LOW IMPORTANCE - Decide on 2 or 4 spaces for tabs, have consistent spacing between functions, groups of statements, prettify source so investors can read easily and require less trust

  Some small areas with inconsistent spacing - in fourth review.

<br />

<hr />

## Third Review

Third review of [https://github.com/investfeed-corp/feed-token-sale/commit/2007dc6163cc8a2c27cc6c3e35023663b1641214](https://github.com/investfeed-corp/feed-token-sale/commit/2007dc6163cc8a2c27cc6c3e35023663b1641214).

Setting up [tests](test).

Some potential issues:

* \#10 MEDIUM IMPORTANCE - Comments from the individual contract files should be left in the combined files to make it more readable

  Comments have now been left in the combined files - in fourth review.

* \#11 MEDIUM IMPORTANCE - Use the [ConsenSys multisig](https://github.com/ConsenSys/MultiSigWallet) or Ethereum multisig as these are more widely use, unless you have a good reason to use the OpenZeppelin multisig

  InvestFeed is using the ConsenSys multisig - in fourth review.

* \#12 MEDIUM IMPORTANCE - Developer to review recent changes to the OpenZeppelin and TokenMarket libraries since the contracts were copied, for high priority bugs

  InvestFeed incorporated changes to StandardToken.sol to remove `addApproval(...)` and `subApproval(...)` in the fourth review.

<br />

<hr />

## Fourth Review

Fourth review of [https://github.com/investfeed-corp/feed-token-sale/commit/68f31e23c40b405275ad1b521fc222ec7cccdde8](https://github.com/investfeed-corp/feed-token-sale/commit/68f31e23c40b405275ad1b521fc222ec7cccdde8).

There were some changes to [contracts/Crowdsale.sol](contracts/Crowdsale.sol) and [contracts/StandardToken.sol](contracts/StandardToken.sol) which will be reviewed below.

The combined files have been updated to leave the comments from the individual files in place.

* TODO - Run a few more tests [tests](test) to confirm that the contracts lifecycle works as expected.

<br />

<hr />

### Recommendations

* See note below re `preallocate(...)` and refunds. The crowdsale team should reconcile the crowdsale contract `weiRaised` variable against
  the funds received during the preallocation phase - after all the `preallocate(...)` entries have been entered. If these numbers do not
  reconcile, it may be best to deploy a new crowdsale contract and enter the correct `preallocate(...)` entries.

* As the interactions between the different contracts is quite convoluted, prepare some scripts to check the relationships between the contracts are correct 
  and that the crowdsale numbers add up. See the example script [https://github.com/openanx/OpenANXToken/blob/master/scripts/getOpenANXTokenDetails.sh](https://github.com/openanx/OpenANXToken/blob/master/scripts/getOpenANXTokenDetails.sh) 
  with sample results in [https://github.com/openanx/OpenANXToken/blob/master/scripts/Main_20170704_150051-final.txt](https://github.com/openanx/OpenANXToken/blob/master/scripts/Main_20170704_150051-final.txt) and
  [https://github.com/openanx/OpenANXToken/blob/master/scripts/TokensBought_20170625_015900.tsv](https://github.com/openanx/OpenANXToken/blob/master/scripts/TokensBought_20170625_015900.tsv).

<br />

<hr />

### Notes

* If the crowdsale does not reach the minimum funding goal by the end of the crowdsale period, all funds supporting the tokens issued must be moved
  back into the crowdsale contract before the refund state is activated. This includes the funds that support the tokens created using the
  `preallocate(...)` function.

  It is important to get the `weiPrice` parameter of the `preallocate(...)` function correct, as noone will be able claim their refunds and 
  the ethers may be trapped in this crowdsale contract.

  Once scenario is where the `preallocate(...)` function has the `weiPrice` out by a factor of 10 times. 10 times as much funds that were 
  collected during the preallocation phase will need to be moved back into the crowdsale contract for refunds to be active.

* The `preallocate(...)` function can be executed at any time before, during and after the crowdsale, but before finalisation of the crowdsale. Normally
  this function is used before the crowdsale starts.

* The `preallocate(...)` function can only be used to allocate round token amounts and not fractional token amounts. E.g. 10 instead of 10.123456789000000000

* If `CrowdsaleToken.(UpgradeableToken).setUpgradeMaster(...)` is called with an invalid new upgrade master, upgrades can be prevented forever
 
<br />

<hr />

### Code Review

* [CrowdsaleTokenCombined.sol](contracts-thirdreview/CrowdsaleTokenCombined.sol)
  * [x] contract [CrowdsaleToken](codereview/CrowdsaleToken.md) is *ReleasableToken*, *MintableToken*, *UpgradeableToken*
    * [x] contract [ReleasableToken](codereview/ReleasableToken.md) is *ERC20*, *Ownable*
      * [x] contract [ERC20](codereview/ERC20.md) is *ERC20Basic*
        * [x] contract [ERC20Basic](codereview/ERC20Basic.md)
      * [x] contract [Ownable](codereview/Ownable.md)
    * [x] contract [MintableToken](codereview/MintableToken.md) is *StandardToken*, *Ownable*
      * [x] contract [StandardToken](codereview/StandardToken.md) is *ERC20*, *SafeMathLib*
        * contract *ERC20* is *ERC20Basic*
          * contract *ERC20Basic*
        * [x] contract [SafeMathLib](codereview/SafeMathLib.md)
      * contract *Ownable*
    * [x] contract [UpgradeableToken](codereview/UpgradeableToken.md) is *StandardToken*
      * contract *StandardToken* is *ERC20*, *SafeMathLib*
        * contract *ERC20* is *ERC20Basic*
          * contract *ERC20Basic*
        * contract *SafeMathLib*
      * [x] contract [UpgradeAgent](codereview/UpgradeAgent.md)

* [EthTranchePricingCombined.sol](contracts-thirdreview/EthTranchePricingCombined.sol)
  * [x] contract [EthTranchePricing](codereview/EthTranchePricing.md) is *PricingStrategy*, *Ownable*, *SafeMathLib*
    * [x] contract [PricingStrategy](codereview/PricingStrategy.md)
    * contract *Ownable*
    * contract *SafeMathLib*
  
* [MintedEthCappedCrowdsaleCombined.sol](contracts-thirdreview/MintedEthCappedCrowdsaleCombined.sol)
  * [x] contract [MintedEthCappedCrowdsale](codereview/MintedEthCappedCrowdsale.md) is *Crowdsale*
    * [x] contract [Crowdsale](codereview/Crowdsale.md) is *Haltable*, *SafeMathLib*
      * [x] contract [Haltable](codereview/Haltable.md) is *Ownable*
        * contract *Ownable*
      * contract *SafeMathLib*

* [BonusFInalizeAgentCombined.sol](contracts-thirdreview/BonusFInalizeAgentCombined.sol)
  * contract [BonusFinalizeAgent](codereview/BonusFinalizeAgent.md) is *FinalizeAgent*, *SafeMathLib*
    * [x] contract [FinalizeAgent](codereview/FinalizeAgent.md)
    * contract *SafeMathLib*


<br />

<hr />

## References

* [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)

<br />

<br />

Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd for InvestFeed Jul 9 2017. The MIT Licence.