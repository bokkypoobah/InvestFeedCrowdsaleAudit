pragma solidity ^0.4.11;
// Thanks to OpenZeppeline & TokenMarket for the awesome Libraries.
contract SafeMathLib {
  function safeMul(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }
}


contract Ownable {
  address public owner;
  address public newOwner;
  event OwnershipTransferred(address indexed _from, address indexed _to);
  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address _newOwner) onlyOwner {
    newOwner = _newOwner;
  }

  function acceptOwnership() {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address _to, uint _value) returns (bool success);
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address _from, address _to, uint _value) returns (bool success);
  function approve(address _spender, uint _value) returns (bool success);
  event Approval(address indexed owner, address indexed spender, uint value);
}



contract StandardToken is ERC20, SafeMathLib {
  event Minted(address receiver, uint amount);
  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    if (balances[msg.sender] >= _value 
        && _value > 0 
        && balances[_to] + _value > balances[_to]
        ) {
      balances[msg.sender] = safeSub(balances[msg.sender],_value);
      balances[_to] = safeAdd(balances[_to],_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }
    else{
      return false;
    }
    
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    if (balances[_from] >= _value
        && _allowance >= _value
        && _value > 0
        && balances[_to] + _value > balances[_to]
        ){
    balances[_to] = safeAdd(balances[_to],_value);
    balances[_from] = safeSub(balances[_from],_value);
    allowed[_from][msg.sender] = safeSub(_allowance,_value);
    Transfer(_from, _to, _value);
    return true;
        }
    else {
      return false;
    }
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  function addApproval(address _spender, uint _addedValue) returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    allowed[msg.sender][_spender] = safeAdd(oldValue,_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function subApproval(address _spender, uint _subtractedValue) returns (bool success) {

    uint oldVal = allowed[msg.sender][_spender];

    if (_subtractedValue > oldVal) {
        allowed[msg.sender][_spender] = 0;
    } else {
        allowed[msg.sender][_spender] = safeSub(oldVal,_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract UpgradeAgent {
  uint public originalSupply;
  function isUpgradeAgent() public constant returns (bool) {
    return true;
  }
  function upgradeFrom(address _from, uint256 _value) public;
}

contract UpgradeableToken is StandardToken {
  address public upgradeMaster;
  UpgradeAgent public upgradeAgent;
  uint256 public totalUpgraded;
  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}
  event Upgrade(address indexed _from, address indexed _to, uint256 _value);
  event UpgradeAgentSet(address agent);
  function UpgradeableToken(address _upgradeMaster) {
    upgradeMaster = _upgradeMaster;
  }
  function upgrade(uint256 value) public {
    UpgradeState state = getUpgradeState();
    require((state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading));
    if (value == 0) throw;

    balances[msg.sender] = safeSub(balances[msg.sender],value);
    totalSupply = safeSub(totalSupply,value);
    totalUpgraded = safeAdd(totalUpgraded,value);
    upgradeAgent.upgradeFrom(msg.sender, value);
    Upgrade(msg.sender, upgradeAgent, value);
  }
  function setUpgradeAgent(address agent) external {
    require(canUpgrade());

    require(agent != 0x0);
    require(msg.sender == upgradeMaster);
    require(getUpgradeState() != UpgradeState.Upgrading);

    upgradeAgent = UpgradeAgent(agent);
    require(upgradeAgent.isUpgradeAgent());
    require(upgradeAgent.originalSupply() == totalSupply);

    UpgradeAgentSet(upgradeAgent);
  }
  function getUpgradeState() public constant returns(UpgradeState) {
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }
  function setUpgradeMaster(address master) public {
    require(master != 0x0);
    require(msg.sender == upgradeMaster);
    upgradeMaster = master;
  }
  function canUpgrade() public constant returns(bool) {
     return true;
  }

}



contract ReleasableToken is ERC20, Ownable {
  address public releaseAgent;
  bool public released = false;
  mapping (address => bool) public transferAgents;
  modifier canTransfer(address _sender) {

    if(!released) {
        require(transferAgents[_sender]);
    }

    _;
  }
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
    releaseAgent = addr;
  }
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    transferAgents[addr] = state;
  }
  function releaseTokenTransfer() public onlyReleaseAgent {
    released = true;
  }
  modifier inReleaseState(bool releaseState) {
    require(releaseState == released);
    _;
  }
  modifier onlyReleaseAgent() {
    require(msg.sender == releaseAgent);
    _;
  }

  function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
   return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

}


contract MintableToken is StandardToken, Ownable {

  bool public mintingFinished = false;
  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state  );
  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply = safeAdd(totalSupply, amount);
    balances[receiver] = safeAdd(balances[receiver], amount);
    Transfer(0, receiver, amount);
  }
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    MintingAgentChanged(addr, state);
  }

  modifier onlyMintAgent() {
    require(mintAgents[msg.sender]);
    _;
  }
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
}


contract CrowdsaleToken is ReleasableToken, MintableToken, UpgradeableToken {

  event UpdatedTokenInformation(string newName, string newSymbol);

  string public name;

  string public symbol;

  uint8 public decimals;
  function CrowdsaleToken(string _name, string _symbol, uint _initialSupply, uint8 _decimals, bool _mintable)
    UpgradeableToken(msg.sender) {
    owner = msg.sender;

    name = _name;
    symbol = _symbol;

    totalSupply = _initialSupply;

    decimals = _decimals;
    balances[owner] = totalSupply;

    if(totalSupply > 0) {
      Minted(owner, totalSupply);
    }
    if(!_mintable) {
      mintingFinished = true;
      require(totalSupply != 0);
    }
  }
  function releaseTokenTransfer() public onlyReleaseAgent {
    mintingFinished = true;
    super.releaseTokenTransfer();
  }
  function canUpgrade() public constant returns(bool) {
    return released && super.canUpgrade();
  }
  function setTokenInformation(string _name, string _symbol) onlyOwner {
    name = _name;
    symbol = _symbol;
    UpdatedTokenInformation(name, symbol);
  }

}
