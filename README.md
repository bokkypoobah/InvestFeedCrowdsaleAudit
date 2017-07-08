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
  * [Recommendations](#recommendations)
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

TODO

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

* \#5 MEDIUM IMPORTANCE - Use `acceptOwnership(...)` pattern in Owned contract

  Fixed in third review

* \#6 LOW IMPORTANCE - `assert(...)` is built-in in Solidity 0.4.11 - https://github.com/investfeed-corp/feed-token-sale/blob/master/CrowdsaleTokenCombined.sol#L22-L24

* \#7 LOW IMPORTANCE - Use `require(...)` instead of `throw` or `assert(...)` - from https://www.reddit.com/r/ethereum/comments/6llgxv/solidity_0413_released/, "Syntax Checker: Deprecated throw in favour of require(), assert() and revert()"

* \#8 LOW IMPORTANCE - The new OpenZeppelin libraries now use `balances[msg.sender] = balances[msg.sender].sub(_amount);` instead of `balances[_to] = safeAdd(balances[_to],_value);` style

* \#9 LOW IMPORTANCE - Decide on 2 or 4 spaces for tabs, have consistent spacing between functions, groups of statements, prettify source so investors can read easily and require less trust

<br />

<hr />

## Third Review

Third review of [https://github.com/investfeed-corp/feed-token-sale/commit/2007dc6163cc8a2c27cc6c3e35023663b1641214](https://github.com/investfeed-corp/feed-token-sale/commit/2007dc6163cc8a2c27cc6c3e35023663b1641214).

Setting up [tests](test).

<br />

<hr />

### Recommendations

* \#10 MEDIUM IMPORTANCE - Comments from the individual contract files should be left in the combined files to make it more readable

* \#11 MEDIUM IMPORTANCE - Use the ConsenSys or Ethereum multisig as these are more widely use, unless you have a good reason to use the OpenZeppelin multisig

* \#12 MEDIUM IMPORTANCE - Developer to review recent changes to the OpenZeppelin and TokenMarket libraries since the contracts were copied, for high priority bugs

<br />

<hr />

### Code Review

* [CrowdsaleTokenCombined.sol](contracts-thirdreview/CrowdsaleTokenCombined.sol)
  * contract [CrowdsaleToken](codereview/CrowdsaleToken.md) is *ReleasableToken*, *MintableToken*, *UpgradeableToken*
    * contract [ReleasableToken](codereview/ReleasableToken.md) is *ERC20*, *Ownable*
      * [x] contract [ERC20](codereview/ERC20.md) is *ERC20Basic*
        * [x] contract [ERC20Basic](codereview/ERC20Basic.md)
      * [x] contract [Ownable](codereview/Ownable.md)
    * contract [MintableToken](codereview/MintableToken.md) is *StandardToken*, *Ownable*
      * contract [StandardToken](codereview/StandardToken.md) is *ERC20*, *SafeMathLib*
        * contract *ERC20* is *ERC20Basic*
          * contract *ERC20Basic*
        * contract [SafeMathLib](codereview/SafeMathLib.md)
      * contract *Ownable*
    * contract [UpgradeableToken](codereview/UpgradeableToken.md) is *StandardToken*
      * contract *StandardToken* is *ERC20*, *SafeMathLib*
        * contract *ERC20* is *ERC20Basic*
          * contract *ERC20Basic*
        * contract *SafeMathLib*

* [EthTranchePricingCombined.sol](contracts-thirdreview/EthTranchePricingCombined.sol)
  * contract [EthTranchePricing](codereview/EthTranchePricing.md) is *PricingStrategy*, *Ownable*, *SafeMathLib*
    * contract [PricingStrategy](codereview/PricingStrategy.md)
    * contract *Ownable*
    * contract *SafeMathLib*
  
* [MintedEthCappedCrowdsaleCombined.sol](contracts-thirdreview/MintedEthCappedCrowdsaleCombined.sol)
  * contract [MintedEthCappedCrowdsale](codereview/MintedEthCappedCrowdsale.md) is *Crowdsale*
    * contract [Crowdsale](codereview/Crowdsale.md) is *Haltable*, *SafeMathLib*
      * [x] contract [Haltable](codereview/Haltable.md) is *Ownable*
        * contract *Ownable*
      * contract *SafeMathLib*

* [BonusFInalizeAgentCombined.sol](contracts-thirdreview/BonusFInalizeAgentCombined.sol)
  * contract [BonusFinalizeAgent](codereview/BonusFinalizeAgent.md) is *FinalizeAgent*, *SafeMathLib*
    * contract [FinalizeAgent](codereview/FinalizeAgent.md)
    * contract *SafeMathLib*


<br />

<hr />

## References

* [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)

<br />

<br />

Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd for InvestFeed Jul 9 2017. The MIT Licence.