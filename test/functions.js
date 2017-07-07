// Jul 7 2017
var ethPriceUSD = 262.3980;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Multisig");
addAccount(eth.accounts[3], "Account #3");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
addAccount(eth.accounts[8], "Account #8");
// addAccount(eth.accounts[9], "Account #9 - Crowdfund Wallet");
// addAccount(eth.accounts[10], "Account #10 - Foundation");
// addAccount(eth.accounts[11], "Account #11 - Advisors");
// addAccount(eth.accounts[12], "Account #12 - Directors");
// addAccount(eth.accounts[13], "Account #13 - Early Backers");
// addAccount(eth.accounts[14], "Account #14 - Developers");
// addAccount(eth.accounts[15], "Account #15 - Precommitments");
// addAccount(eth.accounts[16], "Account #16 - Tranche 2 Locked");
// addAccount("0x0000000000000000000000000000000000000000", "Burn Account");



var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var multisig = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];
// var crowdfundWallet = eth.accounts[9];
// var foundationAccount = eth.accounts[10];
// var advisorsAccount = eth.accounts[11];
// var directorsAccount = eth.accounts[12];
// var earlyBackersAccount = eth.accounts[13];
// var developersAccount = eth.accounts[14];
// var precommitmentsAccount = eth.accounts[15];
// var tranche2Account = eth.accounts[16];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
// dci Contract
//-----------------------------------------------------------------------------
var dciContractAddress = null;
var dciContractAbi = null;

function addDciContractAddressAndAbi(address, abi) {
  dciContractAddress = address;
  dciContractAbi = abi;
}

var dciFromBlock = 0;
function printDciContractDetails() {
  console.log("RESULT: dciContractAddress=" + dciContractAddress);
  // console.log("RESULT: dciContractAbi=" + JSON.stringify(dciContractAbi));
  if (dciContractAddress != null && dciContractAbi != null) {
    var contract = eth.contract(dciContractAbi).at(dciContractAddress);
    console.log("RESULT: dci.owner=" + contract.owner());
    console.log("RESULT: dci.hammer=" + contract.hammer());
    console.log("RESULT: dci.minDonation=" + contract.minDonation().shift(-18));
    console.log("RESULT: dci.BLOCKS_IN_DAY=" + contract.BLOCKS_IN_DAY());
    console.log("RESULT: dci.cf.fund=" + contract.fund());
    console.log("RESULT: dci.cf.bounty=" + contract.bounty());
    console.log("RESULT: dci.cf.totalFunded=" + contract.totalFunded().shift(-18));
    console.log("RESULT: dci.cf.reference=" + contract.reference());
    console.log("RESULT: dci.cf.config=" + JSON.stringify(contract.config()));
    var config = contract.config();
    console.log("RESULT: dci.cf.config[startBlock]=" + config[0]);
    console.log("RESULT: dci.cf.config[stopBlock]=" + config[1]);
    console.log("RESULT: dci.cf.config[minValue]=" + config[2].shift(-18));
    console.log("RESULT: dci.cf.config[maxValue]=" + config[3].shift(-18));
    console.log("RESULT: dci.cf.config[bountyScale]=" + config[4]);
    console.log("RESULT: dci.cf.config[startRatio]=" + config[5]);
    console.log("RESULT: dci.cf.config[reductionStep]=" + config[6]);
    console.log("RESULT: dci.cf.config[reductionValue]=" + config[7]);
    
    var latestBlock = eth.blockNumber;
    var i;

    var receivedEtherEvents = contract.ReceivedEther({}, { fromBlock: dciFromBlock, toBlock: latestBlock });
    i = 0;
    receivedEtherEvents.watch(function (error, result) {
      console.log("RESULT: ReceivedEther " + i++ + " #" + result.blockNumber + " sender=" + result.args.sender + " amount=" + result.args.amount + " " +
        result.args.amount.shift(-decimals));
    });
    receivedEtherEvents.stopWatching();

    dciFromBlock = latestBlock + 1;
  }
}



//-----------------------------------------------------------------------------
// Cst Contract
//-----------------------------------------------------------------------------
var cstContractAddress = null;
var cstContractAbi = null;

function addCstContractAddressAndAbi(address, abi) {
  cstContractAddress = address;
  cstContractAbi = abi;
}

var cstFromBlock = 0;
function printCstContractDetails() {
  console.log("RESULT: cstContractAddress=" + cstContractAddress);
  // console.log("RESULT: cstContractAbi=" + JSON.stringify(cstContractAbi));
  if (cstContractAddress != null && cstContractAbi != null) {
    var contract = eth.contract(cstContractAbi).at(cstContractAddress);
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply());
    console.log("RESULT: token.mintable=" + contract.mintable());

    var latestBlock = eth.blockNumber;
    var i;

    var approvalEvents = contract.Approval({}, { fromBlock: cstFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " owner=" + result.args.owner + " spender=" + result.args.spender + " _value=" +
        result.args.value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: cstFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " value=" + result.args.value.shift(-decimals));
    });
    transferEvents.stopWatching();

    cstFromBlock = parseInt(latestBlock) + 1;
  }
}
