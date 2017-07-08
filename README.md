# InvestFeed Crowdsale Audit

## Table Of Contents

* [First Review](#first-review)
* [Second Review](#second-review)
* [Third Review](#third-review)

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

* \#6 LOW IMPORTANCE - `assert(...)` is built-in in Solidity 0.4.11 - https://github.com/investfeed-corp/feed-token-sale/blob/master/CrowdsaleTokenCombined.sol#L22-L24

* \#7 LOW IMPORTANCE - Use `require(...)` instead of `throw` or `assert(...)` - from https://www.reddit.com/r/ethereum/comments/6llgxv/solidity_0413_released/, "Syntax Checker: Deprecated throw in favour of require(), assert() and revert()"

* \#8 LOW IMPORTANCE - The new OpenZeppelin libraries now use `balances[msg.sender] = balances[msg.sender].sub(_amount);` instead of `balances[_to] = safeAdd(balances[_to],_value);` style

* \#9 LOW IMPORTANCE - Decide on 2 or 4 spaces for tabs, have consistent spacing between functions, groups of statements, prettify source so investors can read easily and require less trust

<br />

<hr />

## Third Review

Third review of [https://github.com/investfeed-corp/feed-token-sale/commit/2007dc6163cc8a2c27cc6c3e35023663b1641214](https://github.com/investfeed-corp/feed-token-sale/commit/2007dc6163cc8a2c27cc6c3e35023663b1641214).

Setting up [tests](test).

Code review of:

* [CrowdsaleToken.md](CrowdsaleToken.md)
  * contract CrowdsaleToken is ReleasableToken, MintableToken, UpgradeableToken
    * contract ReleasableToken is ERC20, Ownable
      * contract [ERC20](codereview/ERC20.md) is ERC20Basic
        * contract [ERC20Basic](codereview/ERC20Basic.md)
      * contract [Ownable](codereview/Ownable.md)
    * contract MintableToken is StandardToken, Ownable
      * contract StandardToken is ERC20, [SafeMathLib](codereview/SafeMathLib.md)
        * contract ERC20 is ERC20Basic
          * contract ERC20Basic
        * contract SafeMathLib
      * contract Ownable
    * contract UpgradeableToken is StandardToken
      * contract StandardToken is ERC20, SafeMathLib
        * contract ERC20 is ERC20Basic
          * contract ERC20Basic
        * contract SafeMathLib

* [EthTranchePricing.md](EthTranchePricing.md)
  * contract EthTranchePricing is PricingStrategy, Ownable, SafeMathLib
    * contract PricingStrategy
    * contract Ownable
    * contract SafeMathLib
  
* [MintedEthCappedCrowdsale.md](MintedEthCappedCrowdsale.md)
  * contract MintedEthCappedCrowdsale is Crowdsale
    * contract Crowdsale is Haltable, SafeMathLib
      * contract Haltable is Ownable
        * contract Ownable
      * contract SafeMathLib

* [BonusFinalizeAgent.md](BonusFinalizeAgent.md)
  * contract BonusFinalizeAgent is FinalizeAgent, SafeMathLib
    * contract FinalizeAgent
    * contract SafeMathLib


