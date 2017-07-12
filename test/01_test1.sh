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
ENDTIME=`echo "$CURRENTTIME+60*4" | bc`
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
// NOTE: 8 or 18, does not make a difference in the tranches calculations
var decimals = 18;
var mintable = true;

var minimumFundingGoal = new BigNumber(1000).shift(18);
var cap = new BigNumber(2000).shift(18);

#      0 to 15,000 ETH 10,000 FEED = 1 ETH
# 15,000 to 28,000 ETH  9,000 FEED = 1 ETH
var tranches = [ \
  0, new BigNumber(1).shift(18).div(10000), \
  new BigNumber(1500).shift(18), new BigNumber(1).shift(18).div(9000), \
  cap, 0 \
];

var teamMembers = [ team1, team2, team3 ];
var teamBonus = [150, 150, 150];

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
        addAccount(cstAddress, "Token '" + symbol + "' '" + name + "'");
        addTokenContractAddressAndAbi(cstAddress, cstAbi);
        console.log("DATA: teAddress=" + cstAddress);
      }
    }
  }
);


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

printTxData("cstAddress=" + cstAddress, cstTx);
printTxData("etpAddress=" + etpAddress, etpTx);
printBalances();
failIfGasEqualsGasUsed(cstTx, cstMessage);
failIfGasEqualsGasUsed(etpTx, etpMessage);
printTokenContractDetails();
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
        addCrowdsaleContractAddressAndAbi(mecAddress, mecAbi);
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
printCrowdsaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var bfaMessage = "Deploy BonusFinalizerAgent Contract";
console.log("RESULT: " + bfaMessage);
var bfaContract = web3.eth.contract(bfaAbi);
console.log(JSON.stringify(bfaContract));
var bfaTx = null;
var bfaAddress = null;

var bfa = bfaContract.new(cstAddress, mecAddress, teamBonus, teamMembers, {from: contractOwnerAccount, data: bfaBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        bfaTx = contract.transactionHash;
      } else {
        bfaAddress = contract.address;
        addAccount(bfaAddress, "BonusFinalizerAgent");
        console.log("DATA: bfaAddress=" + bfaAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("bfaAddress=" + bfaAddress, bfaTx);
printBalances();
failIfGasEqualsGasUsed(bfaTx, bfaMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var invalidContribution1Message = "Send Invalid Contribution - 100 ETH From Account6 - Before Crowdsale Start";
console.log("RESULT: " + invalidContribution1Message);
var invalidContribution1Tx = eth.sendTransaction({from: account6, to: mecAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("invalidContribution1Tx", invalidContribution1Tx);
printBalances();
passIfGasEqualsGasUsed(invalidContribution1Tx, invalidContribution1Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var stitchMessage = "Stitch Contracts Together";
console.log("RESULT: " + stitchMessage);
var stitch1Tx = cst.setMintAgent(mecAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch2Tx = cst.setMintAgent(bfaAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch3Tx = cst.setReleaseAgent(bfaAddress, {from: contractOwnerAccount, gas: 400000});
var stitch4Tx = cst.setTransferAgent(mecAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch5Tx = mec.setFinalizeAgent(bfaAddress, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("stitch1Tx", stitch1Tx);
printTxData("stitch2Tx", stitch2Tx);
printTxData("stitch3Tx", stitch3Tx);
printTxData("stitch4Tx", stitch4Tx);
printTxData("stitch5Tx", stitch5Tx);
printBalances();
failIfGasEqualsGasUsed(stitch1Tx, stitchMessage + " 1");
failIfGasEqualsGasUsed(stitch2Tx, stitchMessage + " 2");
failIfGasEqualsGasUsed(stitch3Tx, stitchMessage + " 3");
failIfGasEqualsGasUsed(stitch4Tx, stitchMessage + " 4");
failIfGasEqualsGasUsed(stitch5Tx, stitchMessage + " 5");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startsAtTime = mec.startsAt();
var startsAtTimeDate = new Date(startsAtTime * 1000);
console.log("RESULT: Waiting until startAt date at " + startsAtTime + " " + startsAtTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startsAtTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startsAtTime + " " + startsAtTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account6 - After Crowdsale Start";
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = mec.investWithCustomerId(account6, 123, {from: account6, to: mecAddress, gas: 400000, value: web3.toWei("100", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 1900 ETH From Account7 - After Crowdsale Start";
console.log("RESULT: " + validContribution1Message);
var validContribution2Tx = mec.investWithCustomerId(account7, 124, {from: account7, to: mecAddress, gas: 400000, value: web3.toWei("1900", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution2Tx, validContribution2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finaliseMessage = "Finalise Crowdsale";
console.log("RESULT: " + finaliseMessage);
var finaliseTx = mec.finalize({from: contractOwnerAccount, to: mecAddress, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("finaliseTx", finaliseTx);
printBalances();
failIfGasEqualsGasUsed(finaliseTx, finaliseMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transfersMessage = "Testing token transfers";
console.log("RESULT: " + transfersMessage);
var transfers1Tx = cst.transfer(account8, "1000000000000000000", {from: account6, gas: 100000});
var transfers2Tx = cst.approve(account9,  "2000000000000000000", {from: account7, gas: 100000});
while (txpool.status.pending > 0) {
}
var transfers3Tx = cst.transferFrom(account7, account9, "2000000000000000000", {from: account9, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("transfers1Tx", transfers1Tx);
printTxData("transfers2Tx", transfers2Tx);
printTxData("transfers3Tx", transfers3Tx);
printBalances();
failIfGasEqualsGasUsed(transfers1Tx, transfersMessage + " - transfer 1 token ac6 -> ac8");
failIfGasEqualsGasUsed(transfers2Tx, transfersMessage + " - approve 2 tokens ac7 -> ac9");
failIfGasEqualsGasUsed(transfers3Tx, transfersMessage + " - transferFrom 2 tokens ac7 -> ac9");
printTokenContractDetails();
console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
// Wait for crowdsale end
// -----------------------------------------------------------------------------
var endsAtTime = mec.endsAt();
var endsAtTimeDate = new Date(endsAtTime * 1000);
console.log("RESULT: Waiting until startAt date at " + endsAtTime + " " + endsAtTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= endsAtTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + endsAtTime + " " + endsAtTimeDate +
  " currentDate=" + new Date());

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
