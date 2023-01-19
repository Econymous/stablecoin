contract Synthony{
    uint scale = 1e18;
    address DAO = 0x0000000000000000000000000000000000000000; //starting DAO
    address THIS =  address(this);

    uint synthetics;
    mapping(uint => Synthetic) synthetic;
    struct Synthetic{
        SyntheticToken token;
        string name;
        string description;
        mapping(uint=>uint) loanRatio;
        mapping(uint=>uint) interestRate;
        mapping(uint=>uint) threshold;
    }
    
    uint collaterals;
    mapping(uint => Collateral) collateral;
    struct Collateral{
        ERC20 token;
    }

    uint debts;
    mapping(uint => Debt) debt;
    struct Debt{
        address owner;
        uint collateralAmount;
        uint syntheticID;
        uint collateralID;
        uint threshold;
        uint date;
    }

    uint tickets;
    mapping(uint => Ticket) ticket;
    struct Ticket{
        uint purpose;
        string name;
        string description;
        string symbol;
    }

    function takeOutDebt(uint collateralAmount, uint syntheticType, uint collateralType) external{
        address sender = msg.sender;
        Collateral storage col = collateral[collateralType];
        col.token.transferFrom(sender, THIS, collateralAmount);
        Synthetic storage synth = synthetic[syntheticType];
        uint syntheticTokens = collateralAmount * scale / synth.loanRatio[collateralType];

        Debt storage _debt = debt[debts];
        _debt.owner = sender;
        _debt.threshold = synth.threshold[collateralType];
        _debt.date = block.timestamp;
        _debt.collateralID = collateralType;
        _debt.collateralAmount = collateralAmount;
        _debt.syntheticID = syntheticType;
        collaterals++;   

        synth.token.mint(sender,syntheticTokens);
    }

    function transferDebt() external{
        //require(msg.sender == );
    }

    function resolveDebt() external{
        //
    }

    function liquidate() external{
        //
    }

    function oracleIntFallback(uint ticketID, bool EXCEPTION, uint numberOfOptions, uint[] memory optionWeights, int[] memory intOptions) external{
        //
    }

    function price_request() external{
        //
    }

    function price_response() internal{
        //
    }

    function stability_request() external{
        //
    }

    function stability_response() internal{
        //
    }
    
    function threshold_request() external{
        //
    }

    function threshold_response() internal{
        //
    }
    
    function loanRatio_request() external{
        //
    }

    function loanRatio_response() internal{
        //
    }

    function createSynthetic_request(string memory name, string memory description) external{
        //
    }

    function createSynthetic_response() internal{
        //new SyntheticToken();
    }

    function collateral_request() external{
        //
    }

    function collateral_response() internal{
        //
    }
    
    function pairing_request() external{
        //
    }

    function pairing_response() internal{
        //
    }

    function description_request() external{
        //
    }

    function description_response() internal{
        //
    }

    //oracleAddressFallback
    function hop_request(address newOracle) external{
        //
    }
    
    function hop_response() internal{
        //
    }

    /*
    price request/response
    stability fee
    liquidation threshold
    loan ratio
    propose Synthetic
    propose Collateral
    propose pairing
    propose Description change
    daoHop
    */
}

abstract contract ERC20{
    function transfer(address _to, uint _value) public virtual returns (bool);
    function transferFrom(address src, address dst, uint amount) public virtual returns (bool);
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract SyntheticToken is IERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    address synthony;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        synthony = msg.sender;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    function mint(address _address, uint _value) external{
        require(msg.sender == synthony);
		balances[_address] += _value;
		totalSupply_ += _value;
		emit Transfer(address(0), _address, _value);
	}
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}