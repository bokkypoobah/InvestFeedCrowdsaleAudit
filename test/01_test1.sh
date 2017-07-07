#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`

CROWDSALETOKENSOL=`grep ^CROWDSALETOKENSOL= settings.txt | sed "s/^.*=//"`
CROWDSALETOKENTEMPSOL=`grep ^CROWDSALETOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
CROWDSALETOKENJS=`grep ^CROWDSALETOKENJS= settings.txt | sed "s/^.*=//"`

ETHTRANCHEPRICINGSOL=`grep ^ETHTRANCHEPRICINGSOL= settings.txt | sed "s/^.*=//"`
ETHTRANCHEPRICINGTEMPSOL=`grep ^ETHTRANCHEPRICINGTEMPSOL= settings.txt | sed "s/^.*=//"`
ETHTRANCHEPRICINGJS=`grep ^ETHTRANCHEPRICINGJS= settings.txt | sed "s/^.*=//"`

MINTEDETHCAPPEDSOL=`grep ^MINTEDETHCAPPEDSOL= settings.txt | sed "s/^.*=//"`
MINTEDETHCAPPEDTEMPSOL=`grep ^MINTEDETHCAPPEDTEMPSOL= settings.txt | sed "s/^.*=//"`
MINTEDETHCAPPEDJS=`grep ^MINTEDETHCAPPEDJS= settings.txt | sed "s/^.*=//"`

BONUSFINALIZEAGENTSOL=`grep ^BONUSFINALIZEAGENTSOL= settings.txt | sed "s/^.*=//"`
BONUSFINALIZEAGENTTEMPSOL=`grep ^BONUSFINALIZEAGENTTEMPSOL= settings.txt | sed "s/^.*=//"`
BONUSFINALIZEAGENTJS=`grep ^BONUSFINALIZEAGENTJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+75" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*3" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                      = '$MODE'\n"
printf "GETHATTACHPOINT           = '$GETHATTACHPOINT'\n"
printf "PASSWORD                  = '$PASSWORD'\n"

printf "CONTRACTSDIR              = '$CONTRACTSDIR'\n"

printf "CROWDSALETOKENSOL         = '$CROWDSALETOKENSOL'\n"
printf "CROWDSALETOKENTEMPSOL     = '$CROWDSALETOKENTEMPSOL'\n"
printf "CROWDSALETOKENJS          = '$CROWDSALETOKENJS'\n"

printf "ETHTRANCHEPRICINGSOL      = '$ETHTRANCHEPRICINGSOL'\n"
printf "ETHTRANCHEPRICINGTEMPSOL  = '$ETHTRANCHEPRICINGTEMPSOL'\n"
printf "ETHTRANCHEPRICINGJS       = '$ETHTRANCHEPRICINGJS'\n"

printf "MINTEDETHCAPPEDSOL        = '$MINTEDETHCAPPEDSOL'\n"
printf "MINTEDETHCAPPEDTEMPSOL    = '$MINTEDETHCAPPEDTEMPSOL'\n"
printf "MINTEDETHCAPPEDJS         = '$MINTEDETHCAPPEDJS'\n"

printf "BONUSFINALIZEAGENTSOL     = '$BONUSFINALIZEAGENTSOL'\n"
printf "BONUSFINALIZEAGENTTEMPSOL = '$BONUSFINALIZEAGENTTEMPSOL'\n"
printf "BONUSFINALIZEAGENTJS      = '$BONUSFINALIZEAGENTJS'\n"

printf "DEPLOYMENTDATA            = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS                 = '$INCLUDEJS'\n"
printf "TEST1OUTPUT               = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS              = '$TEST1RESULTS'\n"
printf "CURRENTTIME               = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME                 = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME                   = '$ENDTIME' '$ENDTIME_S'\n"

# Make copy of SOL file and modify start and end times ---
`cp $CONTRACTSDIR/$CROWDSALETOKENSOL $CROWDSALETOKENTEMPSOL`
`cp $CONTRACTSDIR/$ETHTRANCHEPRICINGSOL $ETHTRANCHEPRICINGTEMPSOL`
`cp $CONTRACTSDIR/$MINTEDETHCAPPEDSOL $MINTEDETHCAPPEDTEMPSOL`
`cp $CONTRACTSDIR/$BONUSFINALIZEAGENTSOL $BONUSFINALIZEAGENTTEMPSOL`

# --- Modify dates ---
#`perl -pi -e "s/startTime \= 1498140000;.*$/startTime = $STARTTIME; \/\/ $STARTTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$CROWDSALETOKENSOL $CROWDSALETOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$CROWDSALETOKENSOL $CROWDSALETOKENTEMPSOL ---"
echo "$DIFFS1"

DIFFS1=`diff $CONTRACTSDIR/$ETHTRANCHEPRICINGSOL $ETHTRANCHEPRICINGTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$ETHTRANCHEPRICINGSOL $ETHTRANCHEPRICINGTEMPSOL ---"
echo "$DIFFS1"

DIFFS1=`diff $CONTRACTSDIR/$MINTEDETHCAPPEDSOL $MINTEDETHCAPPEDTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$MINTEDETHCAPPEDSOL $MINTEDETHCAPPEDTEMPSOL ---"
echo "$DIFFS1"

DIFFS1=`diff $CONTRACTSDIR/$BONUSFINALIZEAGENTSOL $BONUSFINALIZEAGENTTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$BONUSFINALIZEAGENTSOL $BONUSFINALIZEAGENTTEMPSOL ---"
echo "$DIFFS1"

echo "var cstOutput=`solc --optimize --combined-json abi,bin,interface $CROWDSALETOKENTEMPSOL`;" > $CROWDSALETOKENJS

echo "var etpOutput=`solc --optimize --combined-json abi,bin,interface $ETHTRANCHEPRICINGTEMPSOL`;" > $ETHTRANCHEPRICINGJS

echo "var mecOutput=`solc --optimize --combined-json abi,bin,interface $MINTEDETHCAPPEDTEMPSOL`;" > $MINTEDETHCAPPEDJS

echo "var bfaOutput=`solc --optimize --combined-json abi,bin,interface $BONUSFINALIZEAGENTTEMPSOL`;" > $BONUSFINALIZEAGENTJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("$CROWDSALETOKENJS");
loadScript("$ETHTRANCHEPRICINGJS");
loadScript("$MINTEDETHCAPPEDJS");
loadScript("$BONUSFINALIZEAGENTJS");
loadScript("functions.js");

var cstAbi = JSON.parse(cstOutput.contracts["$CROWDSALETOKENTEMPSOL:CrowdsaleToken"].abi);
var cstBin = "0x" + cstOutput.contracts["$CROWDSALETOKENTEMPSOL:CrowdsaleToken"].bin;

var etpAbi = JSON.parse(etpOutput.contracts["$ETHTRANCHEPRICINGTEMPSOL:EthTranchePricing"].abi);
var etpBin = "0x" + etpOutput.contracts["$ETHTRANCHEPRICINGTEMPSOL:EthTranchePricing"].bin;

var mecAbi = JSON.parse(mecOutput.contracts["$MINTEDETHCAPPEDTEMPSOL:MintedEthCappedCrowdsale"].abi);
var mecBin = "0x" + mecOutput.contracts["$MINTEDETHCAPPEDTEMPSOL:MintedEthCappedCrowdsale"].bin;

var bfaAbi = JSON.parse(bfaOutput.contracts["$BONUSFINALIZEAGENTTEMPSOL:BonusFinalizeAgent"].abi);
var bfaBin = "0x" + bfaOutput.contracts["$BONUSFINALIZEAGENTTEMPSOL:BonusFinalizeAgent"].bin;

// console.log("DATA: cstAbi=" + JSON.stringify(cstAbi));
// console.log("DATA: etpAbi=" + JSON.stringify(etpAbi));
// console.log("DATA: mecAbi=" + JSON.stringify(mecAbi));
// console.log("DATA: bfaAbi=" + JSON.stringify(bfaAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

var name = "Feed";
var symbol = "FEED";
var initialSupply = 0;
var decimals = 18;
var mintable = true;

var minimumFundingGoal = new BigNumber(100).shift(18);
var cap = new BigNumber(1000).shift(18);

var tranches = [ \
  0, new BigNumber(10000).shift(18), \
  new BigNumber(100).shift(18), new BigNumber(9000).shift(18), \
  cap, 0 \
];


if (true) {
// -----------------------------------------------------------------------------
var cstMessage = "Deploy CrowdsaleToken Contract";
console.log("RESULT: " + cstMessage);
var cstContract = web3.eth.contract(cstAbi);
console.log(JSON.stringify(cstContract));
var cstTx = null;
var cstAddress = null;

var cst = cstContract.new(name, symbol, initialSupply, decimals, mintable, {from: contractOwnerAccount, data: cstBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        cstTx = contract.transactionHash;
      } else {
        cstAddress = contract.address;
        addAccount(cstAddress, symbol + " " + name);
        addCstContractAddressAndAbi(cstAddress, cstAbi);
        addTokenContractAddressAndAbi(cstAddress, cstAbi);
        console.log("DATA: teAddress=" + cstAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("cstAddress=" + cstAddress, cstTx);
printBalances();
failIfGasEqualsGasUsed(cstTx, cstMessage);
printCstContractDetails();
console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
var etpMessage = "Deploy PricingStrategy Contract";
console.log("RESULT: " + etpMessage);
var etpContract = web3.eth.contract(etpAbi);
console.log(JSON.stringify(etpContract));
var etpTx = null;
var etpAddress = null;

var etp = etpContract.new(tranches, {from: contractOwnerAccount, data: etpBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        etpTx = contract.transactionHash;
      } else {
        etpAddress = contract.address;
        addAccount(etpAddress, "PricingStrategy");
        // addCstContractAddressAndAbi(etpAddress, etpAbi);
        console.log("DATA: etpAddress=" + etpAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("etpAddress=" + etpAddress, etpTx);
printBalances();
failIfGasEqualsGasUsed(etpTx, etpMessage);
// printCstContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mecMessage = "Deploy MintedEthCappedCrowdsale Contract";
console.log("RESULT: " + mecMessage);
var mecContract = web3.eth.contract(mecAbi);
console.log(JSON.stringify(mecContract));
var mecTx = null;
var mecAddress = null;

var mec = mecContract.new(cstAddress, etpAddress, multisig, $STARTTIME, $ENDTIME, minimumFundingGoal, cap, {from: contractOwnerAccount, data: mecBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mecTx = contract.transactionHash;
      } else {
        mecAddress = contract.address;
        addAccount(mecAddress, "Crowdsale");
        // addCstContractAddressAndAbi(etpAddress, etpAbi);
        console.log("DATA: mecAddress=" + mecAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("mecAddress=" + mecAddress, mecTx);
printBalances();
failIfGasEqualsGasUsed(mecTx, mecMessage);
// printCstContractDetails();
console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
var dciMessage = "Deploy DaoCasinoIco Contract";
console.log("RESULT: " + dciMessage);
var dciContract = web3.eth.contract(dciAbi);
console.log(JSON.stringify(dciContract));
var dciTx = null;
var dciAddress = null;
var startBlock = parseInt(eth.blockNumber) + 1;
var stopBlock = parseInt(eth.blockNumber) + 29;
var day1Block = parseInt(startBlock) + $BLOCKSINDAY * 12; // Day 13 2,000 BET = 1 ETH
var day2Block = parseInt(startBlock) + $BLOCKSINDAY * 16; // Day 16 1,700 BET = 1 ETH
var day3Block = parseInt(startBlock) + $BLOCKSINDAY * 21; // Day 21 1,500 BET = 1 ETH
var minValue = 10000000000000000000; // 10 ETH
var maxValue = 1000000000000000000000; // 1000 ETH
var scale = 1;
var startRatio = 1;
var reductionStep = 1;
var reductionValue = 1;
var minDonation = 100000000000000000; // 0.1 ETH
var dci = dciContract.new(fundAccount, teAddress, "Reference", startBlock, stopBlock, 
    minValue, maxValue, scale, startRatio, reductionStep, reductionValue, minDonation, {from: contractOwnerAccount, data: dciBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        dciTx = contract.transactionHash;
      } else {
        dciAddress = contract.address;
        addAccount(dciAddress, "DaoCasinoIco");
        addDciContractAddressAndAbi(dciAddress, dciAbi);
        console.log("DATA: dciAddress=" + dciAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("dciAddress=" + dciAddress, dciTx);
printBalances();
failIfGasEqualsGasUsed(dciTx, dciMessage);
printDciContractDetails();
console.log("RESULT: ");
console.log(JSON.stringify(dci));


// -----------------------------------------------------------------------------
var linkMessage = "Link TokenEmission With DaoCasinoICO";
console.log("RESULT: " + linkMessage);
var link1Tx = te.setOwner(dciAddress, {from: contractOwnerAccount, gas: 400000});
var link2Tx = te.setHammer(dciAddress, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("link1Tx", link1Tx);
printTxData("link2Tx", link2Tx);
printBalances();
failIfGasEqualsGasUsed(link1Tx, linkMessage);
failIfGasEqualsGasUsed(link2Tx, linkMessage);
printDciContractDetails();
printTeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account4";
console.log("RESULT: " + validContribution1Message);
var sendValidContribution1Tx = eth.sendTransaction({from: account4, to: dciAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendValidContribution1Tx", sendValidContribution1Tx);
printBalances();
failIfGasEqualsGasUsed(sendValidContribution1Tx, validContribution1Message);
printDciContractDetails();
printTeContractDetails();
console.log("RESULT: ");

console.log("RESULT: Waiting until day 2 #" + day1Block + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= day1Block) {
}
console.log("RESULT: Waited until day 2 #" + day1Block + " currentBlock=" + eth.blockNumber);

// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 200 ETH From Account5 - Day2";
console.log("RESULT: " + validContribution2Message);
var sendValidContribution2Tx = eth.sendTransaction({from: account5, to: dciAddress, gas: 400000, value: web3.toWei("200", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendValidContribution2Tx", sendValidContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(sendValidContribution2Tx, validContribution2Message);
printDciContractDetails();
printTeContractDetails();
console.log("RESULT: ");

console.log("RESULT: Waiting until stopBlock #" + stopBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= stopBlock) {
}
console.log("RESULT: Waited until stopBlock #" + stopBlock + " currentBlock=" + eth.blockNumber);

// -----------------------------------------------------------------------------
var getMyBountyMessage = "Get My Bounty - Account4 and Account5 - After stop block";
console.log("RESULT: " + getMyBountyMessage);
var getMyBounty1Tx = dci.getMyBounty({from: account4, to: dciAddress, gas: 400000});
var getMyBounty2Tx = dci.getMyBounty({from: account5, to: dciAddress, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("getMyBounty1Tx", getMyBounty1Tx);
printTxData("getMyBounty2Tx", getMyBounty2Tx);
printBalances();
failIfGasEqualsGasUsed(getMyBounty1Tx, getMyBountyMessage);
failIfGasEqualsGasUsed(getMyBounty2Tx, getMyBountyMessage);
printDciContractDetails();
printTeContractDetails();
console.log("RESULT: ");



exit;




// -----------------------------------------------------------------------------
var sendInvalidContributionMessage = "Send Invalid Contribution - 100 ETH From Account2 Before Start Date";
console.log("RESULT: " + sendInvalidContributionMessage);
var sendInvalidContributionTx = eth.sendTransaction({from: account2, to: ffsAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendInvalidContributionTx", sendInvalidContributionTx);
printBalances();
passIfGasEqualsGasUsed(sendInvalidContributionTx, sendInvalidContributionMessage);
printFfsContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = ffs.startTime();
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var sendInvalidContribution1Message = "Send Invalid Contribution - 100 ETH From Account2 With Too High Gas Price";
console.log("RESULT: " + sendInvalidContribution1Message);
var sendInvalidContribution1Tx = eth.sendTransaction({from: account2, to: ffsAddress, gas: 400000, value: web3.toWei("100", "ether"), gasPrice: web3.toWei(60, "gwei")});

var sendValidContribution1Message = "Send Valid Contribution - 100 ETH From Account3";
console.log("RESULT: " + sendValidContribution1Message);
var sendValidContribution1Tx = eth.sendTransaction({from: account3, to: ffsAddress, gas: 400000, value: web3.toWei("100", "ether")});

var sendValidContribution2Message = "Send Valid Contribution - 890 ETH From Account3 - Sale Over Due To Cap Check Bug";
console.log("RESULT: " + sendValidContribution2Message);
var sendValidContribution2Tx = eth.sendTransaction({from: account3, to: ffsAddress, gas: 400000, value: web3.toWei("890", "ether")});

while (txpool.status.pending > 0) {
}

printTxData("sendInvalidContribution1Tx", sendInvalidContribution1Tx);
printTxData("sendValidContribution1Tx", sendValidContribution1Tx);
printTxData("sendValidContribution2Tx", sendValidContribution2Tx);

printBalances();

passIfGasEqualsGasUsed(sendInvalidContribution1Tx, sendInvalidContribution1Message);
failIfGasEqualsGasUsed(sendValidContribution1Tx, sendValidContribution1Message);
failIfGasEqualsGasUsed(sendValidContribution2Tx, sendValidContribution2Message);

printFfsContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendInvalidContribution2Message = "Send Invalid Contribution - 1 ETH From Account4 - Sale Closed Due To Cap Check Bug";
console.log("RESULT: " + sendInvalidContribution2Message);
var sendInvalidContribution2Tx = eth.sendTransaction({from: account2, to: ffsAddress, gas: 400000, value: web3.toWei("1", "ether"), gasPrice: web3.toWei(60, "gwei")});
while (txpool.status.pending > 0) {
}
printTxData("sendInvalidContribution2Tx", sendInvalidContribution2Tx);
printBalances();
passIfGasEqualsGasUsed(sendInvalidContribution2Tx, sendInvalidContribution2Message);
printFfsContractDetails();
console.log("RESULT: ");


exit;


var skipKycContract = "$MODE" == "dev" ? true : false;
var skipSafeMath = "$MODE" == "dev" ? true : false;

// -----------------------------------------------------------------------------
var testMessage = "Test 1.1 Deploy Token Contract";
console.log("RESULT: " + testMessage);
var tokenContract = web3.eth.contract(tokenAbi);
console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new(tokenOwnerAccount, {from: tokenOwnerAccount, data: tokenBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, token.symbol() + " '" + token.name() + "' *");
        addAccount(token.lockedTokens(), "Locked Tokens");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi, lockedTokensAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printBalances();
failIfGasEqualsGasUsed(tokenTx, testMessage);
printTokenContractStaticDetails();
printTokenContractDynamicDetails();
console.log("RESULT: ");
console.log(JSON.stringify(token));


// -----------------------------------------------------------------------------
var testMessage = "Test 1.2 Precommitments, TokensPerKEther, Wallet";
console.log("RESULT: " + testMessage);
var tx1_2_1 = token.addPrecommitment(precommitmentsAccount, "10000000000000000000000000", {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_2 = token.setTokensPerKEther("1000000", {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_3 = token.setWallet(crowdfundWallet, {from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx1_2_1", tx1_2_1);
printTxData("tx1_2_2", tx1_2_2);
printTxData("tx1_2_3", tx1_2_3);
printBalances();
failIfGasEqualsGasUsed(tx1_2_1, testMessage + " - precommitments");
failIfGasEqualsGasUsed(tx1_2_2, testMessage + " - tokensPerKEther Rate From 343,734 To 1,000,000");
failIfGasEqualsGasUsed(tx1_2_3, testMessage + " - change crowdsale wallet");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startDateTime = token.START_DATE();
var startDateTimeDate = new Date(startDateTime * 1000);
console.log("RESULT: Waiting until start date at " + startDateTime + " " + startDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startDateTime + " " + startDateTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var testMessage = "Test 2.1 Buy tokens";
console.log("RESULT: " + testMessage);
var tx2_1_1 = eth.sendTransaction({from: account2, to: tokenAddress, gas: 400000, value: web3.toWei("100", "ether")});
var tx2_1_2 = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var tx2_1_3 = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("10000", "ether")});
var tx2_1_4 = eth.sendTransaction({from: directorsAccount, to: tokenAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var tx2_1_5 = token.proxyPayment(account6, {from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx2_1_1", tx2_1_1);
printTxData("tx2_1_2", tx2_1_2);
printTxData("tx2_1_3", tx2_1_3);
printTxData("tx2_1_4", tx2_1_4);
printTxData("tx2_1_5", tx2_1_5);
printBalances();
failIfGasEqualsGasUsed(tx2_1_1, testMessage + " - account2 buys 100,000 OAX for 100 ETH");
failIfGasEqualsGasUsed(tx2_1_2, testMessage + " - account3 buys 1,000,000 OAX for 1,000 ETH");
failIfGasEqualsGasUsed(tx2_1_3, testMessage + " - account4 buys 10,000,000 OAX for 10,000 ETH");
failIfGasEqualsGasUsed(tx2_1_4, testMessage + " - directorsAccount buys 1,000,000 OAX for 1,000 ETH");
failIfGasEqualsGasUsed(tx2_1_5, testMessage + " - account5 buys 500 OAX for 0.5 ETH on behalf of account6");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 3.1 Cannot Move Tokens Without Finalisation And KYC Verification";
console.log("RESULT: " + testMessage);
var tx3_1_1 = token.transfer(account5, "1000000000000", {from: account2, gas: 100000});
var tx3_1_2 = token.transfer(account6, "200000000000000", {from: account4, gas: 100000});
var tx3_1_3 = token.approve(account7,  "30000000000000000", {from: account3, gas: 100000});
var tx3_1_4 = token.approve(account8,  "4000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx3_1_5 = token.transferFrom(account3, account7, "30000000000000000", {from: account7, gas: 100000});
var tx3_1_6 = token.transferFrom(account4, account8, "4000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx3_1_1", tx3_1_1);
printTxData("tx3_1_2", tx3_1_2);
printTxData("tx3_1_3", tx3_1_3);
printTxData("tx3_1_4", tx3_1_4);
printTxData("tx3_1_5", tx3_1_5);
printTxData("tx3_1_6", tx3_1_6);
printBalances();
passIfGasEqualsGasUsed(tx3_1_1, testMessage + " - transfer 0.000001 OAX ac2 -> ac5. CHECK no movement");
passIfGasEqualsGasUsed(tx3_1_2, testMessage + " - transfer 0.0002 OAX ac4 -> ac6. CHECK no movement");
failIfGasEqualsGasUsed(tx3_1_3, testMessage + " - approve 0.03 OAX ac3 -> ac7");
failIfGasEqualsGasUsed(tx3_1_4, testMessage + " - approve 4 OAX ac4 -> ac8");
passIfGasEqualsGasUsed(tx3_1_5, testMessage + " - transferFrom 0.03 OAX ac3 -> ac5. CHECK no movement");
passIfGasEqualsGasUsed(tx3_1_6, testMessage + " - transferFrom 4 OAX ac4 -> ac6. CHECK no movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 4.1 Finalise crowdsale";
console.log("RESULT: " + testMessage);
var tx4_1 = token.finalise({from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx4_1", tx4_1);
printBalances();
failIfGasEqualsGasUsed(tx4_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 5.1 KYC Verify";
console.log("RESULT: " + testMessage);
var tx5_1_1 = token.kycVerify(account2, {from: tokenOwnerAccount, gas: 4000000});
var tx5_1_2 = token.kycVerify(account3, {from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx5_1_1", tx5_1_1);
printTxData("tx5_1_2", tx5_1_2);
printBalances();
failIfGasEqualsGasUsed(tx5_1_1, testMessage + " - account2");
failIfGasEqualsGasUsed(tx5_1_2, testMessage + " - account3");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 6.1 Move Tokens After Finalising";
console.log("RESULT: " + testMessage);
console.log("RESULT: kyc(account3)=" + token.kycRequired(account3));
console.log("RESULT: kyc(account4)=" + token.kycRequired(account4));
var tx6_1_1 = token.transfer(account5, "1000000000000", {from: account2, gas: 100000});
var tx6_1_2 = token.transfer(account6, "200000000000000", {from: account4, gas: 100000});
var tx6_1_3 = token.approve(account7, "30000000000000000", {from: account3, gas: 100000});
var tx6_1_4 = token.approve(account8, "4000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx6_1_5 = token.transferFrom(account3, account7, "30000000000000000", {from: account7, gas: 100000});
var tx6_1_6 = token.transferFrom(account4, account8, "4000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx6_1_1", tx6_1_1);
printTxData("tx6_1_2", tx6_1_2);
printTxData("tx6_1_3", tx6_1_3);
printTxData("tx6_1_4", tx6_1_4);
printTxData("tx6_1_5", tx6_1_5);
printTxData("tx6_1_6", tx6_1_6);
printBalances();
failIfGasEqualsGasUsed(tx6_1_1, testMessage + " - transfer 0.000001 OAX ac2 -> ac5. CHECK for movement");
passIfGasEqualsGasUsed(tx6_1_2, testMessage + " - transfer 0.0002 OAX ac4 -> ac5. CHECK no movement");
failIfGasEqualsGasUsed(tx6_1_3, testMessage + " - approve 0.03 OAX ac3 -> ac5");
failIfGasEqualsGasUsed(tx6_1_4, testMessage + " - approve 4 OAX ac4 -> ac5");
failIfGasEqualsGasUsed(tx6_1_5, testMessage + " - transferFrom 0.03 OAX ac3 -> ac5. CHECK for movement");
passIfGasEqualsGasUsed(tx6_1_6, testMessage + " - transferFrom 4 OAX ac4 -> ac6. CHECK no movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for 1Y unlocked date
// -----------------------------------------------------------------------------
var locked1YDateTime = token.LOCKED_1Y_DATE();
var locked1YDateTimeDate = new Date(locked1YDateTime * 1000);
console.log("RESULT: Waiting until locked 1Y date at " + locked1YDateTime + " " + locked1YDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= locked1YDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until locked 1Y date at " + locked1YDateTime + " " + locked1YDateTimeDate +
  " currentDate=" + new Date());


var lockedTokens = eth.contract(lockedTokensAbi).at(token.lockedTokens());


// -----------------------------------------------------------------------------
var testMessage = "Test 7.1 Unlock 1Y Locked Token";
console.log("RESULT: " + testMessage);
var tx7_1_1 = lockedTokens.unlock1Y({from: earlyBackersAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx7_1_1", tx7_1_1);
printBalances();
failIfGasEqualsGasUsed(tx7_1_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 7.2 Unsuccessfully Unlock 2Y Locked Token";
console.log("RESULT: " + testMessage);
var tx7_2_1 = lockedTokens.unlock2Y({from: earlyBackersAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx7_2_1", tx7_2_1);
printBalances();
passIfGasEqualsGasUsed(tx7_2_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for 2Y unlocked date
// -----------------------------------------------------------------------------
var locked2YDateTime = token.LOCKED_2Y_DATE();
var locked2YDateTimeDate = new Date(locked2YDateTime * 1000);
console.log("RESULT: Waiting until locked 2Y date at " + locked2YDateTime + " " + locked2YDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= locked2YDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until locked 2Y date at " + locked2YDateTime + " " + locked2YDateTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var testMessage = "Test 8.1 Successfully Unlock 2Y Locked Token";
console.log("RESULT: " + testMessage);
var tx8_1_1 = lockedTokens.unlock2Y({from: earlyBackersAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx8_1_1", tx8_1_1);
printBalances();
failIfGasEqualsGasUsed(tx8_1_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 8.2 Successfully Unlock All Tokens including Tranche 1 remaining + Tranche 2 30M";
console.log("RESULT: " + testMessage);
var tx8_2_1 = lockedTokens.unlock2Y({from: foundationAccount, gas: 4000000});
var tx8_2_2 = lockedTokens.unlock1Y({from: advisorsAccount, gas: 4000000});
var tx8_2_3 = lockedTokens.unlock2Y({from: advisorsAccount, gas: 4000000});
var tx8_2_4 = lockedTokens.unlock1Y({from: directorsAccount, gas: 4000000});
var tx8_2_5 = lockedTokens.unlock2Y({from: directorsAccount, gas: 4000000});
var tx8_2_6 = lockedTokens.unlock1Y({from: developersAccount, gas: 4000000});
var tx8_2_7 = lockedTokens.unlock1Y({from: tranche2Account, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx8_2_1", tx8_2_1);
printTxData("tx8_2_2", tx8_2_2);
printTxData("tx8_2_3", tx8_2_3);
printTxData("tx8_2_4", tx8_2_4);
printTxData("tx8_2_5", tx8_2_5);
printTxData("tx8_2_6", tx8_2_6);
printTxData("tx8_2_7", tx8_2_7);
printBalances();
failIfGasEqualsGasUsed(tx8_2_1, testMessage);
failIfGasEqualsGasUsed(tx8_2_2, testMessage);
failIfGasEqualsGasUsed(tx8_2_3, testMessage);
failIfGasEqualsGasUsed(tx8_2_4, testMessage);
failIfGasEqualsGasUsed(tx8_2_5, testMessage);
failIfGasEqualsGasUsed(tx8_2_6, testMessage);
failIfGasEqualsGasUsed(tx8_2_7, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 9.1 Burn Tokens";
console.log("RESULT: " + testMessage);
var tx9_1_1 = token.burnFrom(account5, "100000000000000", {from: account2, gas: 100000});
var tx9_1_2 = token.transfer(account6, "20000000000000000", {from: account6, gas: 100000});
var tx9_1_3 = token.approve("0x0", "3000000000000000000", {from: account3, gas: 100000});
var tx9_1_4 = token.approve("0x0", "400000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx9_1_5 = token.burnFrom(account3, "3000000000000000000", {from: account3, gas: 100000});
var tx9_1_6 = token.burnFrom(account4, "400000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx9_1_1", tx9_1_1);
printTxData("tx9_1_2", tx9_1_2);
printTxData("tx9_1_3", tx9_1_3);
printTxData("tx9_1_4", tx9_1_4);
printTxData("tx9_1_5", tx9_1_5);
printTxData("tx9_1_6", tx9_1_6);
printBalances();
failIfGasEqualsGasUsed(tx9_1_1, testMessage + " - burn 0.0001 OAX ac2. CHECK no movement");
passIfGasEqualsGasUsed(tx9_1_2, testMessage + " - burn 0.02 OAX ac6. CHECK no movement");
failIfGasEqualsGasUsed(tx9_1_3, testMessage + " - approve burn 3 OAX ac3");
failIfGasEqualsGasUsed(tx9_1_4, testMessage + " - approve burn 400 OAX ac4");
failIfGasEqualsGasUsed(tx9_1_5, testMessage + " - burn 3 OAX ac3 from ac3. CHECK for movement");
failIfGasEqualsGasUsed(tx9_1_6, testMessage + " - burn 400 OAX ac4 from ac8. CHECK for movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 10.1 Change Ownership";
console.log("RESULT: " + testMessage);
var tx10_1_1 = token.transferOwnership(minerAccount, {from: tokenOwnerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx10_1_2 = token.acceptOwnership({from: minerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx10_1_1", tx10_1_1);
printTxData("tx10_1_2", tx10_1_2);
printBalances();
failIfGasEqualsGasUsed(tx10_1_1, testMessage + " - Change owner");
failIfGasEqualsGasUsed(tx10_1_2, testMessage + " - Accept ownership");
printTokenContractDynamicDetails();
console.log("RESULT: ");

exit;


// TODO: Update test for this
if (!skipSafeMath && false) {
  // -----------------------------------------------------------------------------
  // Notes: 
  // = To simulate failure, comment out the throw lines in safeAdd() and safeSub()
  //
  var testMessage = "Test 2.0 Safe Maths";
  console.log("RESULT: " + testMessage);
  console.log(JSON.stringify(token));
  var result = token.safeAdd("1", "2");
  if (result == 3) {
    console.log("RESULT: PASS safeAdd(1, 2) = 3");
  } else {
    console.log("RESULT: FAIL safeAdd(1, 2) <> 3");
  }

  var minusOneInt = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
  result = token.safeAdd(minusOneInt, "124");
  if (result == 0) {
    console.log("RESULT: PASS safeAdd(" + minusOneInt + ", 124) = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeAdd(" + minusOneInt + ", 124) = 123. Result=" + result);
  }

  result = token.safeAdd("124", minusOneInt);
  if (result == 0) {
    console.log("RESULT: PASS safeAdd(124, " + minusOneInt + ") = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeAdd(124, " + minusOneInt + ") = 123. Result=" + result);
  }

    result = token.safeSub("124", 1);
  if (result == 123) {
    console.log("RESULT: PASS safeSub(124, 1) = 123. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeSub(124, 1) <> 123. Result=" + result);
  }

    result = token.safeSub("122", minusOneInt);
  if (result == 0) {
    console.log("RESULT: PASS safeSub(122, " + minusOneInt + ") = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeSub(122, " + minusOneInt + ") = 123. Result=" + result);
  }

}

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
