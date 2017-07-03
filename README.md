# InvestFeed Crowdsale Audit

The [MintedEthCappedCrowdsale](contracts/MintedEthCappedCrowdsale.sol) crowdsale contract is deployed at [0x70791b81028f30ff01d4ad8f83cbffcd2be1b1f3](https://etherscan.io/address/0x70791b81028f30ff01d4ad8f83cbffcd2be1b1f3#code)

The variable `token` points to [CrowdsaleToken](contracts/CrowdsaleToken.sol) deployed at [0xafcb18e95b10a18baeaf69baac1ac610df9f7d12](https://etherscan.io/address/0xafcb18e95b10a18baeaf69baac1ac610df9f7d12#code)

The variable `pricingStrategy` points to [EthTranchePricing](contracts/EthTranchePricing.sol) deployed at [0x486e49d1622fdfc8ca760fcfc17792753a4beca8](https://etherscan.io/address/0x486e49d1622fdfc8ca760fcfc17792753a4beca8#code)

The variable `finalizeAgent` points to [BonusFinalizeAgent](contracts/BonusFinalizeAgent.sol) deployed at [0xde5bb4b67b64daa2a92df3abf662023f06e599d8](https://etherscan.io/address/0xde5bb4b67b64daa2a92df3abf662023f06e599d8#code)

Following are the line counts in each of the contracts:

    $ wc -l *
         748 BonusFinalizeAgent.sol
         421 CrowdsaleToken.sol
         452 EthTranchePricing.sol
         772 MintedEthCappedCrowdsale.sol
        2393 total


Some potential issues:

* \#1 LOW IMPORTANCE `uint` is used instead of `uint8` for `decimals`. `uint8` is the recommended data type in ERC20 . I have not found any side-effects from using `uint` but it may be better to stick to the standard

* \#2 LOW IMPORTANCE `transfer(...)` and `transferFrom(...)` throws when unable to transfer the tokens. This will not allow contracts to use `transfer(...)` and `transferFrom(...)` elegantly. Some discussion at https://www.reddit.com/r/ethdev/comments/6hakyf/please_those_in_favor_of_throwing_instead_of/ . I have not worked out what the resolution is, but I return true/false for my `transfer(...)` and `transferFrom(...)` - example https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L71-L83 and https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L101-L124

* \#3 MEDIUM IMPORTANCE There are problems with the use of `onlyPayloadSize(...)` - https://blog.coinfabrik.com/smart-contract-short-address-attack-mitigation-failure/ . And OpenZeppelin have a closed issue to remove all short address attack mitigation code - https://github.com/OpenZeppelin/zeppelin-solidity/issues/261 . You can see that they removed this check - https://github.com/OpenZeppelin/zeppelin-solidity/commit/e33d9bb41be136f12bc734aef1aa6fffbf54fa40#diff-36d1ffbdb9795a5b94350fb71b725dbe 