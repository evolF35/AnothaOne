// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Claim is ERC20, Ownable {
    constructor(string memory name, string memory acronym) ERC20(name,acronym) {
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(msg.sender,amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender,amount);
    }
}

contract Pool {

    using SafeERC20 for Claim;

    uint256 settlementDate;
    int256 price;
    address oracleAddress;
    uint256 decayFactor;

    bool condition;

    struct valueAndtime {
        uint value;
        uint time;
    }

    mapping(address => uint) public PosnumDeposits;
    mapping(address => uint) public NegnumDeposits;

    mapping(address => mapping(uint => valueAndtime)) PosTimein;
    mapping(address => mapping(uint => valueAndtime)) NegTimein;

    Claim public positiveSide;
    Claim public negativeSide;

    AggregatorV3Interface public oracle;

    function getCondition() public view returns (bool){
        return(condition);
    }
    function getOracleAddress() public view returns (address){
        return(oracleAddress);
    }
    function getSettlementPrice() public view returns (int256){
        return(price);
    }
    function getSettlementDate() public view returns (uint256){
        return(settlementDate);
    }
    function getDecayFactor() public view returns (uint256){
        return(decayFactor);
    }
    function pastSettlementDate() public view returns (bool){
        return(block.timestamp > settlementDate);
    }

    constructor(address _oracle, int256 _price, uint256 _settlementDate,uint256 _decay,string memory name,string memory acronym) {
        settlementDate = _settlementDate;
        price = _price;
        oracleAddress = _oracle;
        decayFactor = _decay;

        string memory over = "Over";
        string memory Over = string(bytes.concat(bytes(name), "-", bytes(over)));

        string memory under = "Under";
        string memory Under = string(bytes.concat(bytes(name), "-", bytes(under)));

        string memory Pacr = "POS";
        string memory PAC = string(bytes.concat(bytes(acronym), "-", bytes(Pacr)));

        string memory Nacr = "NEG";
        string memory NAC = string(bytes.concat(bytes(acronym), "-", bytes(Nacr)));

        positiveSide = new Claim(Over,PAC);
        negativeSide = new Claim(Under,NAC);

        condition = false;

        oracle = AggregatorV3Interface(oracleAddress);
    }

    function depositToPOS() public payable {
        require(block.timestamp < settlementDate);
        require(msg.value > 0.001 ether, "mc");
        positiveSide.mint(msg.value);
        positiveSide.safeTransfer(msg.sender,msg.value);

        PosnumDeposits[msg.sender]++;
        uint currentIndex = PosnumDeposits[msg.sender];
        PosTimein[msg.sender][currentIndex] = valueAndtime({value: msg.value,time:block.timestamp});
    }

    function depositToNEG() public payable {
        require(block.timestamp < settlementDate);
        require(msg.value > 0.001 ether, "mc");
        negativeSide.mint(msg.value);
        negativeSide.safeTransfer(msg.sender,msg.value);

        NegnumDeposits[msg.sender]++;
        uint currentIndex = NegnumDeposits[msg.sender];
        NegTimein[msg.sender][currentIndex] = valueAndtime({value: msg.value,time:block.timestamp});
    }

    function settle() public {
        require(block.timestamp > settlementDate, "te");
        (,int256 resultPrice,,,) = oracle.latestRoundData();

        if(resultPrice >= price){
            condition = true;
        }

    }

    function withdrawWithPOS() public { 
        require(block.timestamp > settlementDate, "te");
        require(condition == true,"cn");
        require(positiveSide.balanceOf(msg.sender) > 0, "yn");

        uint256 saved = (positiveSide.balanceOf(msg.sender) / positiveSide.totalSupply()) * (address(this).balance);
        
        positiveSide.safeTransferFrom(msg.sender,address(this),positiveSide.balanceOf(msg.sender));

        (payable(msg.sender)).transfer(saved);
    }

    function withdrawWithNEG() public {
        require(block.timestamp > settlementDate, "te");
        require(condition == false,"cn");
        require(negativeSide.balanceOf(msg.sender) > 0, "yn");

        uint256 saved = (negativeSide.balanceOf(msg.sender) / negativeSide.totalSupply()) * (address(this).balance);
        
        negativeSide.safeTransferFrom(msg.sender,address(this),negativeSide.balanceOf(msg.sender));

        (payable(msg.sender)).transfer(saved);
    }
}

contract deploy {

    event PoolCreated(address _oracle, int256 _price, uint256 _settlementDate,uint256 decay,string name,string acronym,address poolAddress);

    function createPool(address oracle, int256 price, uint256 settlementDate,uint256 decay,string memory name,string memory acronym ) public returns (address newPool){
        newPool = address(new Pool(oracle,price,settlementDate,decay,name,acronym));
        emit PoolCreated(oracle,price,settlementDate,decay,name,acronym,newPool);
        return(newPool);
    }
}

